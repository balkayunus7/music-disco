import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/disc_palette.dart';
import 'package:music_disco/core/widgets/holo_disc.dart';

class BrokenDisc extends StatelessWidget {
  const BrokenDisc({super.key, required this.size});

  final double size;

  static const _palette = DiscPalette(
    deep: Color(0xFF16161A),
    base: Color(0xFF34343B),
    light: Color(0xFF7C7C88),
    holoStrength: 0.22,
  );
  static const _tilt = -0.2;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Transform.rotate(
          angle: _tilt,
          child: Stack(
            fit: StackFit.expand,
            children: [
              HoloDisc(palette: _palette, size: size, hasShadow: false),
              RepaintBoundary(
                child: CustomPaint(
                  painter: _FracturePainter(
                    background: context.colors.background,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FracturePainter extends CustomPainter {
  _FracturePainter({required this.background});

  final Color background;

  static const _sheen = Color(0xFFFFFFFF);
  static const _chip = [
    (-64.0, 1.05),
    (-60.0, 0.84),
    (-55.0, 0.92),
    (-50.0, 0.76),
    (-44.0, 0.9),
    (-39.0, 0.8),
    (-34.0, 1.05),
  ];
  static const _jitter = [0.0, 0.03, -0.025, 0.035, -0.02, 0.028, 0.0];
  static const _arcs = [
    (0.52, 20.0, 70.0, 0.28),
    (0.62, 110.0, 40.0, 0.2),
    (0.71, 200.0, 95.0, 0.3),
    (0.83, 300.0, 30.0, 0.22),
    (0.9, 70.0, 55.0, 0.18),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = size.center(Offset.zero);

    _paintScratches(canvas, center, radius);
    _paintCrack(
      canvas,
      _polar(center, radius * 0.3, -50),
      _polar(center, radius * 0.78, -50.5),
      radius,
    );
    final rimCrack = _polar(center, radius * 1.02, 150);
    _paintCrack(canvas, _polar(center, radius * 0.3, 150), rimCrack, radius);
    _paintCrack(
      canvas,
      _polar(center, radius * 0.66, 150),
      _polar(center, radius * 1.02, 196),
      radius,
    );
    _paintChip(canvas, center, radius);
  }

  static Offset _polar(Offset center, double radius, double degrees) {
    final angle = degrees * math.pi / 180;
    return center + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  void _paintScratches(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
    final scratch = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(0.5, radius * 0.006);
    for (final (fraction, start, sweep, alpha) in _arcs) {
      scratch.color = _sheen.withValues(alpha: alpha);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * fraction),
        start * math.pi / 180,
        sweep * math.pi / 180,
        false,
        scratch,
      );
    }
    scratch.color = _sheen.withValues(alpha: 0.2);
    canvas.drawLine(
      _polar(center, radius * 0.4, 100),
      _polar(center, radius * 0.97, 72),
      scratch,
    );
    canvas.drawLine(
      _polar(center, radius * 0.45, 245),
      _polar(center, radius * 0.95, 262),
      scratch,
    );
    canvas.restore();
  }

  void _paintCrack(Canvas canvas, Offset from, Offset to, double radius) {
    final delta = to - from;
    final normal = Offset(-delta.dy, delta.dx) / delta.distance;
    final path = Path()..moveTo(from.dx, from.dy);
    for (var i = 1; i < _jitter.length; i++) {
      final t = i / (_jitter.length - 1);
      final point = from + delta * t + normal * (_jitter[i] * radius);
      path.lineTo(point.dx, point.dy);
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      path,
      stroke
        ..strokeWidth = radius * 0.03
        ..color = background,
    );
    canvas.drawPath(
      path.shift(Offset(radius * 0.014, radius * 0.01)),
      stroke
        ..strokeWidth = math.max(0.6, radius * 0.008)
        ..color = _sheen.withValues(alpha: 0.32),
    );
  }

  void _paintChip(Canvas canvas, Offset center, double radius) {
    final points = [
      for (final (degrees, fraction) in _chip)
        _polar(center, radius * fraction, degrees),
    ];
    final fill = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      fill.lineTo(point.dx, point.dy);
    }
    fill.close();
    canvas.drawPath(fill, Paint()..color = background);

    final edge = Path()..moveTo(points[1].dx, points[1].dy);
    for (final point in points.skip(2).take(points.length - 3)) {
      edge.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(0.8, radius * 0.012)
        ..color = _sheen.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_FracturePainter oldDelegate) =>
      oldDelegate.background != background;
}
