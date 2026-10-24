import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/disc_palette.dart';

class HoloDisc extends StatelessWidget {
  const HoloDisc({
    super.key,
    required this.palette,
    required this.size,
    this.title,
    this.caption,
    this.turns = 0,
    this.isDimmed = false,
    this.hasShadow = true,
  });

  final DiscPalette palette;
  final double size;

  final String? title;

  final String? caption;

  final double turns;
  final bool isDimmed;
  final bool hasShadow;

  static const double _labelMinSize = 56;

  @override
  Widget build(BuildContext context) {
    final showsLabel = size >= _labelMinSize;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: context.colors.overlay,
                    blurRadius: size * 0.12,
                    offset: Offset(0, size * 0.05),
                  ),
                ]
              : null,
        ),
        child: AnimatedOpacity(
          opacity: isDimmed ? 0.45 : 1,
          duration: const Duration(milliseconds: 220),
          child: Transform.rotate(
            angle: turns * 2 * math.pi,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _HoloDiscPainter(
                  palette: palette,
                  holeColor: context.colors.background,
                  title: showsLabel ? title : null,
                  caption: showsLabel ? caption : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyDiscSlot extends StatelessWidget {
  const EmptyDiscSlot({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surface,
        border: Border.all(color: context.colors.borderSecondary),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.18,
        height: size * 0.18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.border, width: 1.2),
        ),
      ),
    );
  }
}

class _HoloDiscPainter extends CustomPainter {
  _HoloDiscPainter({
    required this.palette,
    required this.holeColor,
    this.title,
    this.caption,
  });

  final DiscPalette palette;
  final Color holeColor;
  final String? title;
  final String? caption;

  static const _sheen = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = size.center(Offset.zero);
    final discRect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..shader = SweepGradient(
        colors: [
          palette.base,
          palette.light,
          palette.base,
          palette.deep,
          palette.base,
          palette.light,
          palette.deep,
          palette.base,
        ],
        transform: const GradientRotation(-math.pi / 3),
      ).createShader(discRect);
    canvas.drawCircle(center, radius, base);

    final holo = Paint()
      ..shader = SweepGradient(
        colors: [
          for (final color in DiscPalette.holoSpectrum)
            color.withValues(alpha: palette.holoStrength),
          Colors.transparent,
          Colors.transparent,
          for (final color in DiscPalette.holoSpectrum)
            color.withValues(alpha: palette.holoStrength * 0.7),
          Colors.transparent,
        ],
        transform: const GradientRotation(math.pi / 5),
      ).createShader(discRect)
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, radius, holo);

    final depth = Paint()
      ..shader = RadialGradient(
        colors: [
          _sheen.withValues(alpha: 0.18),
          Colors.transparent,
          palette.deep.withValues(alpha: 0.25),
        ],
        stops: const [0.2, 0.6, 1],
      ).createShader(discRect);
    canvas.drawCircle(center, radius, depth);

    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.4, radius * 0.004)
      ..color = _sheen.withValues(alpha: 0.07);
    for (var r = radius * 0.34; r < radius * 0.97; r += radius * 0.035) {
      canvas.drawCircle(center, r, groove);
    }

    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _sheen.withValues(alpha: 0.22),
          Colors.transparent,
          Colors.transparent,
          _sheen.withValues(alpha: 0.12),
        ],
        stops: const [0, 0.35, 0.7, 1],
      ).createShader(discRect);
    canvas.drawCircle(center, radius, gloss);

    _paintLabels(canvas, center, radius);
    _paintHub(canvas, center, radius);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, radius * 0.012)
      ..color = _sheen.withValues(alpha: 0.45);
    canvas.drawCircle(center, radius - rim.strokeWidth / 2, rim);
    canvas.drawCircle(
      center,
      radius * 0.93,
      rim
        ..strokeWidth = math.max(0.5, radius * 0.006)
        ..color = _sheen.withValues(alpha: 0.18),
    );
  }

  void _paintHub(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius * 0.3,
      Paint()..color = _sheen.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      center,
      radius * 0.21,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFE6E6E6),
            Color(0xFF8C8C8C),
            Color(0xFFF5F5F5),
            Color(0xFF7A7A7A),
            Color(0xFFE6E6E6),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.21)),
    );
    canvas.drawCircle(
      center,
      radius * 0.165,
      Paint()..color = _sheen.withValues(alpha: 0.85),
    );
    canvas.drawCircle(center, radius * 0.13, Paint()..color = holeColor);
  }

  void _paintLabels(Canvas canvas, Offset center, double radius) {
    final title = this.title;
    if (title != null) {
      final painter = TextPainter(
        text: TextSpan(
          text: title.replaceFirst(' ', '\n'),
          style: TextStyle(
            fontFamily: 'ArchivoBlack',
            fontSize: radius * 0.2,
            height: 0.9,
            color: _sheen.withValues(alpha: 0.95),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, center + Offset(-radius * 0.56, -radius * 0.64));
    }

    final caption = this.caption;
    if (caption != null) {
      final painter = TextPainter(
        text: TextSpan(
          text: caption,
          style: TextStyle(
            fontFamily: 'Montserrat',
            package: 'mobile_boilerplate',
            fontSize: radius * 0.055,
            fontWeight: FontWeight.w700,
            letterSpacing: radius * 0.008,
            color: _sheen.withValues(alpha: 0.75),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, center + Offset(-radius * 0.82, radius * 0.48));
    }
  }

  @override
  bool shouldRepaint(_HoloDiscPainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.holeColor != holeColor ||
        oldDelegate.title != title ||
        oldDelegate.caption != caption;
  }
}
