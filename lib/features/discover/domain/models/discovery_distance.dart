/// How far the next songs may wander from the listener's known taste.
enum DiscoveryDistance {
  close(fraction: 0),
  bitDifferent(fraction: 0.5),
  faraway(fraction: 1);

  const DiscoveryDistance({required this.fraction});

  /// Position of this stop on a 0–1 track.
  final double fraction;

  /// The stop closest to [fraction]. Values outside 0–1 are clamped.
  static DiscoveryDistance nearest(double fraction) {
    final clamped = fraction.clamp(0.0, 1.0);
    var best = DiscoveryDistance.close;
    for (final distance in values) {
      if ((distance.fraction - clamped).abs() <
          (best.fraction - clamped).abs()) {
        best = distance;
      }
    }
    return best;
  }
}
