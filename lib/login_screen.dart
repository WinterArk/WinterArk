// login_screen.dart
import 'package:flutter/material.dart';
import 'api_service.dart'; // Make sure this file exists and is set up.
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  final bool isSignUp;
  const LoginScreen({Key? key, required this.isSignUp}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Initialize local mode from the widget parameter.
  late bool _isSignUp = widget.isSignUp;

  // Controllers for the input fields.
  final TextEditingController _nameController = TextEditingController(); // Only for sign-up.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _tosAccepted = false;
  bool _isLoading = false;

  void _showTosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              setState(() {
                _tosAccepted = true;
              });
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

    setState(() {
      _isLoading = true;
    });
    try {
      await ApiService.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await ApiService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
              const SizedBox(height: 40),
              const Text(
                'WinterArk',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFADD8E6)),
              ),
              const SizedBox(height: 40),
              // Name field (only for sign-up).
              if (_isSignUp) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Enter Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Your name',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Email field.
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Enter Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Your email',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Password field.
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Enter Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Your password',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // In sign-up mode, show the TOS link.
              if (_isSignUp)
                GestureDetector(
                  onTap: _showTosDialog,
                  child: const Text(
                    'By continuing, you agree to our Terms of Service.',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              const SizedBox(height: 20),
              // Continue button: calls sign-up or sign-in handler.
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _isSignUp ? _handleSignUp : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFADD8E6),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
                    : Text(_isSignUp ? 'Create Account' : 'Log In',
                    style: const TextStyle(color: Colors.black, fontSize: 16)),
              ),
              const SizedBox(height: 20),
              // Toggle between sign in and sign up.
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
