import 'package:flutter/painting.dart';

/// Illustration colors for one holographic disc. These are intentional raw
/// brand colors, not semantic UI tokens.
class DiscPalette {
  const DiscPalette({
    required this.deep,
    required this.base,
    required this.light,
    this.holoStrength = 0.55,
  });

  final Color deep;
  final Color base;
  final Color light;

  /// Opacity of the rainbow diffraction layer, 0–1.
  final double holoStrength;

  static const List<Color> holoSpectrum = [
    Color(0xFF7CF5FF),
    Color(0xFFFFF27A),
    Color(0xFFFF8BD8),
    Color(0xFFA48BFF),
    Color(0xFF7CF5FF),
  ];
}
