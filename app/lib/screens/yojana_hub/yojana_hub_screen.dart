import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../theme/agrovia_theme.dart';

class YojanaHubScreen extends StatelessWidget {
  const YojanaHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yojana Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16.0),
            surfaceColor: AgroviaColors.primaryLight,
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Check Eligibility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AgroviaColors.primaryDark)),
                      SizedBox(height: 4),
                      Text('Answer 5 simple questions to see which schemes you qualify for.', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgroviaColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Start'),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Recommended Schemes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSchemeCard(
            'PM-KISAN Samman Nidhi',
            '₹6,000 / year direct benefit transfer for landholding farmers.',
            'Central Scheme',
            true,
          ),
          _buildSchemeCard(
            'Fasal Bima Yojana',
            'Crop insurance against natural calamities and pests.',
            'Insurance',
            false,
          ),
          _buildSchemeCard(
            'Kisan Credit Card (KCC)',
            'Short-term formal credit for seeds, fertilizers & machinery.',
            'Credit',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(String title, String desc, String category, bool isVerifiedEligible) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AgroviaColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(category, style: const TextStyle(fontSize: 10, color: AgroviaColors.primaryDark, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                if (isVerifiedEligible)
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: AgroviaColors.accentGreen),
                      SizedBox(width: 4),
                      Text('High Chance', style: TextStyle(fontSize: 12, color: AgroviaColors.accentGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
