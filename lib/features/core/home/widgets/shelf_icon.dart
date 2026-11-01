part of '../home_page.dart';

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

  static const double _strokeRatio = 0.08;
  static const double _topRatio = 0.18;
  static const double _bottomRatio = 0.82;
  static const List<double> _spineRatios = [0.16, 0.34, 0.52];
  static const double _leaningTopRatio = 0.68;
  static const double _leaningBottomRatio = 0.86;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * _strokeRatio
      ..strokeCap = StrokeCap.round;
    final top = size.height * _topRatio;
    final bottom = size.height * _bottomRatio;
    for (final x in _spineRatios) {
      canvas.drawLine(
        Offset(size.width * x, top),
        Offset(size.width * x, bottom),
        paint,
      );
    }
    canvas.drawLine(
      Offset(size.width * _leaningTopRatio, top),
      Offset(size.width * _leaningBottomRatio, bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShelfPainter oldDelegate) => oldDelegate.color != color;
}
