import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../theme/agrovia_theme.dart';

enum LoginState {
  idle,
  sendingOtp,
  otpSent,
  verifyingOtp,
  authenticated,
  error,
}

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  LoginState _loginState = LoginState.idle;
  String? _verificationId;
  int? _resendToken;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token != null && mounted) {
      context.go('/home');
    }
  }


  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _setState(LoginState state, {String? error}) {
    if (mounted) {
      setState(() {
        _loginState = state;
        if (error != null) _errorMsg = error;
      });
    }
  }

  String _normalizePhoneNumber(String rawValue) {
    String number = rawValue.replaceAll(RegExp(r'\D'), '');
    if (number.length == 10) {
      return '+91$number';
    }
    if (number.startsWith('91') && number.length == 12) {
      return '+$number';
    }
    return '+$number';
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Enter a valid phone number.';
      case 'too-many-requests':
      case 'quota-exceeded':
        return 'Too many OTP requests. Please try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Check your internet connection.';
      case 'invalid-verification-code':
        return 'The OTP is incorrect. Please try again.';
      case 'invalid-verification-id':
      case 'session-expired':
        return 'This OTP has expired. Request a new OTP.';
      case 'operation-not-allowed':
        return 'Phone authentication is disabled in configuration.';
      default:
        return 'Authentication failed: ${e.message ?? e.code}';
    }
  }

  Future<void> _verifyPhone({bool isResend = false}) async {
    if (_loginState == LoginState.sendingOtp) return;

    final phone = _normalizePhoneNumber(_phoneController.text.trim());
    if (phone.length < 10) {
      _setState(LoginState.error, error: 'Enter a valid phone number.');
      return;
    }

    _setState(LoginState.sendingOtp, error: null);
    _otpController.clear();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: isResend ? _resendToken : null,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (Android only)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setState(LoginState.error, error: _mapFirebaseError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _setState(LoginState.otpSent);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setState(LoginState.error, error: 'Unexpected error starting verification');
    }
  }

  Future<void> _verifyOtp() async {
    if (_loginState == LoginState.verifyingOtp) return;

    final enteredOtp = _otpController.text.trim();
    if (enteredOtp.isEmpty || _verificationId == null) {
       _setState(LoginState.error, error: 'Enter a valid OTP.');
       return;
    }

    _setState(LoginState.verifyingOtp, error: null);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: enteredOtp,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _setState(LoginState.error, error: _mapFirebaseError(e));
      _setState(LoginState.otpSent); // Revert to let them try typing again
    } catch (e) {
      _setState(LoginState.error, error: 'Failed to verify OTP.');
      _setState(LoginState.otpSent);
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    _setState(LoginState.verifyingOtp);

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken(true);

      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(code: 'internal-error', message: 'Failed to retrieve Firebase ID token');
      }

      // Exchange trusted Firebase ID token for Agrovia JWT session
      final dio = Dio();

      // Update with correct production/env base URL
      const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000');

      final response = await dio.post(
        '$baseUrl/auth/login',
        data: { 'idToken': idToken },
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) => status! < 500, // Handle 401/403 seamlessly
        )
      );

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['accessToken'];
        const storage = FlutterSecureStorage();
        await storage.write(key: 'jwt_token', value: accessToken);

        // Clear transaction state securely
        _verificationId = null;
        _resendToken = null;

        _setState(LoginState.authenticated);

        if (mounted) {
          context.go('/home');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw FirebaseAuthException(code: 'unauthorized', message: 'Server rejected authentication.');
      } else {
        throw FirebaseAuthException(code: 'server-error', message: 'Unknown server error.');
      }
    } on FirebaseAuthException catch (e) {
      _setState(LoginState.error, error: _mapFirebaseError(e));
      // Sign out from Firebase if backend negotiation failed
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _setState(LoginState.error, error: 'Backend login transaction failed.');
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy = _loginState == LoginState.sendingOtp || _loginState == LoginState.verifyingOtp;

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

              if (_loginState == LoginState.error && _errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorMsg!, style: TextStyle(color: Colors.red.shade800)),
                ),
                const SizedBox(height: 16),
              ],

              if (_loginState == LoginState.idle || _loginState == LoginState.sendingOtp || (_loginState == LoginState.error && _verificationId == null)) ...[
                const Text('Enter Phone Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !isBusy,
                  decoration: const InputDecoration(
                    prefixText: '+91 ',
                    border: OutlineInputBorder(),
                    hintText: '99999 99999',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isBusy ? null : () => _verifyPhone(isResend: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgroviaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isBusy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Send OTP', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ] else if (_loginState == LoginState.otpSent || _loginState == LoginState.verifyingOtp || (_loginState == LoginState.error && _verificationId != null)) ...[
                const Text('Enter OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  enabled: !isBusy,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '6-digit code',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isBusy ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgroviaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isBusy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verify & Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isBusy ? null : () => _verifyPhone(isResend: true),
                  child: const Text('Resend OTP'),
                ),
                TextButton(
                  onPressed: isBusy ? null : () {
                    _verificationId = null;
                    _resendToken = null;
                    _otpController.clear();
                    _setState(LoginState.idle);
                  },
                  child: const Text('Change Phone Number'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}