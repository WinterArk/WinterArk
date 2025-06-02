import 'package:flutter/material.dart';
import 'ui_helpers.dart';

class NeonButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color glowColor;
  final Color backgroundColor;
  final Color textColor;
  final Duration flashDuration;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.glowColor = Colors.blueAccent,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.flashDuration = const Duration(milliseconds: 500),
  });

  @override
  _NeonButtonState createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isFlashing = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed != null) setState(() => _isFlashing = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed != null) {
      widget.onPressed!();
      setState(() => _isFlashing = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) setState(() => _isFlashing = false);
  }

  @override
  Widget build(BuildContext context) {
    // Base glow: a gentle shadow always present
    final baseGlow = BoxShadow(
      color: widget.glowColor.withOpacity(1),
      blurRadius: 2,
      spreadRadius: 1,
    );

    // Flash glow: stronger, when pressed
    final flashGlow = BoxShadow(
      color: widget.glowColor.withOpacity(1),
      blurRadius: 24,
      spreadRadius: 12,
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: widget.flashDuration,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            baseGlow,
            if (_isFlashing) flashGlow,
          ],
        ),
        child: Text(
          widget.label,
          style: glowingTextStyle(
            widget.textColor,
            size: 12,
          ),
        ),
      ),
    );
  }
}
