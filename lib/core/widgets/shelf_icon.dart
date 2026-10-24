import 'package:flutter/material.dart';

class ShelfIcon extends StatelessWidget {
  const ShelfIcon({super.key, required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _ShelfPainter(color: color)),
    );
  }
}

class _ShelfPainter extends CustomPainter {
  _ShelfPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    final top = size.height * 0.18;
    final bottom = size.height * 0.82;
    for (final x in [0.16, 0.34, 0.52]) {
      canvas.drawLine(
        Offset(size.width * x, top),
        Offset(size.width * x, bottom),
        paint,
      );
    }
    canvas.drawLine(
      Offset(size.width * 0.68, top),
      Offset(size.width * 0.86, bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShelfPainter oldDelegate) => oldDelegate.color != color;
}
