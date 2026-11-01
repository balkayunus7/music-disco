import 'package:flutter/painting.dart';

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

  final double holoStrength;

  static const List<Color> holoSpectrum = [
    Color(0xFF7CF5FF),
    Color(0xFFFFF27A),
    Color(0xFFFF8BD8),
    Color(0xFFA48BFF),
    Color(0xFF7CF5FF),
  ];
}
