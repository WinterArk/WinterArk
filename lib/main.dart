import 'package:flutter/material.dart';  // Required for UI
import 'pages/homepage.dart';
import 'pages/landingpage.dart';
import 'pages/winter_ark_main.dart';

void main() {
  runApp(WinterArkApp());
}

class WinterArkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WinterArk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(),  // Show Landing Page First
      routes: {
        '/home': (context) => WinterArkHome(),
        '/main': (context) => WinterArkMain(),
      },
    );
  }
}

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
              Text(
                'WinterArk',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/main');  // Navigate to Home Page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFADD8E6),
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
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/main');  // Navigate to Home Page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFADD8E6),
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
                        style: TextStyle(color: Colors.black),
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
