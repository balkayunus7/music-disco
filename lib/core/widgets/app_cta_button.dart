import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/design_system/motion.dart';

enum AppCtaButtonSize {
  regular,
  compact,
  player;

  bool get isCompact => this != regular;
}

class AppCtaButton extends StatelessWidget {
  const AppCtaButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon = Icons.north_east_rounded,
    this.size = AppCtaButtonSize.regular,
  });
  final String text;
  final VoidCallback? onTap;
  final IconData icon;
  final AppCtaButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onTap != null;
    final isCompact = size.isCompact;
    final foreground = isEnabled ? colors.textPrimary : colors.textDisabled;
    final background = isEnabled
        ? colors.buttonSecondary
        : colors.buttonDisabled;
    final textStyle = size == AppCtaButtonSize.player
        ? smallButtonTextStyle(context)
        : buttonTextStyle(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: text,
      haptic: TapHaptic.medium,
      child: AnimatedContainer(
        duration: context.motion(MotionDuration.base),
        constraints: BoxConstraints(
          minHeight: isCompact ? Sp.minTouchTarget : Sp.primaryButtonHeight,
        ),
        padding: (isCompact ? Sp.s20 : Sp.s24).padHVR(Sp.s12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: Sp.s64.radiusR,
        ),
        child: Row(
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: isCompact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          spacing: (isCompact ? Sp.s8 : Sp.s12).w,
          children: [
            Flexible(
              fit: isCompact ? FlexFit.loose : FlexFit.tight,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle.copyWith(color: foreground),
              ),
            ),
            Icon(icon, color: foreground, size: Sp.s20.r),
          ],
        ),
      ),
    );
  }
}
