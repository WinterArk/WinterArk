import 'package:flutter/material.dart';
import 'homepage.dart'; // Import HomePage

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Landing Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to HomePage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: Text('Go to Home Page'),
        ),
      ),
    );
  }
}
