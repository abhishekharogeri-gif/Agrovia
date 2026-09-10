import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AgroviaScanner {
  Interpreter? _interpreter;
  List<String> _labels = [];
  Map<String, dynamic> _advisoryDB = {};

  bool get isReady => _interpreter != null && _labels.isNotEmpty;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/agrovia_model.tflite');

      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();

      final dbData = await rootBundle.loadString('assets/data/agrovia_advisory.json');
      _advisoryDB = json.decode(dbData);
    } catch (e) {
      // ignore: avoid_print
      print('Error loading scanner models: $e');
    }
  }

  Map<String, dynamic>? processImage(Uint8List imageBytes) {
    if (!isReady) return null;

    // Decode and resize image to 224x224 (MobileNet standard)
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return null;

    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    // Normalize pixel values to 0.0 - 1.0 (or whatever format model expects)
    var input = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resizedImage.getPixel(x, y);
            return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          },
        ),
      ),
    );

    // Prepare output buffer
    var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

    // Run inference
    _interpreter!.run(input, output);

    // Find highest scoring class
    List<double> probabilities = List<double>.from(output[0]);
    int maxIndex = 0;
    double maxProb = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    String predictedClass = _labels[maxIndex].trim();
    var advisoryEntry = _advisoryDB[predictedClass];
    if (advisoryEntry == null || maxProb < 0.35) {
      return {
        'confidence': maxProb,
        'predicted_class': 'Unregistered',
        'crop': 'Unregistered Crop',
        'condition': 'Crop is not registered in database',
        'is_unregistered': true,
        'message': 'Crop is not registered in database',
      };
    }
    var result = Map<String, dynamic>.from(advisoryEntry);
    result['confidence'] = maxProb;
    result['predicted_class'] = predictedClass;
    result['is_unregistered'] = false;

    return result;
  }
}
