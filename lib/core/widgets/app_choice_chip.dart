import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/design_system/motion.dart';

class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.isExpanded = true,
  }) : hasIndicator = false;

  const AppChoiceChip.indicator({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isExpanded = true,
  }) : icon = null,
       hasIndicator = true;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool hasIndicator;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isSelected ? colors.textPrimary : colors.textSecondary;
    final background = isSelected ? colors.surfaceSecondary : colors.surface;
    final borderColor = isSelected
        ? colors.textSecondary
        : colors.borderSecondary;
    final icon = this.icon;

    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: context.motion(MotionDuration.base),
          curve: MotionCurve.enter,
          constraints: const BoxConstraints(minHeight: Sp.minTouchTarget),
          padding: Sp.s16.padHVR(Sp.s8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: Sp.s12.radiusR,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: hasIndicator
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            spacing: Sp.s10.w,
            children: [
              if (hasIndicator) ...[_SelectionDot(isSelected: isSelected)],
              if (icon != null) ...[
                Icon(icon, color: foreground, size: Sp.s16.r),
              ],
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: context.motion(MotionDuration.base),
                  style: listTitleStyle(context).copyWith(color: foreground),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final markColor = isSelected ? colors.textPrimary : colors.border;
    final size = Sp.s18.r;
    return AnimatedContainer(
      duration: context.motion(MotionDuration.base),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: markColor, width: Stroke.regular),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: isSelected ? 1 : 0.5,
        duration: context.motion(MotionDuration.base),
        curve: MotionCurve.overshoot,
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: markColor),
        ),
      ),
    );
  }
}
