// winterark_home.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';

class WinterArkHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App title
              Text(
                'WinterArk',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Snowflakes decoration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.ac_unit, color: Color(0xFFADD8E6), size: 30),
                  SizedBox(width: 10),
                  Icon(Icons.ac_unit, color: Color(0xFFADD8E6), size: 40),
                  SizedBox(width: 10),
                  Icon(Icons.ac_unit, color: Color(0xFFADD8E6), size: 30),
                ],
              ),
              SizedBox(height: 20),
              // Quote
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'The frost bites, but you bite back harder. Winter is your proving ground—where grit meets grind and legends are born. While the world sleeps, you conquer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Buttons for Sign up and Sign in
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen in sign-up mode.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(isSignUp: true),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFADD8E6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text('Sign up', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen in sign-in mode.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(isSignUp: false),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFADD8E6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text('Sign in', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
