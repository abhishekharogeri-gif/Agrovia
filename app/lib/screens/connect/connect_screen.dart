import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme/agrovia_theme.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  List<Map<String, dynamic>> _feed = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = await ApiService.getAuthenticatedDio();
      final response = await dio.get('/connect/feed');
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          _feed = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Feed unreachable — showing local data';
        _feed = _getLocalFeed();
      });
    }
  }

  List<Map<String, dynamic>> _getLocalFeed() {
    return [
      {
        'id': 'post_1',
        'authorName': 'Ramesh Patel',
        'authorDistrict': 'Indore',
        'authorSpecialty': 'Soybean Specialist',
        'isExpert': true,
        'content': 'एफिड्स से बचाव के लिए नीम तेल का छिड़काव सुबह 6-8 बजे करें। बाद में करने से मधुमक्खियों को नुकसान होता है।',
        'likes': 24,
        'comments': 5,
        'timestamp': '2h ago',
        'isLiked': false,
      },
      {
        'id': 'post_2',
        'authorName': 'Suresh Sharma',
        'authorDistrict': 'Dewas',
        'authorSpecialty': 'Organic Wheat',
        'isExpert': false,
        'content': 'गेहूं की बुवाई इस हफ्ते शुरू कर देनी चाहिए। मिट्टी की नमी सही है।',
        'likes': 18,
        'comments': 3,
        'timestamp': '4h ago',
        'isLiked': false,
      },
      {
        'id': 'post_3',
        'authorName': 'Dr. Alok Verma',
        'authorDistrict': 'KVK Bhopal',
        'authorSpecialty': 'KVK Agronomist (Verified)',
        'isExpert': true,
        'content': 'PM-KISAN 17th installment will be released by 15th September. Ensure your Aadhaar is linked to bank account and land records are updated.',
        'likes': 56,
        'comments': 12,
        'timestamp': '6h ago',
        'isLiked': false,
      },
      {
        'id': 'post_4',
        'authorName': 'Lakshmi Devi',
        'authorDistrict': 'Vidisha',
        'authorSpecialty': 'Vegetable Farmer',
        'isExpert': false,
        'content': 'टमाटर में लीफ कर्ल वायरस का खतरा बढ़ रहा है। सफेद मक्खी नियंत्रण जरूरी है।',
        'likes': 31,
        'comments': 7,
        'timestamp': '1d ago',
        'isLiked': true,
      },
    ];
  }

  void _toggleLike(int index) {
    setState(() {
      final post = _feed[index];
      final wasLiked = post['isLiked'] as bool? ?? false;
      post['isLiked'] = !wasLiked;
      post['likes'] = (post['likes'] as int? ?? 0) + (wasLiked ? -1 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgroviaColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Kisan Connect', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AgroviaColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Connect: Coming soon — share your Farmer Card!'), duration: Duration(seconds: 2)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AgroviaColors.textPrimary),
            onPressed: _fetchFeed,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AgroviaColors.primary,
        backgroundColor: AgroviaColors.backgroundDark,
        onRefresh: _fetchFeed,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // QR Exchange Banner
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              surfaceColor: AgroviaColors.glassSurfaceDark,
              borderColor: AgroviaColors.glassBorderDark,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AgroviaColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, size: 32, color: AgroviaColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Share Your Farmer Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AgroviaColors.primary)),
                        SizedBox(height: 4),
                        Text('Connect with local farmers & verified experts instantly.', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: AgroviaColors.primary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share your Farmer Card with nearby farmers!'), duration: Duration(seconds: 2)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Community Feed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
            const SizedBox(height: 8),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: AgroviaColors.accentWarning, fontSize: 12, fontStyle: FontStyle.italic)),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator(color: AgroviaColors.primary)),
              )
            else if (_feed.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: Text('No posts yet. Be the first to share!', style: TextStyle(color: AgroviaColors.textSecondary))),
              )
            else
              ..._feed.asMap().entries.map((e) => _buildPostCard(e.value, e.key)),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AgroviaColors.primary,
        onPressed: () => _showCreatePost(),
        child: const Icon(Icons.edit_rounded, color: Colors.black87),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    final isExpert = post['isExpert'] as bool? ?? false;
    final isLiked = post['isLiked'] as bool? ?? false;
    final likes = post['likes'] as int? ?? 0;
    final comments = post['comments'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: isExpert ? AgroviaColors.accentGreen : AgroviaColors.primaryDark,
                      child: Text(
                        (post['authorName'] as String? ?? 'U')[0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isExpert)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: AgroviaColors.backgroundDark, shape: BoxShape.circle),
                          child: const Icon(Icons.verified_rounded, size: 12, color: AgroviaColors.accentGreen),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post['authorName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AgroviaColors.textPrimary)),
                          if (isExpert) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AgroviaColors.accentGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Expert', style: TextStyle(fontSize: 9, color: AgroviaColors.accentGreen, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${post['authorDistrict']} • ${post['authorSpecialty']}',
                        style: const TextStyle(fontSize: 11, color: AgroviaColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(post['timestamp'] ?? '', style: const TextStyle(fontSize: 11, color: AgroviaColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),

            // Post content
            Text(
              post['content'] ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5, color: AgroviaColors.textPrimary),
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                InkWell(
                  onTap: () => _toggleLike(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: isLiked ? Colors.redAccent : AgroviaColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text('$likes', style: TextStyle(fontSize: 12, color: isLiked ? Colors.redAccent : AgroviaColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${post['authorName']}: ${post['content']?.toString().substring(0, 30) ?? ""}...')),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AgroviaColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('$comments', style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18, color: AgroviaColors.textSecondary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share post with fellow farmers!'), duration: Duration(seconds: 2)),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePost() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        decoration: const BoxDecoration(
          color: AgroviaColors.backgroundDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AgroviaColors.glassBorderDark)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AgroviaColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Share with the Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AgroviaColors.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: AgroviaColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Share your farming tip, question, or update...',
                hintStyle: const TextStyle(color: AgroviaColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AgroviaColors.glassBorderDark)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AgroviaColors.glassBorderDark)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AgroviaColors.primary)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() {
                      _feed.insert(0, {
                        'id': 'post_new_${DateTime.now().millisecondsSinceEpoch}',
                        'authorName': 'You',
                        'authorDistrict': 'Indore',
                        'authorSpecialty': 'Agrovia User',
                        'isExpert': false,
                        'content': controller.text.trim(),
                        'likes': 0,
                        'comments': 0,
                        'timestamp': 'Just now',
                        'isLiked': false,
                      });
                    });
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgroviaColors.primary,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
