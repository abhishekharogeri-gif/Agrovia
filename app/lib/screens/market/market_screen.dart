import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme/agrovia_theme.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  List<Map<String, dynamic>> _prices = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _filters = ['All', 'Soybean', 'Wheat', 'Cotton', 'Onion', 'Maize'];

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = await ApiService.getAuthenticatedDio();
      final response = await dio.get('/market/prices');
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          _prices = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load mandi prices');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'मंडी भाव अभी उपलब्ध नहीं हैं (Live feed unreachable)';
        // Fallback to locally available mock data
        _prices = _getLocalMockPrices();
      });
    }
  }

  List<Map<String, dynamic>> _getLocalMockPrices() {
    return [
      {
        'commodity': 'Soybean',
        'variety': 'Yellow',
        'marketCenter': 'Indore',
        'state': 'Madhya Pradesh',
        'modalPrice': 4850,
        'minPrice': 4700,
        'maxPrice': 4950,
        'trend': 'UP',
        'trendPercentage': 3.2,
        'arrivalDate': DateTime.now().toString().split('T')[0],
      },
      {
        'commodity': 'Cotton',
        'variety': 'BT',
        'marketCenter': 'Guntur',
        'state': 'Andhra Pradesh',
        'modalPrice': 7150,
        'minPrice': 6800,
        'maxPrice': 7400,
        'trend': 'DOWN',
        'trendPercentage': 1.2,
        'arrivalDate': DateTime.now().toString().split('T')[0],
      },
      {
        'commodity': 'Onion',
        'variety': 'Red',
        'marketCenter': 'Lasalgaon',
        'state': 'Maharashtra',
        'modalPrice': 1820,
        'minPrice': 1500,
        'maxPrice': 2100,
        'trend': 'UP',
        'trendPercentage': 5.4,
        'arrivalDate': DateTime.now().toString().split('T')[0],
      },
      {
        'commodity': 'Wheat',
        'variety': 'Sharbati',
        'marketCenter': 'Sehore',
        'state': 'Madhya Pradesh',
        'modalPrice': 2950,
        'minPrice': 2800,
        'maxPrice': 3200,
        'trend': 'STABLE',
        'trendPercentage': 0,
        'arrivalDate': DateTime.now().toString().split('T')[0],
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredPrices {
    return _prices.where((p) {
      final matchFilter = _selectedFilter == 'All' || (p['commodity'] as String).toLowerCase() == _selectedFilter.toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          (p['marketCenter'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p['commodity'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandi Spot Rates', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchPrices,
            tooltip: 'Refresh Rates',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((label) {
                final isSelected = _selectedFilter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedFilter = label),
                    backgroundColor: AgroviaColors.glassSurface,
                    selectedColor: AgroviaColors.primaryLight,
                    checkmarkColor: AgroviaColors.primaryDark,
                    labelStyle: TextStyle(
                      color: isSelected ? AgroviaColors.primaryDark : AgroviaColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Search Field
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            borderRadius: 30,
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search mandi, crop, or district...',
                border: InputBorder.none,
                icon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic)),
            ),

          // Mandi list
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredPrices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: Text('No matching commodities found.')),
            )
          else
            ..._filteredPrices.map((p) => _buildMandiCard(p)),
        ],
      ),
    );
  }

  Widget _buildMandiCard(Map<String, dynamic> p) {
    final trend = p['trend'] as String? ?? 'STABLE';
    final isUp = trend == 'UP';
    final isDown = trend == 'DOWN';
    final trendPct = (p['trendPercentage'] as num?)?.toDouble() ?? 0.0;
    final commodity = p['commodity'] as String? ?? 'Unknown';
    final variety = p['variety'] as String? ?? '';
    final market = p['marketCenter'] as String? ?? 'Unknown';
    final state = p['state'] as String? ?? '';
    final modalPrice = p['modalPrice'] as num? ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$commodity ($variety)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('$market Mandi • $state', style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUp
                        ? AgroviaColors.accentGreen.withValues(alpha: 0.15)
                        : isDown
                            ? AgroviaColors.accentDanger.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp ? Icons.arrow_upward_rounded : isDown ? Icons.arrow_downward_rounded : Icons.remove_rounded,
                        size: 14,
                        color: isUp ? AgroviaColors.accentGreen : isDown ? AgroviaColors.accentDanger : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trendPct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUp ? AgroviaColors.accentGreen : isDown ? AgroviaColors.accentDanger : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Modal Price', style: TextStyle(fontSize: 10, color: AgroviaColors.textSecondary)),
                    Text('₹${modalPrice.toStringAsFixed(0)}/q', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Min - Max', style: TextStyle(fontSize: 10, color: AgroviaColors.textSecondary)),
                    Text(
                      '₹${p['minPrice']} - ₹${p['maxPrice']}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
