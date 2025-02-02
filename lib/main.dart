// main.dart
import 'package:flutter/material.dart';
import 'winterark_home.dart';

void main() {
  runApp(WinterArkApp());
}

class WinterArkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WinterArk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
      ),
      home: WinterArkHome(),
    );
  }
}
