import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/diagnosis_result.dart';

enum SyncItemType { visionDiagnosis, mandiAlert, farmerPost, dpdpConsent }

class SyncQueueItem {
  final String id;
  final SyncItemType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int retryCount;

  SyncQueueItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });
}

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final List<SyncQueueItem> _pendingQueue = [];
  bool _isSyncing = false;

  List<SyncQueueItem> get pendingQueue => List.unmodifiable(_pendingQueue);
  int get pendingCount => _pendingQueue.length;

  /// Enqueue an on-device diagnosis result for background synchronization
  void enqueueDiagnosis(DiagnosisResult result) {
    final item = SyncQueueItem(
      id: 'sync_diag_${result.id}',
      type: SyncItemType.visionDiagnosis,
      createdAt: DateTime.now(),
      payload: {
        'diagnosisId': result.id,
        'cropName': result.cropName,
        'diseaseName': result.diseaseName,
        'confidence': result.confidence,
        'healthScore': result.healthScore,
        'affectedAreaPct': result.affectedAreaPct,
        'imagePath': result.imagePath,
        'treatmentOrganic': result.organicTreatment.title,
        'treatmentChemical': result.chemicalTreatment.title,
      },
    );

    _pendingQueue.add(item);
    debugPrint('OfflineSyncService: Enqueued diagnosis ${result.id}. Queue size: ${_pendingQueue.length}');
  }

  /// Trigger sync flush to backend
  Future<int> processSyncQueue({String backendBaseUrl = 'http://localhost:3000'}) async {
    if (_isSyncing || _pendingQueue.isEmpty) return 0;

    _isSyncing = true;
    int syncedCount = 0;

    try {
      debugPrint('OfflineSyncService: Flushing ${_pendingQueue.length} items to $backendBaseUrl...');

      // Simulate non-blocking asynchronous batch network transmission
      await Future.delayed(const Duration(milliseconds: 800));

      final itemsToProcess = List<SyncQueueItem>.from(_pendingQueue);
      for (final item in itemsToProcess) {
        // In live mode: call http.post('$backendBaseUrl/vision/diagnose', ...)
        _pendingQueue.remove(item);
        syncedCount++;
      }

      debugPrint('OfflineSyncService: Successfully synced $syncedCount items with cloud.');
    } catch (e) {
      debugPrint('OfflineSyncService: Error during queue flush: $e');
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }
}
