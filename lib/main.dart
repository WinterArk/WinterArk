// main.dart
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'winterark_home.dart';

void main() {
  // Initialize time zone data
  tz.initializeTimeZones();
  runApp(const WinterArkApp());
}

class WinterArkApp extends StatelessWidget {
  const WinterArkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WinterArk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
      ),
      home: const WinterArkHome(),
    );
  }
}
