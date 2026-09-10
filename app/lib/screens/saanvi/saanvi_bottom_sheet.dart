import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/language_provider.dart';
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

class SaanviBottomSheet extends ConsumerStatefulWidget {
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
  ConsumerState<SaanviBottomSheet> createState() => _SaanviBottomSheetState();
}

class _SaanviBottomSheetState extends ConsumerState<SaanviBottomSheet> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool _isListening = false;
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _sttAvailable = false;

  final List<MessageItem> _chatHistory = [
    MessageItem(
      text: 'Hello! I am Saanvi, your digital agricultural companion. How can I help you today?',
      isUser: false,
      suggestedActions: [
        {'label': 'Mandi Prices', 'query': 'What is the price of Soybean in Indore today?'},
        {'label': 'Weather', 'query': 'Will it rain in the next two days?'},
        {'label': 'Disease Diagnosis', 'query': 'There are yellow spots appearing on leaves'},
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _sttAvailable = await _stt.initialize(onError: (_) {}, onStatus: (_) {});
    } catch (_) {
      _sttAvailable = false;
    }
  }

  void _toggleListening() {
    if (_isLoading) return;
    if (_isListening) {
      _stt.stop();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    if (_sttAvailable) {
      _stt.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() => _isListening = false);
            if (result.recognizedWords.trim().isNotEmpty) _sendQuery(result.recognizedWords);
          }
        },
      );
    }
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
      final currentLang = ref.read(languageProvider);
      final response = await dio.post(
        '/saanvi/query',
        data: {'query': query, 'language': currentLang},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final reply = data['replyText'] ?? 'मैं समझ नहीं पाई, कृपया फिर से बोलें।';
        final List<dynamic>? actions = data['suggestedActions'];
        setState(() {
          _chatHistory.add(MessageItem(
            text: reply,
            isUser: false,
            suggestedActions: actions?.map((a) => Map<String, dynamic>.from(a)).toList(),
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatHistory.add(MessageItem(
            text: 'Sorry, unable to connect to server. Please check your internet connection and try again.',
            isUser: false,
          ));
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAction(Map<String, dynamic> action) {
    if (action['query'] != null) {
      _sendQuery(action['query'] as String);
      return;
    }

    final actionType = action['actionType'] as String?;
    final payload = action['payload'];

    if (actionType == 'NAVIGATE_TAB') {
      final tab = payload is Map ? payload['tab'] : null;
      Navigator.pop(context);
      if (tab == 'market') {
        context.go('/market');
      } else if (tab == 'vision') {
        context.go('/vision-x');
      } else if (tab == 'yojana') {
        context.go('/yojana-hub');
      } else if (tab == 'connect') {
        context.go('/connect');
      } else {
        context.go('/home');
      }
      return;
    }

    if (action['label'] != null) {
      _sendQuery(action['label'] as String);
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AgroviaColors.backgroundDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AgroviaColors.glassBorderDark, width: 1)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AgroviaColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, color: AgroviaColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AgroviaColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AgroviaColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AgroviaColors.glassBorderDark),
            Expanded(
              child: ListView.builder(
                itemCount: kSupportedLanguages.length,
                itemBuilder: (context, index) {
                  final lang = kSupportedLanguages[index];
                  final isSelected = ref.watch(languageProvider) == lang.code;
                  return ListTile(
                    title: Text(
                      lang.name,
                      style: TextStyle(
                        color: isSelected ? AgroviaColors.primary : AgroviaColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      lang.nativeName,
                      style: TextStyle(
                        color: isSelected ? AgroviaColors.primary.withValues(alpha: 0.8) : AgroviaColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AgroviaColors.primary)
                        : null,
                    onTap: () {
                      ref.read(languageProvider.notifier).setLanguage(lang.code);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLangCode = ref.watch(languageProvider);
    final currentLang = kSupportedLanguages.firstWhere(
      (l) => l.code == currentLangCode,
      orElse: () => kSupportedLanguages.first,
    );
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AgroviaColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AgroviaColors.glassBorderDark, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(width: 44, height: 5, decoration: BoxDecoration(color: AgroviaColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3))),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AgroviaColors.glassSurface, borderRadius: BorderRadius.circular(16)),
                  child: Image.asset('assets/icons/saanvi.png', width: 40, height: 40),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saanvi AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AgroviaColors.textPrimary)),
                    Text('Digital Agri-Assistant', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: _showLanguagePicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AgroviaColors.glassSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AgroviaColors.glassBorderDark),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language_rounded, size: 16, color: AgroviaColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          currentLang.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AgroviaColors.textPrimary,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18, color: AgroviaColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _chatHistory.length && _isLoading) {
                  return const Align(alignment: Alignment.centerLeft, child: Text('Saanvi is thinking...', style: TextStyle(color: AgroviaColors.textSecondary)));
                }
                final msg = _chatHistory[index];
                return Column(
                  crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: GlassContainer(
                        surfaceColor: msg.isUser ? AgroviaColors.primary.withValues(alpha: 0.2) : AgroviaColors.glassSurface,
                        borderColor: msg.isUser ? AgroviaColors.primary : AgroviaColors.glassBorderDark,
                        padding: const EdgeInsets.all(14),
                        child: Text(msg.text, style: const TextStyle(color: AgroviaColors.textPrimary)),
                      ),
                    ),
                    if (!msg.isUser && msg.suggestedActions != null && msg.suggestedActions!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: msg.suggestedActions!.map((act) {
                          return ActionChip(
                            label: Text(
                              act['label'] ?? '',
                              style: const TextStyle(fontSize: 12, color: AgroviaColors.primary, fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AgroviaColors.glassSurface,
                            side: BorderSide(color: AgroviaColors.glassBorderDark),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onPressed: () => _handleAction(act),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: AgroviaColors.textPrimary),
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Ask Saanvi...', hintStyle: TextStyle(color: AgroviaColors.textSecondary)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _toggleListening, icon: Icon(_isListening ? Icons.mic_off_rounded : Icons.mic_rounded), style: IconButton.styleFrom(backgroundColor: AgroviaColors.primary)),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: () => _sendQuery(_textController.text), icon: const Icon(Icons.send), style: IconButton.styleFrom(backgroundColor: AgroviaColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
