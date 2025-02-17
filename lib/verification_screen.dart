// verification_screen.dart
// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_page.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String userId; // <-- Add userId to constructor so we can go directly to HomePage

  const VerificationScreen({
    super.key,
    required this.email,
    required this.userId,
  });

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _handleVerify() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 1) Attempt to verify on the backend
      await ApiService.verify(
        widget.email,
        _codeController.text.trim(),
      );

      // 2) If successful, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account verified successfully!')),
      );

      // 3) Navigate directly to HomePage, passing userId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userId: widget.userId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle resending verification code
  Future<void> _handleResendVerification() async {
    setState(() {
      _isResending = true;
    });
    try {
      await ApiService.resendVerification(widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend verification email: $e')),
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Enter the verification code sent to your email:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleVerify,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isResending ? null : _handleResendVerification,
              child: _isResending
                  ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
