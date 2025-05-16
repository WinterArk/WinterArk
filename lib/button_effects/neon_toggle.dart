import 'package:flutter/material.dart';

class NeonToggle extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color glowColor;
  final Color activeColor;
  final Color inactiveTrackColor;
  final Duration flashDuration;

  const NeonToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.glowColor = Colors.blueAccent,
    this.activeColor = Colors.lightBlueAccent,
    this.inactiveTrackColor = Colors.grey,
    this.flashDuration = const Duration(milliseconds: 300),
  });

  @override
  _NeonToggleState createState() => _NeonToggleState();
}

class _NeonToggleState extends State<NeonToggle> {
  bool _isFlashing = false;

  void _handleChanged(bool v) {
    widget.onChanged(v);
    setState(() => _isFlashing = true);

    Future.delayed(widget.flashDuration, () {
      if (!mounted) return;
      setState(() => _isFlashing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(width: 12),
        AnimatedContainer(
          duration: widget.flashDuration,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (widget.value)
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              if (_isFlashing) ...[
                BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 16, spreadRadius: 4),
                BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 32, spreadRadius: 8),
              ],
            ],
          ),
          child: Switch(
            value: widget.value,
            activeColor: widget.activeColor,
            activeTrackColor: widget.activeColor.withOpacity(0.3),
            inactiveTrackColor: widget.inactiveTrackColor,
            onChanged: _handleChanged,
          ),
        ),
      ],
    );
  }
}
