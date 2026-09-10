class DiagnosisResult {
  final String id;
  final String cropName;
  final String diseaseName;
  final double confidence;
  final double healthScore; // 0 to 100
  final double affectedAreaPct; // e.g. 15.5%
  final String severity; // 'Low', 'Moderate', 'Severe'
  final List<RadarMetric> radarMetrics;
  final TreatmentPlan organicTreatment;
  final TreatmentPlan chemicalTreatment;
  final DateTime timestamp;
  final String? imagePath;

  // New advisory fields
  final List<String> symptoms;
  final List<String> cultural;
  final List<String> organic;
  final List<String> chemical;
  final List<String> precautions;
  final String? harvestWindow;
  final List<String>? harvestIndicators;
  final bool isUnregistered;

  DiagnosisResult({
    required this.id,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.healthScore,
    required this.affectedAreaPct,
    required this.severity,
    required this.radarMetrics,
    required this.organicTreatment,
    required this.chemicalTreatment,
    required this.timestamp,
    this.imagePath,
    this.symptoms = const [],
    this.cultural = const [],
    this.organic = const [],
    this.chemical = const [],
    this.precautions = const [],
    this.harvestWindow,
    this.harvestIndicators,
    this.isUnregistered = false,
  });
}

class RadarMetric {
  final String label;
  final double value; // 0 to 1.0

  RadarMetric({required this.label, required this.value});
}

class TreatmentPlan {
  final String title;
  final List<String> steps;
  final String? dosage;
  final String safetyWarning;

  TreatmentPlan({
    required this.title,
    required this.steps,
    this.dosage,
    required this.safetyWarning,
  });
}
