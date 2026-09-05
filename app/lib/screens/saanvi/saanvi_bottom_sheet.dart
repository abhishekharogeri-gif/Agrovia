import 'package:flutter/material.dart';
import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';

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
  bool _isListening = false;
  final List<String> _chatHistory = [
    'नमस्ते! मैं सान्वी हूँ, आपकी कृषि सखी। आज मैं आपकी कैसे मदद कर सकती हूँ?',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (!_isListening) {
        // Mock processing user voice input
        _chatHistory.add('User: सोयाबीन का आज क्या भाव है?');
        _chatHistory.add('Saanvi: आज इंदौर मंडी में सोयाबीन का भाव ₹4,850/क्विंटल चल रहा है। आगामी 3 दिनों में तेजी की संभावना है।');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AgroviaColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AgroviaColors.textSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView.separated(
              reverse: true,
              itemCount: _chatHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                // Because list is reversed, 0 is the newest message
                final msg = _chatHistory.reversed.toList()[index];
                final isUser = msg.startsWith('User:');
                final text = isUser ? msg.substring(5).trim() : msg;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: GlassContainer(
                    blur: 10,
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? AgroviaColors.primaryDark : AgroviaColors.textPrimary,
                        fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Voice interaction area
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                final scale = _isListening ? 1.0 + (_waveController.value * 0.2) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AgroviaColors.primary, AgroviaColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AgroviaColors.primary.withValues(alpha: 0.5 + (_waveController.value * 0.3)),
                          blurRadius: _isListening ? 20 : 10,
                          spreadRadius: _isListening ? 4 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? 'Listening... Tap to stop' : 'Tap to speak (hi, mr, te, ta, en)',
            style: const TextStyle(color: AgroviaColors.textSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
