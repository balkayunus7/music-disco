import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/widgets/pressable.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = Sp.xxlarge.r + Sp.tiny.r;
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      haptic: TapHaptic.selection,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.colors.surfaceSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: context.colors.textPrimary,
          size: Sp.medium.r + 2,
        ),
      ),
    );
  }
}
