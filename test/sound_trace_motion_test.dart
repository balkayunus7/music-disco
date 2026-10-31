import 'package:flutter_test/flutter_test.dart';
import 'package:music_disco/features/discover/presentation/sound_trace_motion.dart';

void main() {
  test('all five traces keep 49 finite bars within paint bounds', () {
    for (final elapsed in [0.0, 1500.0, 3600.0, 6400.0, 8000.0]) {
      for (var row = 0; row < SoundTraceMotion.rowCount; row++) {
        final bars = SoundTraceMotion.sampleRow(row, elapsed);
        expect(bars, hasLength(49));
        for (final bar in bars) {
          expect(bar.height.isFinite, isTrue);
          expect(bar.height, inInclusiveRange(0.0, 1.0));
          expect(bar.opacity, inInclusiveRange(0.18, 0.90));
        }
      }
    }
  });

  test('traces resolve in order without representing request completion', () {
    final first = SoundTraceMotion.sampleRow(0, 2000);
    final last = SoundTraceMotion.sampleRow(4, 2000);
    expect(first.first.opacity, closeTo(0.90, 0.000001));
    expect(last.first.opacity, 0.18);
  });

  test('all traces resolve within the five-second display', () {
    for (var row = 0; row < SoundTraceMotion.rowCount; row++) {
      final bars = SoundTraceMotion.sampleRow(row, 4100);
      expect(
        bars.every((bar) => (bar.opacity - 0.90).abs() < 0.000001),
        isTrue,
      );
    }
  });

  test('reduced motion keeps exactly the same waveform at any time', () {
    for (var row = 0; row < SoundTraceMotion.rowCount; row++) {
      final start = SoundTraceMotion.sampleRow(row, 0, reducedMotion: true);
      final later = SoundTraceMotion.sampleRow(row, 6400, reducedMotion: true);
      expect(start.map((bar) => bar.height), later.map((bar) => bar.height));
      expect(start.map((bar) => bar.opacity), later.map((bar) => bar.opacity));
    }
  });
}
