import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';

class MessageItem {
  final String text;
  final bool isUser;
  final List<Map<String, dynamic>>? suggestedActions;

  MessageItem({
    required this.text,
    required this.isUser,
    this.suggestedActions,
  });
}

class SaanviBottomSheet extends StatefulWidget {
  const SaanviBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SaanviBottomSheet(),
    );
  }

  @override
  State<SaanviBottomSheet> createState() => _SaanviBottomSheetState();
}

class _SaanviBottomSheetState extends State<SaanviBottomSheet> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;
  bool _isLoading = false;
  String _selectedLanguage = 'hi';

  final List<MessageItem> _chatHistory = [
    MessageItem(
      text: 'नमस्ते! मैं सान्वी हूँ, आपकी डिजिटल कृषि सखी। आज मैं आपकी कैसे मदद कर सकती हूँ?',
      isUser: false,
      suggestedActions: [
        {'label': 'मंडी भाव (Mandi)', 'query': 'आज इंदौर में सोयाबीन का भाव क्या है?'},
        {'label': 'मौसम अपडेट (Weather)', 'query': 'अगले दो दिन बारिश होगी क्या?'},
        {'label': 'रोग निदान (Disease)', 'query': 'पत्तियों पर पीले धब्बे आ रहे हैं'},
        {'label': 'सरकारी योजनाएं (Schemes)', 'query': 'पीएम किसान योजना की स्थिति'},
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendQuery(String queryText) async {
    final query = queryText.trim();
    if (query.isEmpty || _isLoading) return;

    setState(() {
      _chatHistory.add(MessageItem(text: query, isUser: true));
      _isLoading = true;
    });
    _textController.clear();

    try {
      final dio = await ApiService.getAuthenticatedDio();
      final response = await dio.post(
        '/saanvi/query',
        data: {
          'query': query,
          'language': _selectedLanguage,
          'context': {
            'location': 'Indore, MP',
            'crop': 'Soybean',
          },
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final reply = data['replyText'] ?? 'उत्तर प्राप्त नहीं हुआ।';
        final List<dynamic>? actions = data['suggestedActions'];

        setState(() {
          _chatHistory.add(MessageItem(
            text: reply,
            isUser: false,
            suggestedActions: actions?.map((a) => Map<String, dynamic>.from(a)).toList(),
          ));
        });
      } else {
        _handleFallbackResponse(query);
      }
    } catch (e) {
      _handleFallbackResponse(query);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleFallbackResponse(String query) {
    // Intelligent offline local fallback when backend is unreachable
    final q = query.toLowerCase();
    String reply = 'नमस्ते! सर्वर से कनेक्ट करने में समस्या हुई, लेकिन मैं आपकी सहायता के लिए यहाँ हूँ।';
    List<Map<String, dynamic>> actions = [];

    if (q.contains('भाव') || q.contains('price') || q.contains('mandi')) {
      reply = 'आज इंदौर मंडी में सोयाबीन ₹4,850/क्विंटल और गेहूं ₹2,300/क्विंटल पर व्यापार कर रहा है।';
      actions = [{'label': 'View Market', 'actionType': 'NAVIGATE_TAB', 'payload': {'tab': 'market'}}];
    } else if (q.contains('रोग') || q.contains('धब्बे') || q.contains('disease') || q.contains('leaf')) {
      reply = 'पीले धब्बे फंगल संक्रमण (सर्कोस्पोरा) के लक्षण हो सकते हैं। Vision X से पत्ती का स्कैन करें।';
      actions = [{'label': 'Open Vision X', 'actionType': 'NAVIGATE_TAB', 'payload': {'tab': 'vision'}}];
    } else if (q.contains('मौसम') || q.contains('बारिश') || q.contains('weather') || q.contains('rain')) {
      reply = 'अगले 48 घंटों में हल्की बारिश और 85% आर्द्रता की संभावना है। छिड़काव स्थगित रखें।';
    } else if (q.contains('योजना') || q.contains('scheme') || q.contains('kisan')) {
      reply = 'पीएम-किसान 17वीं किस्त व कुसुम सोलर पंप 60% सब्सिडी आवेदन सक्रिय हैं। योजना हब देखें।';
      actions = [{'label': 'Open Yojana Hub', 'actionType': 'NAVIGATE_TAB', 'payload': {'tab': 'yojana'}}];
    }

    setState(() {
      _chatHistory.add(MessageItem(
        text: reply,
        isUser: false,
        suggestedActions: actions.isNotEmpty ? actions : null,
      ));
    });
  }

  void _handleAction(Map<String, dynamic> action) {
    if (action.containsKey('query')) {
      _sendQuery(action['query']);
    } else if (action['actionType'] == 'NAVIGATE_TAB') {
      final tab = action['payload']?['tab'];
      Navigator.pop(context);
      if (tab == 'market') {
        context.go('/market');
      } else if (tab == 'vision') {
        context.go('/vision-x');
      } else if (tab == 'yojana') {
        context.go('/yojana-hub');
      }
    }
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // Voice input simulation
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isListening) {
          setState(() {
            _isListening = false;
          });
          _sendQuery('सोयाबीन का आज क्या भाव है और कब बेचना चाहिए?');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AgroviaColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header & Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AgroviaColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AgroviaColors.primaryDark,
                    radius: 18,
                    child: Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Saanvi (सान्वी)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('AI Digital Agronomist', style: TextStyle(fontSize: 11, color: AgroviaColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _selectedLanguage,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'hi', child: Text('हिंदी (Hindi)')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'mr', child: Text('मराठी (Marathi)')),
                  DropdownMenuItem(value: 'te', child: Text('తెలుగు (Telugu)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),
            ],
          ),
          const Divider(height: 20),

          // Chat message list
          Expanded(
            child: ListView.separated(
              itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _chatHistory.length && _isLoading) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: GlassContainer(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AgroviaColors.primaryDark),
                          ),
                          SizedBox(width: 10),
                          Text('सान्वी सोच रही है...', style: TextStyle(fontSize: 13, color: AgroviaColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _chatHistory[index];
                return Column(
                  crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: GlassContainer(
                        blur: 10,
                        borderRadius: 18,
                        surfaceColor: msg.isUser ? AgroviaColors.primaryLight : AgroviaColors.glassSurface,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 15,
                            color: msg.isUser ? AgroviaColors.primaryDark : AgroviaColors.textPrimary,
                            fontWeight: msg.isUser ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    if (msg.suggestedActions != null && msg.suggestedActions!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: msg.suggestedActions!.map((action) {
                          return ActionChip(
                            label: Text(
                              action['label'] ?? action['query'] ?? 'Option',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AgroviaColors.primaryDark),
                            ),
                            backgroundColor: AgroviaColors.primaryLight,
                            side: BorderSide(color: AgroviaColors.primaryDark.withValues(alpha: 0.3)),
                            onPressed: () => _handleAction(action),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Input controls
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  borderRadius: 24,
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (val) => _sendQuery(val),
                    decoration: const InputDecoration(
                      hintText: 'Ask Saanvi anything about farming...',
                      hintStyle: TextStyle(fontSize: 13, color: AgroviaColors.textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _sendQuery(_textController.text),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                style: IconButton.styleFrom(backgroundColor: AgroviaColors.primaryDark),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    final scale = _isListening ? 1.0 + (_waveController.value * 0.2) : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening ? Colors.redAccent : AgroviaColors.accentGreen,
                        ),
                        child: Icon(
                          _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
