import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../theme/agrovia_theme.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;
  String? _errorMsg;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phone', // Assuming India
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _errorMsg = e.message ?? 'Verification failed';
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || _verificationId == null) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMsg = 'Invalid OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      // 1. Authenticate with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) throw Exception('Failed to retrieve Firebase ID token');

      // 2. Exchange with NestJS Backend
      // Fallback url for emulator/local dev
      final dio = Dio();
      final response = await dio.post('http://10.0.2.2:3000/auth/login', data: {
        'idToken': idToken,
      });

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['accessToken'];

        // 3. Save secure token
        const storage = FlutterSecureStorage();
        await storage.write(key: 'jwt_token', value: accessToken);

        // 4. Navigate to Home
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Backend login failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  // --- MOCK FLOW FOR DEV WITHOUT FIREBASE CREDENTIALS --- //
  Future<void> _mockBypass() async {
    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim().isEmpty ? '9999999999' : _phoneController.text.trim();
      final mockIdToken = 'mock.devuser123.+91$phone'; // Matches what AuthService expects

      final dio = Dio();
      final response = await dio.post('http://10.0.2.2:3000/auth/login', data: {
        'idToken': mockIdToken,
      });

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        const storage = FlutterSecureStorage();
        await storage.write(key: 'jwt_token', value: accessToken);
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Mock bypass failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login to Agrovia', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.agriculture_rounded, size: 80, color: AgroviaColors.primary),
              const SizedBox(height: 32),

              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorMsg!, style: TextStyle(color: Colors.red.shade800)),
                ),
                const SizedBox(height: 16),
              ],

              if (!_codeSent) ...[
                const Text('Enter Phone Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixText: '+91 ',
                    border: OutlineInputBorder(),
                    hintText: '99999 99999',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgroviaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Send OTP', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ] else ...[
                const Text('Enter OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '6-digit code',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgroviaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verify & Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],

              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: _isLoading ? null : _mockBypass,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Dev Bypass (Mock Token)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}