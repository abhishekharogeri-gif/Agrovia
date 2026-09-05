import 'package:flutter_test/flutter_test.dart';
import 'package:agrovia/models/diagnosis_result.dart';
import 'package:agrovia/services/offline_sync_service.dart';

void main() {
  group('OfflineSyncService Tests', () {
    test('Enqueue and process offline sync queue properly', () async {
      final syncService = OfflineSyncService();

      final dummyResult = DiagnosisResult(
        id: 'test_diag_123',
        cropName: 'Wheat',
        diseaseName: 'Yellow Rust',
        confidence: 0.95,
        healthScore: 82.0,
        affectedAreaPct: 8.5,
        severity: 'Low',
        imagePath: 'path/to/img.jpg',
        timestamp: DateTime.now(),
        radarMetrics: [],
        organicTreatment: TreatmentPlan(title: 'Neem Spray', steps: [], dosage: '5ml/L', safetyWarning: 'Avoid eyes'),
        chemicalTreatment: TreatmentPlan(title: 'Propiconazole', steps: [], dosage: '1ml/L', safetyWarning: 'Wear mask'),
      );

      syncService.enqueueDiagnosis(dummyResult);
      expect(syncService.pendingCount, greaterThanOrEqualTo(1));

      final synced = await syncService.processSyncQueue();
      expect(synced, greaterThanOrEqualTo(1));
      expect(syncService.pendingCount, 0);
    });
  });
}
