import 'package:flutter/material.dart';
import 'landingpage.dart'; // Import the LandingPage file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(), // Start with the Landing Page
    );
  }
}


