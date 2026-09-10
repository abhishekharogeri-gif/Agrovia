import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme/agrovia_theme.dart';

class YojanaHubScreen extends StatefulWidget {
  const YojanaHubScreen({super.key});

  @override
  State<YojanaHubScreen> createState() => _YojanaHubScreenState();
}

class _YojanaHubScreenState extends State<YojanaHubScreen> {
  List<Map<String, dynamic>> _schemes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSchemes();
  }

  Future<void> _fetchSchemes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = await ApiService.getAuthenticatedDio();
      final response = await dio.get('/yojana/schemes');
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          _schemes = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load schemes');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'योजनाएं लोड नहीं हो सकीं (Using offline data)';
        _schemes = _getLocalSchemes();
      });
    }
  }

  List<Map<String, dynamic>> _getLocalSchemes() {
    return [
      {
        'id': 'sch_pmkisan',
        'nameEn': 'PM-KISAN Samman Nidhi',
        'nameHi': 'प्रधानमंत्री किसान सम्मान निधि',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'benefitAmount': '₹6,000 / year',
        'category': 'FINANCIAL',
        'description': 'Income support to all landholding farmer families. Direct benefit transfer of ₹6,000/year in 3 installments.',
        'eligibilityCriteria': ['Must own cultivable land', 'Valid Aadhaar linked to bank account', 'Not an institutional landholder'],
        'requiredDocs': ['Aadhaar Card', 'Land Records (7/12)', 'Bank Passbook'],
        'applyUrl': 'https://pmkisan.gov.in',
      },
      {
        'id': 'sch_kusum',
        'nameEn': 'PM-KUSUM Solar Pump Scheme',
        'nameHi': 'प्रधानमंत्री कुसुम सोलर पंप योजना',
        'ministry': 'Ministry of New & Renewable Energy',
        'benefitAmount': '60% Govt Subsidy',
        'category': 'SOLAR_IRRIGATION',
        'description': 'Subsidy for stand-alone solar agriculture pumps and solarization of grid-connected pumps.',
        'eligibilityCriteria': ['Farmers having agricultural land with irrigation source'],
        'requiredDocs': ['Aadhaar Card', 'Land Ownership Records', 'Bank Details'],
        'applyUrl': 'https://pmkusum.mnre.gov.in',
      },
      {
        'id': 'sch_pmfby',
        'nameEn': 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
        'nameHi': 'प्रधानमंत्री फसल बीमा योजना',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'benefitAmount': '1.5% - 2% premium',
        'category': 'INSURANCE',
        'description': 'Insurance coverage for crop loss due to natural calamities, pests & diseases.',
        'eligibilityCriteria': ['All farmers growing notified crops in notified areas'],
        'requiredDocs': ['Sowing Certificate', 'Land Records', 'Aadhaar Card', 'Bank Account'],
        'applyUrl': 'https://pmfby.gov.in',
      },
      {
        'id': 'sch_kcc',
        'nameEn': 'Kisan Credit Card (KCC)',
        'nameHi': 'किसान क्रेडिट कार्ड',
        'ministry': ' NABARD / Reserve Bank of India',
        'benefitAmount': 'Credit limit up to ₹3 Lakhs',
        'category': 'FINANCIAL',
        'description': 'Short-term formal credit for seeds, fertilizers, pesticides and machinery at subsidized interest rates.',
        'eligibilityCriteria': ['All farmers - individual or joint owners', 'Tenant farmers, sharecroppers', 'Self Help Groups of farmers'],
        'requiredDocs': ['Aadhaar Card', 'Land Records', 'Passport Photo', 'Bank Account Details'],
        'applyUrl': 'https://www.pmjdy.pmjay.gov.in',
      },
    ];
  }

  void _showEligibilityCheck() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EligibilitySheet(
        onResult: (eligible) {
          // Filter schemes based on eligibility
          if (eligible.isNotEmpty) {
            setState(() {
              _schemes = _schemes.where((s) => eligible.contains(s['id'])).toList();
            });
          }
        },
      ),
    );
  }

  void _showSchemeDetails(Map<String, dynamic> scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SchemeDetailsSheet(scheme: scheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgroviaColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Yojana Hub', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AgroviaColors.textPrimary),
            onPressed: _fetchSchemes,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Eligibility Checker Card
          GlassContainer(
            padding: const EdgeInsets.all(16.0),
            surfaceColor: AgroviaColors.glassSurfaceDark,
            borderColor: AgroviaColors.glassBorderDark,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Check Eligibility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        'Answer 5 simple questions to see which schemes you qualify for.',
                        style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _showEligibilityCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgroviaColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: AgroviaColors.accentWarning, fontSize: 12, fontStyle: FontStyle.italic)),
            ),

          const Text('Recommended Schemes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
          const SizedBox(height: 12),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator(color: AgroviaColors.primary)),
            )
          else
            ..._schemes.map((s) => _buildSchemeCard(s)),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(Map<String, dynamic> scheme) {
    final category = scheme['category'] as String? ?? 'FINANCIAL';
    final categoryColor = _getCategoryColor(category);
    final categoryLabel = _getCategoryLabel(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => _showSchemeDetails(scheme),
        child: GlassContainer(
          surfaceColor: AgroviaColors.glassSurfaceDark,
          borderColor: AgroviaColors.glassBorderDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(categoryLabel, style: TextStyle(fontSize: 10, color: categoryColor, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Text(
                    scheme['benefitAmount'] ?? '',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AgroviaColors.accentGreen),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(scheme['nameEn'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                scheme['description'] ?? '',
                style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(scheme['ministry'] ?? '', style: const TextStyle(fontSize: 10, color: AgroviaColors.textSecondary))),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AgroviaColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'FINANCIAL': return AgroviaColors.accentGreen;
      case 'SOLAR_IRRIGATION': return AgroviaColors.accentWarning;
      case 'INSURANCE': return AgroviaColors.primary;
      case 'SOIL_FERTILIZER': return const Color(0xFFA78BFA);
      default: return AgroviaColors.primary;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'FINANCIAL': return '💰 Financial';
      case 'SOLAR_IRRIGATION': return '☀️ Solar / Irrigation';
      case 'INSURANCE': return '🛡️ Insurance';
      case 'SOIL_FERTILIZER': return '🌱 Soil & Fertilizer';
      default: return category;
    }
  }
}

class _EligibilitySheet extends StatefulWidget {
  final Function(List<String>) onResult;
  const _EligibilitySheet({required this.onResult});
  @override
  State<_EligibilitySheet> createState() => _EligibilitySheetState();
}

class _EligibilitySheetState extends State<_EligibilitySheet> {
  int _step = 0;
  bool? _hasLand;
  bool? _hasBankAccount;
  String _state = 'Madhya Pradesh';

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      final eligible = <String>[];
      if (_hasLand == true) eligible.addAll(['sch_pmkisan', 'sch_pmfby', 'sch_kcc']);
      if (_hasBankAccount == true) eligible.add('sch_kusum');
      widget.onResult(eligible.toSet().toList());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = [
      'क्या आपके नाम पर कृषि योग्य भूमि है? (Do you own agricultural land?)',
      'क्या आपका बैंक खाता आधार से जुड़ा है? (Is your bank account linked to Aadhaar?)',
      'आप किस राज्य से हैं? (Which state are you from?)',
      'आपकी कितनी जमीन है? (How much land do you own?)',
      'क्या आपने पहले किसी सरकारी योजना का लाभ लिया है? (Have you received govt scheme benefits before?)',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AgroviaColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AgroviaColors.glassBorderDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AgroviaColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Step ${_step + 1} of ${questions.length}', style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: (_step + 1) / questions.length, backgroundColor: AgroviaColors.glassSurfaceDark, color: AgroviaColors.primary),
          const SizedBox(height: 20),
          Text(questions[_step], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          if (_step == 2)
            DropdownButton<String>(
              value: _state,
              dropdownColor: AgroviaColors.backgroundDark,
              style: const TextStyle(color: AgroviaColors.textPrimary),
              items: ['Madhya Pradesh', 'Maharashtra', 'Rajasthan', 'Gujarat', 'Uttar Pradesh', 'Punjab', 'Haryana', 'Karnataka']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) { if (val != null) setState(() => _state = val); },
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () { _hasLand = true; _next(); }, style: ElevatedButton.styleFrom(backgroundColor: AgroviaColors.primary, foregroundColor: Colors.black87), child: const Text('हाँ / Yes')),
                const SizedBox(width: 16),
                OutlinedButton(onPressed: () { _hasLand = false; _next(); }, style: OutlinedButton.styleFrom(foregroundColor: AgroviaColors.textPrimary, side: const BorderSide(color: AgroviaColors.glassBorderDark)), child: const Text('नहीं / No')),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SchemeDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> scheme;
  const _SchemeDetailsSheet({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final docs = (scheme['requiredDocs'] as List<dynamic>?)?.map((d) => d.toString()).toList() ?? [];
    final criteria = (scheme['eligibilityCriteria'] as List<dynamic>?)?.map((d) => d.toString()).toList() ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AgroviaColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AgroviaColors.glassBorderDark)),
      ),
      child: ListView(
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AgroviaColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(scheme['nameEn'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
          const SizedBox(height: 4),
          Text(scheme['nameHi'] ?? '', style: const TextStyle(fontSize: 14, color: AgroviaColors.textSecondary)),
          const SizedBox(height: 8),
          Text(scheme['ministry'] ?? '', style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AgroviaColors.accentGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AgroviaColors.accentGreen.withValues(alpha: 0.3))),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AgroviaColors.accentGreen),
                const SizedBox(width: 8),
                Expanded(child: Text(scheme['benefitAmount'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.accentGreen))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
          const SizedBox(height: 6),
          Text(scheme['description'] ?? '', style: const TextStyle(fontSize: 14, color: AgroviaColors.textSecondary)),
          const SizedBox(height: 16),
          const Text('Eligibility Criteria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
          const SizedBox(height: 6),
          ...criteria.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 16, color: AgroviaColors.accentGreen),
                const SizedBox(width: 6),
                Expanded(child: Text(c, style: const TextStyle(fontSize: 13, color: AgroviaColors.textPrimary))),
              ],
            ),
          )),
          const SizedBox(height: 16),
          const Text('Required Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: docs.map((d) => Chip(
              label: Text(d, style: const TextStyle(fontSize: 11, color: AgroviaColors.textPrimary)),
              backgroundColor: AgroviaColors.glassSurfaceDark,
              side: const BorderSide(color: AgroviaColors.glassBorderDark),
            )).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Open official URL
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AgroviaColors.primary,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Apply on Official Website →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
