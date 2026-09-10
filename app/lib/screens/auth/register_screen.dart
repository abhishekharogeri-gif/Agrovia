import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/password_requirement_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]'));
  }

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      setState(() => _error = 'Please fill all fields.');
      return;
    }

    if (!_isPasswordValid(pass)) {
      setState(() => _error = 'Password does not meet requirements.');
      return;
    }

    if (pass != confirmPass) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() { _busy = true; _error = null; });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final idToken = await cred.user?.getIdToken(true);
      if (idToken == null) throw FirebaseAuthException(code: 'no-token', message: 'No ID token');

      // Exchange for backend JWT
      const storage = FlutterSecureStorage();
      try {
        const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000');
        final dio = Dio();
        final resp = await dio.post(
          '$baseUrl/auth/login',
          data: {'idToken': idToken},
          options: Options(
            headers: {'Authorization': 'Bearer $idToken'},
            sendTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
            validateStatus: (s) => s! < 500,
          ),
        );
        if (resp.statusCode == 200 && resp.data != null) {
          await storage.write(key: 'jwt_token', value: resp.data['accessToken']);
        } else {
          await storage.write(key: 'jwt_token', value: 'offline_$idToken');
        }
      } catch (_) {
        await storage.write(key: 'jwt_token', value: 'offline_$idToken');
      }

      if (mounted) context.go('/onboarding/details');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _busy = false;
        _error = _mapError(e.code);
      });
    } catch (e) {
      setState(() { _busy = false; _error = 'Registration failed. Please try again.'; });
    }
  }

  String _mapError(String code) {
    if (code == 'email-already-in-use') return 'An account already exists for this email.';
    if (code == 'invalid-email') return 'Invalid email address.';
    if (code == 'weak-password') return 'Password is too weak.';
    return 'Registration failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgroviaColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/icons/agrovia_logo.png', width: 80, height: 80),
                ),
                const SizedBox(height: 16),
                const Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Join Agrovia to get started', style: TextStyle(fontSize: 14, color: AgroviaColors.textSecondary)),
                const SizedBox(height: 24),

                if (_error != null) ...[
                  GlassContainer(
                    surfaceColor: AgroviaColors.accentDanger.withValues(alpha: 0.15),
                    borderColor: AgroviaColors.accentDanger.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AgroviaColors.accentDanger, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: AgroviaColors.accentDanger, fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_busy,
                        style: const TextStyle(color: AgroviaColors.textPrimary),
                        decoration: _inputDeco('Email', Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        enabled: !_busy,
                        style: const TextStyle(color: AgroviaColors.textPrimary),
                        decoration: _inputDeco('Password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: AgroviaColors.textSecondary),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PasswordRequirementIndicator(password: _passCtrl.text),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPassCtrl,
                        obscureText: _obscureConfirmPass,
                        enabled: !_busy,
                        style: const TextStyle(color: AgroviaColors.textPrimary),
                        decoration: _inputDeco('Confirm Password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPass ? Icons.visibility_off : Icons.visibility, color: AgroviaColors.textSecondary),
                            onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _busy ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgroviaColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _busy
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: AgroviaColors.textSecondary, fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text('Sign In', style: TextStyle(color: AgroviaColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AgroviaColors.textSecondary),
      prefixIcon: Icon(icon, color: AgroviaColors.textSecondary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AgroviaColors.glassBorderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AgroviaColors.primary)),
    );
  }
}
