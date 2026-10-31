part of 'discovery_loading_view.dart';

class _SoundTraceRows extends StatelessWidget {
  const _SoundTraceRows({required this.animation, required this.reducedMotion});

  final Animation<double> animation;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10.h,
      children: [
        for (var row = 0; row < SoundTraceMotion.rowCount; row++)
          SizedBox(
            height: 33.h,
            child: Row(
              spacing: Sp.medium.w,
              children: [
                SizedBox(
                  width: Sp.large.w,
                  child: Text(
                    '0${row + 1}',
                    style: traceNumberStyle(
                      context,
                    ).copyWith(color: context.colors.textTertiary),
                  ),
                ),
                Expanded(
                  child: CustomPaint(
                    key: ValueKey('sound-trace-$row'),
                    size: Size(double.infinity, 33.h),
                    painter: _SoundTracePainter(
                      row: row,
                      animation: animation,
                      reducedMotion: reducedMotion,
                      color: context.loadingWave,
                      barHeight: 29,
                      maxBarWidth: 3,
                      gap: isNarrowTypography(context) ? 1 : 2,
                    ),
                  ),
                ),
                Container(
                  width: 3.r,
                  height: 3.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SoundTracePainter extends CustomPainter {
  _SoundTracePainter({
    required this.row,
    required this.animation,
    required this.reducedMotion,
    required this.color,
    required this.barHeight,
    required this.maxBarWidth,
    required this.gap,
  }) : super(repaint: animation);

  final int row;
  final Animation<double> animation;
  final bool reducedMotion;
  final Color color;
  final double barHeight;
  final double maxBarWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final bars = SoundTraceMotion.sampleRow(
      row,
      animation.value * SoundTraceMotion.cycle.inMilliseconds,
      reducedMotion: reducedMotion,
    );
    final width = math.max(
      0.0,
      math.min(
        maxBarWidth,
        (size.width - gap * (bars.length - 1)) / bars.length,
      ),
    );
    final spacing = math.max(
      gap,
      (size.width - width * bars.length) / (bars.length - 1),
    );
    final paint = Paint();
    for (final (column, bar) in bars.indexed) {
      final height = barHeight * bar.height;
      paint.color = color.withValues(alpha: bar.opacity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            column * (width + spacing),
            (size.height - height) / 2,
            width,
            height,
          ),
          Radius.circular(width / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SoundTracePainter oldDelegate) =>
      oldDelegate.row != row ||
      oldDelegate.animation != animation ||
      oldDelegate.reducedMotion != reducedMotion ||
      oldDelegate.color != color ||
      oldDelegate.barHeight != barHeight ||
      oldDelegate.maxBarWidth != maxBarWidth ||
      oldDelegate.gap != gap;
}
