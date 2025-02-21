// login_screen.dart
// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_page.dart';
import 'verification_screen.dart';
import 'winterark_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final bool isSignUp;
  const LoginScreen({Key? key, required this.isSignUp}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _isSignUp = widget.isSignUp;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameOrEmailController = TextEditingController();
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

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
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
      // 1) Make the signup API call
      final signUpResponse = await ApiService.signUp(
        _nameController.text.trim(),
        _usernameOrEmailController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2) Extract the user object from response and save userId to shared preferences
      final user = signUpResponse['user'];
      final newUserId = user['_id'] as String;
      await saveUserId(newUserId);

      // 3) Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Check your email for the verification code.'),
        ),
      );
      
      // 4) Navigate to VerificationScreen, passing both the email & the newly created userId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: _emailController.text.trim(),
            userId: newUserId,
          ),
        ),
      );
      // Save userId to shared preferences
      await saveUserId(user.id);
    } 
    catch (e) {
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
      // 1) Call signIn() and capture its JSON
      final responseData = await ApiService.signIn(
        _usernameOrEmailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2) Extract user object, then grab the _id and save userId to shared preferences
      final user = responseData['user'];
      final userId = user['_id'] as String;
      await saveUserId(userId);

      // 3) Notify success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully!')),
      );

      // 4) Pass userId to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userId: userId),
        ),
      );
    } 
    catch (e) {
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains("verify")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your account is not verified. Please check your email.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: _emailController.text.trim(),
              // userId is unknown in login error scenario, so you could pass an empty string or handle differently
              userId: '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameOrEmailController.dispose();
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
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => WinterArkHome()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'WinterArk',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFADD8E6)),
              ),
              const SizedBox(height: 40),
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
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _isSignUp ? 'Enter Username' : 'Username or Email',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('login-username-email'),
                controller: _usernameOrEmailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _isSignUp ? 'Your username' : 'Your username or email',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Enter Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('login-password'),
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
              if (_isSignUp)
                GestureDetector(
                  onTap: _showTosDialog,
                  child: const Text(
                    'By continuing, you agree to our Terms of Service.',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                key: const Key('login-button'),
                onPressed: _isLoading
                    ? null
                    : _isSignUp
                    ? _handleSignUp
                    : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFADD8E6),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
                    : Text(
                  _isSignUp ? 'Create Account' : 'Log In',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
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
