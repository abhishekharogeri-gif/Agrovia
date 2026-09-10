import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email address.');
      return;
    }
    setState(() { _busy = true; _error = null; });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() { _busy = false; _sent = true; });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _busy = false;
        _error = e.code == 'user-not-found'
            ? 'No account found with this email.'
            : 'Failed to send reset email. Try again.';
      });
    } catch (_) {
      setState(() { _busy = false; _error = 'Something went wrong.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgroviaColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AgroviaColors.textPrimary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.lock_reset_rounded, size: 64, color: AgroviaColors.primary),
                const SizedBox(height: 16),
                const Text('Reset Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email and we\'ll send a reset link.',
                  style: TextStyle(color: AgroviaColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (_sent) ...[
                  GlassContainer(
                    surfaceColor: AgroviaColors.accentGreen.withValues(alpha: 0.15),
                    borderColor: AgroviaColors.accentGreen.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AgroviaColors.accentGreen, size: 40),
                        SizedBox(height: 8),
                        Text('Reset link sent! Check your inbox.', style: TextStyle(color: AgroviaColors.accentGreen, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to Login', style: TextStyle(color: AgroviaColors.primary)),
                  ),
                ] else ...[
                  if (_error != null) ...[
                    GlassContainer(
                      surfaceColor: AgroviaColors.accentDanger.withValues(alpha: 0.15),
                      borderColor: AgroviaColors.accentDanger.withValues(alpha: 0.4),
                      padding: const EdgeInsets.all(12),
                      child: Text(_error!, style: const TextStyle(color: AgroviaColors.accentDanger, fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_busy,
                          style: const TextStyle(color: AgroviaColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: AgroviaColors.textSecondary),
                            prefixIcon: const Icon(Icons.email_outlined, color: AgroviaColors.textSecondary),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AgroviaColors.primary)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _sendReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AgroviaColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _busy
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
