import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color glowColor;
  final Color backgroundColor;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.glowColor        = Colors.blueAccent,
    this.backgroundColor  = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            // static neon glow
            BoxShadow(
              color: glowColor.withOpacity(1),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,   
            color: glowColor,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: glowColor,
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}