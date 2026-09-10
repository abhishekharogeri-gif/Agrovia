import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token != null && mounted) context.go('/home');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter email and password.');
      return;
    }
    setState(() { _busy = true; _error = null; });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final idToken = await cred.user?.getIdToken(true);
      if (idToken == null) throw FirebaseAuthException(code: 'no-token', message: 'No ID token');

      // Exchange for backend JWT (graceful fallback if backend unreachable)
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

      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _busy = false;
        _error = _mapError(e.code);
      });
    } catch (e) {
      setState(() { _busy = false; _error = 'Login failed. Please try again.'; });
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found. Please register first.';
      case 'wrong-password': return 'Incorrect password.';
      case 'invalid-email': return 'Invalid email address.';
      case 'user-disabled': return 'This account has been disabled.';
      case 'too-many-requests': return 'Too many attempts. Try again later.';
      case 'invalid-credential': return 'Invalid email or password.';
      default: return 'Authentication failed. Please try again.';
    }
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
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/icons/agrovia_logo.png', width: 90, height: 90),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sign in to continue to Agrovia',
                  style: TextStyle(fontSize: 14, color: AgroviaColors.textSecondary),
                ),
                const SizedBox(height: 32),

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
                        obscureText: _obscure,
                        enabled: !_busy,
                        style: const TextStyle(color: AgroviaColors.textPrimary),
                        onSubmitted: (_) => _login(),
                        decoration: _inputDeco('Password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AgroviaColors.textSecondary),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _busy ? null : () => context.go('/forgot-password'),
                          child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: AgroviaColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _busy ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgroviaColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _busy
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AgroviaColors.textSecondary, fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: const Text('Register', style: TextStyle(color: AgroviaColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
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
