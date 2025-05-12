import 'package:flutter/material.dart';

class PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  const PulsingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 32,
  });

  @override
  _PulsingIconState createState() => _PulsingIconState();
}

class _PulsingIconState extends State<PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = Tween(begin: 2.0, end: 8.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.8),
                blurRadius: _pulse.value,
                spreadRadius: _pulse.value / 2,
              ),
            ],
          ),
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
      },
    );
  }
}
