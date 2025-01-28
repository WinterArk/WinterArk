import 'package:flutter/material.dart';
 
void main() {
  runApp(WinterArkApp());
}
 
class WinterArkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
 
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top bar with "Cancel" and "X"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Handle cancel action
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white, // White text for visibility
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Handle close action
                    },
                    icon: Icon(Icons.close, color: Colors.white), // White icon
                  ),
                ],
              ),
              SizedBox(height: 20),
              // App title
              Text(
                'WinterArk',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFADD8E6), // Light blue color
                ),
              ),
              SizedBox(height: 40),
              // Email input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.white), // White input text
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADD8E6)), // Light blue border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADD8E6)), // Light blue border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADD8E6)), // Light blue border
                  ),
                  isDense: true, // Reduce height
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.white54), // Greyish hint
                ),
              ),
              SizedBox(height: 20),
              // Password input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                obscureText: true,
                style: TextStyle(color: Colors.white), // White input text
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADD8E6)), // Light blue border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADD8E6)), // Light blue border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADD8E6)), // Light blue border
                  ),
                  isDense: true, // Reduce height
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.white54), // Greyish hint
                ),
              ),
              SizedBox(height: 10),
              // Remember me and Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: false, // Default unchecked
                        onChanged: (bool? value) {
                          // Handle checkbox state
                        },
                        checkColor: Colors.black, // Checkbox tick color
                        activeColor: Color(0xFFADD8E6), // Light blue checkbox color
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(color: Colors.white), // White text
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFFADD8E6), // Light blue text
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Continue button
              ElevatedButton(
                onPressed: () {
                  // Handle continue action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFADD8E6), // Light blue background
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(color: Colors.black, fontSize: 16), // Black text for contrast
                ),
              ),
              SizedBox(height: 20),
              // Footer text
              Text(
                'By continuing, you agree to our Terms of Service, Privacy Policy, and Cookie Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white, // White text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}