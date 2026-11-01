import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';

class DiscPlaceholder extends StatelessWidget {
  const DiscPlaceholder({super.key, required this.size});
  final double size;

  static const double _holeRatio = 0.2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          border: Border.all(color: colors.borderSecondary),
        ),
        child: Center(
          child: SizedBox.square(
            dimension: size * _holeRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border, width: Stroke.thin),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
