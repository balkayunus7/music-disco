import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/colors.dart';
import 'package:music_disco/core/widgets/disc_cover.dart';
import 'package:music_disco/features/discover/presentation/painters/fracture_painter.dart';

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
              DiscCover(palette: _palette, size: size, hasShadow: false),
              RepaintBoundary(
                child: CustomPaint(
                  painter: FracturePainter(
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
