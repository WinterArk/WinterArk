
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Set dark background
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // WinterArk Title
              Text(
                'WinterArk',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,  // Restore blue title
                ),
              ),
              SizedBox(height: 20),
              // Snowflake Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.ac_unit, color: Colors.blue, size: 30),
                  SizedBox(width: 10),
                  Icon(Icons.ac_unit, color: Colors.blue, size: 40),
                  SizedBox(width: 10),
                  Icon(Icons.ac_unit, color: Colors.blue, size: 30),
                ],
              ),
              SizedBox(height: 20),
              // Motivational Quote
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'The frost bites, but you bite back harder. '
                  'Winter is your proving ground—where grit meets grind and legends are born. '
                  'While the world sleeps, you conquer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Sign Up & Sign In Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/main');  // Go to Home Page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,  // Restore blue button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        'Sign up',
                        style: TextStyle(color: Colors.white),  // White text
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/main');  // Go to Home Page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,  // Restore blue button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(color: Colors.white),  // White text
                      ),
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
