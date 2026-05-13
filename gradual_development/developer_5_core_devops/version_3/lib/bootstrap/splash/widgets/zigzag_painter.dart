// lib/bootstrap/splash/widgets/zigzag_painter.dart
import 'package:flutter/material.dart';

/// A reusable custom painter that draws a zigzag line across the given width.
class ZigZagPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int points;

  const ZigZagPainter({
    this.color = const Color(0xFF9E5B22),
    this.strokeWidth = 2.0,
    this.points = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final step = size.width / points;

    path.moveTo(0, size.height);

    for (int i = 1; i <= points; i++) {
      final double y = (i % 2 != 0) ? 0.0 : size.height;
      path.lineTo(i * step, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ZigZagPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.points != points;
}
