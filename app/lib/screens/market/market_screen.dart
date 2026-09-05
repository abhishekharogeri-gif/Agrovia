import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../theme/agrovia_theme.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandi Spot Rates', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Crops', true),
                _buildFilterChip('Soybean', false),
                _buildFilterChip('Wheat', false),
                _buildFilterChip('Maize', false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Field
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            borderRadius: 30,
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search mandi by district...',
                border: InputBorder.none,
                icon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Market List
          _buildMandiCard('Indore Mandi', 'Soybean (Yellow)', '₹4,850/q', '+₹50', true),
          _buildMandiCard('Khandwa Mandi', 'Soybean (Yellow)', '₹4,790/q', '-₹20', false),
          _buildMandiCard('Ujjain Mandi', 'Wheat (Lok-1)', '₹2,300/q', '+₹10', true),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: AgroviaColors.glassSurface,
        selectedColor: AgroviaColors.primaryLight,
        checkmarkColor: AgroviaColors.primaryDark,
        labelStyle: TextStyle(
          color: isSelected ? AgroviaColors.primaryDark : AgroviaColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMandiCard(String mandi, String crop, String price, String trend, bool isUp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mandi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUp ? AgroviaColors.accentGreen.withValues(alpha: 0.1) : AgroviaColors.accentDanger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                           size: 14, color: isUp ? AgroviaColors.accentGreen : AgroviaColors.accentDanger),
                      const SizedBox(width: 4),
                      Text(trend, style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUp ? AgroviaColors.accentGreen : AgroviaColors.accentDanger,
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(crop, style: const TextStyle(color: AgroviaColors.textSecondary)),
                Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
