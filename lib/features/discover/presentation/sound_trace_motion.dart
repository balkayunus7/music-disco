import 'dart:math' as math;

/// Decorative sound traces, independent of request progress or result count.
abstract final class SoundTraceMotion {
  static const rowCount = 5;
  static const barsPerRow = 49;
  static const cycle = Duration(seconds: 5);

  static List<SoundTraceBar> sampleRow(
    int row,
    double elapsedMilliseconds, {
    bool reducedMotion = false,
  }) {
    // Fit the reference's eight-second choreography into the visible hold.
    final referenceMilliseconds =
        elapsedMilliseconds * 8000 / cycle.inMilliseconds;
    final seconds = referenceMilliseconds / 1000;
    final blend = reducedMotion
        ? 1.0
        : ((referenceMilliseconds - 1500 - row * 850) / 1500).clamp(0.0, 1.0);
    return List.generate(barsPerRow, (column) {
      final x = column / (barsPerRow - 1);
      final shape =
          0.12 +
          0.85 *
              math.pow(math.sin(math.pi * x), 1.1) *
              math.sin(x * (12 + row * 2) + row).abs();
      final noise =
          0.10 +
          0.55 *
              (math.sin(x * 16 - seconds * 1.3 + row) *
                      math.cos(x * 7 + seconds * 0.7))
                  .abs();
      return SoundTraceBar(
        height: noise * (1 - blend) + shape * blend,
        opacity: 0.18 + 0.72 * blend,
      );
    }, growable: false);
  }
}

class SoundTraceBar {
  const SoundTraceBar({required this.height, required this.opacity});

  final double height;
  final double opacity;
}
