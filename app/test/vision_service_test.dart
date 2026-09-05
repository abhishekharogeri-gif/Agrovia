import 'package:flutter_test/flutter_test.dart';
import 'package:agrovia/services/vision_x_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VisionXService Unit Tests', () {
    test('diagnoseImage returns valid diagnosis result with treatment plans', () async {
      final service = VisionXService();
      final result = await service.diagnoseImage('dummy/path/leaf.jpg');

      expect(result.cropName, 'Soybean');
      expect(result.diseaseName, contains('Frogeye Leaf Spot'));
      expect(result.confidence, greaterThanOrEqualTo(0.9));
      expect(result.organicTreatment.steps.isNotEmpty, isTrue);
      expect(result.chemicalTreatment.steps.isNotEmpty, isTrue);
      expect(result.radarMetrics.length, 5);
      expect(result.affectedAreaPct, 14.2);
    });
  });
}
