import 'package:flutter/material.dart';

class LandingButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const LandingButton({ required this.onTap, required this.child });

  @override
  _LandingButtonState createState() => _LandingButtonState();
}

class _LandingButtonState extends State<LandingButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
