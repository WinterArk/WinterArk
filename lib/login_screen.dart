// lib/login_screen.dart
// ignore_for_file: use_build_context_synchronously, prefer_const_constructors,
//                 library_private_types_in_public_api, prefer_final_locals

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart' show sendTokenToBackend;
import 'api_service.dart';
import 'home_page.dart';
import 'verification_screen.dart';
import 'winterark_home.dart';
import 'dart:async'; // for unawaited
import 'package:firebase_messaging/firebase_messaging.dart'; // for FCM

class LoginScreen extends StatefulWidget {
  final bool isSignUp;
  const LoginScreen({super.key, required this.isSignUp});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _isSignUp = widget.isSignUp;

  final _nameCtrl        = TextEditingController();
  final _userOrEmailCtrl = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();

  bool _tosAccepted = false;
  bool _isLoading   = false;

  /// Store the id for `main.dart`
  Future<void> _persistUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', userId);
    print('🟢 saved currentUserId = $userId');
  }

  /* ─────────────────────────  SIGN‑UP  ───────────────────────── */

  void _showTosDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Please read and accept our Terms of Service to create an account.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _tosAccepted = true);
              Navigator.pop(context);
            },
            child: const Text('I Agree', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_tosAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the Terms of Service.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.signUp(
        _nameCtrl.text.trim(),
        _userOrEmailCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      final userId = res['user']['_id'] as String;
      await _persistUserId(userId);
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        unawaited(sendTokenToBackend(token));
      }


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created! Check your email for the verification code.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(
            email: _emailCtrl.text.trim(),
            userId: userId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /* ─────────────────────────  SIGN‑IN  ───────────────────────── */

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.signIn(
        _userOrEmailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      final userId = res['user']['_id'] as String;
      await _persistUserId(userId);
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        unawaited(sendTokenToBackend(token));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(userId: userId)),
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('verify')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account is not verified. Please check your email.',
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              email: _emailCtrl.text.trim(),
              userId: '', // unknown here
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /* ─────────────────────────  UI  ───────────────────────── */

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userOrEmailCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => WinterArkHome()),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'WinterArk',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFADD8E6),
                ),
              ),
              const SizedBox(height: 40),

              /* ───── SIGN‑UP specific fields ───── */
              if (_isSignUp) ...[
                _label('Enter Name'),
                _textField(_nameCtrl, 'Your name'),
                const SizedBox(height: 20),
                _label('Enter Email'),
                _textField(_emailCtrl, 'Your email'),
                const SizedBox(height: 20),
              ],

              _label(_isSignUp ? 'Enter Username' : 'Username or Email'),
              _textField(
                _userOrEmailCtrl,
                _isSignUp ? 'Your username' : 'Your username or email',
                key: const Key('login-username-email'),
              ),
              const SizedBox(height: 20),
              _label('Enter Password'),
              _textField(
                _passCtrl,
                'Your password',
                obscure: true,
                key: const Key('login-password'),
              ),
              const SizedBox(height: 10),

              if (_isSignUp)
                GestureDetector(
                  onTap: _showTosDialog,
                  child: const Text(
                    'By continuing, you agree to our Terms of Service.',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              ElevatedButton(
                key: const Key('login-button'),
                onPressed: _isLoading
                    ? null
                    : (_isSignUp ? _handleSignUp : _handleSignIn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFADD8E6),
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
                    : Text(
                  _isSignUp ? 'Create Account' : 'Log In',
                  style:
                  const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : "Don't have an account? Sign Up",
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /* helpers */
  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );

  Widget _textField(
      TextEditingController ctrl,
      String hint, {
        bool obscure = false,
        Key? key,
      }) =>
      TextField(
        key: key,
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: const OutlineInputBorder(),
        ),
      );
}
