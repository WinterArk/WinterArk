import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

final blueGrotto = const Color.fromARGB(255, 45, 178, 250); 
final aquamarine = const Color.fromARGB(255, 167, 223, 248); 
final babyBlue   = const Color.fromARGB(255, 212, 242, 255);

void showShortFadeSnack(BuildContext context, String message) {
    Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: Colors.black87,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: glowingTextStyle(aquamarine, size: 16)
      ),
      // How long it stays visible
      duration: const Duration(seconds: 2),
      // How long the fade in/out takes
      animationDuration: const Duration(milliseconds: 300),
    ).show(context);
  }

  List<BoxShadow> glowShadows(Color c, {List<double> radii = const [4,8,16]}) =>
    radii.map((r)=>BoxShadow(
      color: c.withOpacity(0.6),
      blurRadius: r,
      spreadRadius: r/4,
  )).toList();

  Widget glowingIcon(IconData icon, Color color, double size) => Text(
    String.fromCharCode(icon.codePoint),
    style: TextStyle(
      fontFamily: icon.fontFamily,
      package: icon.fontPackage,
      fontSize: size,
      color: color,
      shadows: glowShadows(color, radii: [8,16,24]),
    ),
  );

  TextStyle glowingTextStyle(Color color, {double size=20}) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color,
    shadows: [
      ...glowShadows(color, radii: [8,16,24]),
      BoxShadow(color: color.withOpacity(0.3), blurRadius: 36),
    ],
  );

  InputDecoration inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: Colors.grey[900],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );

  InputDecoration glowingInput(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white70),
    filled: true, fillColor: Colors.grey[900],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
    ),
  );

  Widget iconTextField(TextEditingController ctl, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        prefixIcon: SizedBox(
          width: 24,
          height: 24,
          child: Center(child: glowingIcon(icon, babyBlue, 25)),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget neonPicker({ 
    required Widget icon, 
    required String label, 
    required VoidCallback onTap, 
    required Color glowColor 
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          boxShadow: glowShadows(glowColor, radii: [6,12,18]),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label, style: glowingTextStyle(glowColor, size: 14)),
          ],
        ),
      ),
    );
  }

  