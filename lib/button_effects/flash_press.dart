import 'package:flutter/material.dart';

class FlashOnPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration flashDuration;
  final Color glowColor;   // NEW!
  final Color flashColor;  // NEW!

  const FlashOnPress({
    Key? key,
    required this.child,
    required this.onTap,
    this.flashDuration = const Duration(milliseconds: 200),
    this.glowColor   = Colors.blueAccent,
    this.flashColor  = Colors.white,
  }) : super(key: key);

  @override
  _FlashOnPressState createState() => _FlashOnPressState();
}

class _FlashOnPressState extends State<FlashOnPress> {
  bool _flashing = false;

  void _handleTap() {
    // show the flash
    setState(() => _flashing = true);

    // do your real action _after_ hold time
    Future.delayed(widget.flashDuration, () {
      if (!mounted) return;
      widget.onTap();
      setState(() => _flashing = false);
    });
  }

  List<BoxShadow> glowShadows(
    Color baseColor, {
    List<double> radii = const [12, 24, 36],
    List<double>? opacities,
  }) {
    final count = radii.length;
    final alphas = opacities ??
        List.generate(count, (i) => 1.0 - (i * (1.0 / count))).toList();
    return List.generate(radii.length, (i) {
      return BoxShadow(
        color: baseColor.withOpacity(alphas[i].clamp(0.0, 1.0)),
        blurRadius: radii[i],
        offset: const Offset(0, 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // build your glow shadows based on widget.glowColor
    final blueGlow = glowShadows(widget.glowColor, radii: [8,16,24])
        .map((s) => BoxShadow(
              color: s.color,
              blurRadius: s.blurRadius,
              offset: s.offset,
            ))
        .toList();

    return AnimatedContainer(
      duration: widget.flashDuration,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // permanent glow
        boxShadow: [
          ...blueGlow,
          // only white( or flashColor ) flash when _flashing
          if (_flashing) ...[
            BoxShadow(
              color: widget.flashColor.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: widget.flashColor.withOpacity(0.3),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ]
        ],
        color: Colors.transparent, // your child paints its own fill
      ),
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );
  }
}
