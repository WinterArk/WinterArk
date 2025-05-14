import 'dart:async';

import 'package:flutter/material.dart';
import 'login_screen.dart';

class WinterArkHome extends StatefulWidget {
  const WinterArkHome({Key? key}) : super(key: key);

  @override
  State<WinterArkHome> createState() => _WinterArkHomeState();
}

class _WinterArkHomeState extends State<WinterArkHome> {
  final PageController _pageController = PageController();
  late final Timer _timer;

  int _currentPage = 0;
  final List<String> _backgroundImages = [
    'assets/images/frozen-fall-leaves-in-winter-free-image.webp',
    'assets/images/tiny-and-lonely-snowman-in-the-city-free-photo.png',
    'assets/images/heavy-snow-in-the-forest-free-image.webp',
    'assets/images/cute-bambi-in-snowy-forest-free-photo.png',
    'assets/images/small-village-in-a-snow-globe-free-image.webp',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _currentPage = (_currentPage + 1) % _backgroundImages.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // auto-scrolling background carousel
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _backgroundImages.length,
            itemBuilder: (context, index) => Image.asset(
              _backgroundImages[index],
              fit: BoxFit.cover,
            ),
          ),

          // dark overlay
          Container(color: const Color.fromRGBO(0, 0, 0, 0.45)),

          // foreground content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'WinterArk',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Frost icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.ac_unit, color: Color(0xFFADD8E6), size: 30),
                      SizedBox(width: 10),
                      Icon(Icons.ac_unit, color: Color(0xFFADD8E6), size: 40),
                      SizedBox(width: 10),
                      Icon(Icons.ac_unit, color: Color(0xFFADD8E6), size: 30),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tagline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'The frost bites, but you bite back harder. '
                      'Winter is your proving ground—where grit meets grind and legends are born. '
                      'While the world sleeps, you conquer.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            height: 1.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign up / Sign in buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAuthButton(
                        label: 'Sign up',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(isSignUp: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildAuthButton(
                        label: 'Sign in',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(isSignUp: false),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFADD8E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black)),
    );
  }
}
