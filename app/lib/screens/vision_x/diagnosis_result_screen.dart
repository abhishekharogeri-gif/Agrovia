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
      appBar: AppBar(
        title: const Text('Diagnosis Report', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
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
                        color: AgroviaColors.primaryDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        res.cropName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.primaryDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: res.severity == 'Severe'
                            ? AgroviaColors.accentDanger.withValues(alpha: 0.15)
                            : AgroviaColors.accentWarning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      const Text('Overall Crop Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    radius: 12,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                '${res.healthScore.toInt()}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                      const Text('Affected Leaf Area', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    radius: 12,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                '${res.affectedAreaPct.toStringAsFixed(1)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                const Text('Agronomic Risk Radar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      dataSets: [
                        RadarDataSet(
                          fillColor: AgroviaColors.primary.withValues(alpha: 0.3),
                          borderColor: AgroviaColors.primaryDark,
                          entryRadius: 3,
                          dataEntries: res.radarMetrics.map((m) => RadarEntry(value: m.value)).toList(),
                          borderWidth: 2,
                        ),
                      ],
                      radarBorderData: const BorderSide(color: Colors.grey, width: 0.5),
                      gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
                      tickCount: 3,
                      getTitle: (index, angle) {
                        return RadarChartTitle(
                          text: res.radarMetrics[index].label,
                          angle: angle,
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
            labelColor: AgroviaColors.primaryDark,
            unselectedLabelColor: AgroviaColors.textSecondary,
            indicatorColor: AgroviaColors.primaryDark,
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

          // Ask Saanvi Floating Shortcut
          GlassContainer(
            surfaceColor: AgroviaColors.primaryLight,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AgroviaColors.primaryDark,
                  child: Icon(Icons.mic_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Have questions about this disease?', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Ask Saanvi in Hindi, Marathi, Telugu...', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onPressed: () {},
                ),
              ],
            ),
          ),
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
          Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (plan.dosage != null) ...[
            const SizedBox(height: 4),
            Text('Recommended Dosage: ${plan.dosage}', style: const TextStyle(fontWeight: FontWeight.w600, color: AgroviaColors.primaryDark, fontSize: 13)),
          ],
          const Divider(height: 20),
          ...plan.steps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${entry.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOrganic ? AgroviaColors.accentGreen.withValues(alpha: 0.1) : AgroviaColors.accentWarning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
