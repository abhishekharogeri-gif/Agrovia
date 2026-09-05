import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/diagnosis_result.dart';

class VisionXService {
  static final VisionXService _instance = VisionXService._internal();
  factory VisionXService() => _instance;
  VisionXService._internal();

  bool _isModelLoaded = false;
  bool get isModelLoaded => _isModelLoaded;

  Future<void> initModel() async {
    try {
      // Lazy load model from assets if available
      // In production: await Interpreter.fromAsset('assets/models/crop_disease_model.tflite');
      _isModelLoaded = true;
    } catch (e) {
      debugPrint('VisionXService: Failed to load TFLite model, fallback enabled: $e');
      _isModelLoaded = false;
    }
  }

  // Dual-stage on-device inference isolated in a background worker
  Future<DiagnosisResult> diagnoseImage(String imagePath) async {
    return compute(_runInferenceIsolate, imagePath);
  }
}

// Background compute function
Future<DiagnosisResult> _runInferenceIsolate(String imagePath) async {
  // Simulated dual-stage fast classification & segmentation
  // (In production, load image tensor, normalize 0-255 to [0,1], run interpreter)
  await Future.delayed(const Duration(milliseconds: 1200));

  return DiagnosisResult(
    id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
    cropName: 'Soybean',
    diseaseName: 'Frogeye Leaf Spot (Cercospora sojina)',
    confidence: 0.942,
    healthScore: 78.5,
    affectedAreaPct: 14.2,
    severity: 'Moderate',
    imagePath: imagePath,
    timestamp: DateTime.now(),
    radarMetrics: [
      RadarMetric(label: 'Fungal Risk', value: 0.85),
      RadarMetric(label: 'Spread Velocity', value: 0.60),
      RadarMetric(label: 'Yield Impact', value: 0.45),
      RadarMetric(label: 'Moisture Vuln.', value: 0.75),
      RadarMetric(label: 'Recovery Potential', value: 0.90),
    ],
    organicTreatment: TreatmentPlan(
      title: 'Neem Oil & Trichoderma Spray',
      steps: [
        'Mix 5ml cold-pressed Neem Oil (10,000 ppm) per liter of warm water with 1ml organic soap liquid.',
        'Apply Trichoderma harzianum @ 5g/liter on soil around root zones to prevent secondary spore spread.',
        'Spray during early morning or late evening (avoid direct hot sunlight).'
      ],
      dosage: '5ml / Liter of water',
      safetyWarning: 'Safe for pollinators when sprayed in late evening.',
    ),
    chemicalTreatment: TreatmentPlan(
      title: 'Pyraclostrobin + Fluxapyroxad Fungicide',
      steps: [
        'Apply systemic fungicide (e.g. Priaxor / Pyraclostrobin 20% + Fluxapyroxad 20% SC).',
        'Ensure uniform coverage on lower and upper leaf surfaces.',
        'Maintain a 14-day pre-harvest interval (PHI).'
      ],
      dosage: '120ml / Acre in 150L water',
      safetyWarning: 'Wear protective gloves, mask, and goggles during preparation and spraying.',
    ),
  );
}
