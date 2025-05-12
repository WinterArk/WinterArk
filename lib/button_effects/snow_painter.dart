import 'package:flutter/material.dart';

class SnowPainter extends CustomPainter {
  final List<Offset> _positions;
  final Paint _paint;

  SnowPainter(this._positions)
      : _paint = Paint()..color = Colors.white.withOpacity(0.3);

  @override
  void paint(Canvas canvas, Size size) {
    for (final pos in _positions) {
      canvas.drawCircle(pos, 2, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant SnowPainter old) => true;
}
