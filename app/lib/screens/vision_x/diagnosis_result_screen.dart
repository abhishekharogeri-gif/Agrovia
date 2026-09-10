import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/diagnosis_result.dart';
import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';

class DiagnosisResultScreen extends StatefulWidget {
  final DiagnosisResult result;

  const DiagnosisResultScreen({super.key, required this.result});

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;

    return Scaffold(
      backgroundColor: AgroviaColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Diagnosis Report', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AgroviaColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AgroviaColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing card generated for Kisan Connect!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (res.isUnregistered) ...[
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              surfaceColor: AgroviaColors.accentDanger.withValues(alpha: 0.12),
              borderColor: AgroviaColors.accentDanger.withValues(alpha: 0.35),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AgroviaColors.accentDanger, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Crop is not registered in database',
                      style: TextStyle(
                        color: AgroviaColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Crop & Disease Header Card
          GlassContainer(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AgroviaColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AgroviaColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        res.cropName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.primary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: res.severity == 'Severe'
                            ? AgroviaColors.accentDanger.withValues(alpha: 0.15)
                            : AgroviaColors.accentWarning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: res.severity == 'Severe'
                              ? AgroviaColors.accentDanger.withValues(alpha: 0.3)
                              : AgroviaColors.accentWarning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Severity: ${res.severity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: res.severity == 'Severe' ? AgroviaColors.accentDanger : AgroviaColors.accentWarning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  res.diseaseName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Confidence: ${(res.confidence * 100).toStringAsFixed(1)}% (On-Device Dual-Stage)',
                  style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Health Donut & Affected Area Metric
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  child: Column(
                    children: [
                      const Text('Overall Crop Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AgroviaColors.textPrimary)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 28,
                                startDegreeOffset: 270,
                                sections: [
                                  PieChartSectionData(
                                    value: res.healthScore,
                                    color: AgroviaColors.accentGreen,
                                    radius: 12,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: 100 - res.healthScore,
                                    color: Colors.white.withValues(alpha: 0.05),
                                    radius: 12,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                '${res.healthScore.toInt()}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AgroviaColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassContainer(
                  child: Column(
                    children: [
                      const Text('Affected Leaf Area', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AgroviaColors.textPrimary)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 28,
                                startDegreeOffset: 270,
                                sections: [
                                  PieChartSectionData(
                                    value: res.affectedAreaPct,
                                    color: AgroviaColors.accentDanger,
                                    radius: 12,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: 100 - res.affectedAreaPct,
                                    color: Colors.white.withValues(alpha: 0.05),
                                    radius: 12,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                '${res.affectedAreaPct.toStringAsFixed(1)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AgroviaColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Condition Radar Chart
          GlassContainer(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Agronomic Risk Radar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      dataSets: [
                        RadarDataSet(
                          fillColor: AgroviaColors.primary.withValues(alpha: 0.25),
                          borderColor: AgroviaColors.primary,
                          entryRadius: 3,
                          dataEntries: res.radarMetrics.map((m) => RadarEntry(value: m.value)).toList(),
                          borderWidth: 2,
                        ),
                      ],
                      radarBorderData: BorderSide(color: AgroviaColors.glassBorderDark, width: 1),
                      gridBorderData: BorderSide(color: AgroviaColors.glassBorderDark.withValues(alpha: 0.5), width: 1),
                      tickCount: 3,
                      getTitle: (index, angle) {
                        return RadarChartTitle(
                          text: res.radarMetrics[index].label,
                          angle: angle,
                          positionPercentageOffset: 0.15,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Treatment Tabs: Organic vs Chemical
          TabBar(
            controller: _tabController,
            labelColor: AgroviaColors.primary,
            unselectedLabelColor: AgroviaColors.textSecondary,
            indicatorColor: AgroviaColors.primary,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(icon: Icon(Icons.eco_rounded), text: 'Organic Advisory'),
              Tab(icon: Icon(Icons.science_rounded), text: 'Chemical Control'),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 260,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTreatmentView(res.organicTreatment, isOrganic: true),
                _buildTreatmentView(res.chemicalTreatment, isOrganic: false),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Symptoms Card (when present)
          if (res.symptoms.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.visibility_rounded, size: 18, color: AgroviaColors.accentWarning),
                      SizedBox(width: 8),
                      Text('Symptoms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
                    ],
                  ),
                  const Divider(height: 16, color: AgroviaColors.glassBorderDark),
                  ...res.symptoms.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.primary)),
                        Expanded(child: Text(s, style: const TextStyle(fontSize: 13, color: AgroviaColors.textPrimary))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Harvest Advisory (when present)
          if (res.harvestWindow != null || (res.harvestIndicators?.isNotEmpty ?? false)) ...[
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              surfaceColor: AgroviaColors.accentGreen.withValues(alpha: 0.08),
              borderColor: AgroviaColors.accentGreen.withValues(alpha: 0.25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.agriculture_rounded, size: 18, color: AgroviaColors.accentGreen),
                      SizedBox(width: 8),
                      Text('Harvest Advisory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
                    ],
                  ),
                  const Divider(height: 16, color: AgroviaColors.glassBorderDark),
                  if (res.harvestWindow != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Window: ${res.harvestWindow}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AgroviaColors.textPrimary)),
                    ),
                  if (res.harvestIndicators?.isNotEmpty ?? false)
                    ...res.harvestIndicators!.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✓ ', style: TextStyle(color: AgroviaColors.accentGreen, fontWeight: FontWeight.bold)),
                          Expanded(child: Text(h, style: const TextStyle(fontSize: 13, color: AgroviaColors.textPrimary))),
                        ],
                      ),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Precautions (when present)
          if (res.precautions.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              surfaceColor: AgroviaColors.accentDanger.withValues(alpha: 0.08),
              borderColor: AgroviaColors.accentDanger.withValues(alpha: 0.25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: AgroviaColors.accentDanger),
                      SizedBox(width: 8),
                      Text('Precautions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
                    ],
                  ),
                  const Divider(height: 16, color: AgroviaColors.glassBorderDark),
                  ...res.precautions.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠ ', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.accentDanger)),
                        Expanded(child: Text(p, style: const TextStyle(fontSize: 13, color: AgroviaColors.textPrimary))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Ask Saanvi Floating Shortcut
          GlassContainer(
            surfaceColor: AgroviaColors.glassSurfaceDark,
            borderColor: AgroviaColors.glassBorderDark,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AgroviaColors.primaryLight, AgroviaColors.primaryDark],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset('assets/icons/saanvi.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Have questions about this disease?', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                      Text('Ask Saanvi in Hindi, Marathi, Telugu...', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AgroviaColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTreatmentView(TreatmentPlan plan, {required bool isOrganic}) {
    return GlassContainer(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
          if (plan.dosage != null) ...[
            const SizedBox(height: 4),
            Text('Recommended Dosage: ${plan.dosage}', style: const TextStyle(fontWeight: FontWeight.w600, color: AgroviaColors.primary, fontSize: 13)),
          ],
          const Divider(height: 20, color: AgroviaColors.glassBorderDark),
          ...plan.steps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${entry.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.primary)),
                    Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 13, color: AgroviaColors.textPrimary))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOrganic ? AgroviaColors.accentGreen.withValues(alpha: 0.15) : AgroviaColors.accentWarning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isOrganic ? AgroviaColors.accentGreen.withValues(alpha: 0.3) : AgroviaColors.accentWarning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isOrganic ? AgroviaColors.accentGreen : AgroviaColors.accentWarning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.safetyWarning,
                    style: TextStyle(
                      fontSize: 11,
                      color: isOrganic ? AgroviaColors.accentGreen : AgroviaColors.accentWarning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
