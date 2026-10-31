import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/pressable.dart';

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.hasIndicator = false,
    this.isExpanded = true,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool hasIndicator;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? context.colors.textPrimary
        : context.colors.textSecondary;
    final icon = this.icon;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : 220.ms,
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: Sp.minTouchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: Sp.medium.w,
            vertical: Sp.xsmall,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.surfaceSecondary
                : context.colors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected
                  ? context.colors.textSecondary
                  : context.colors.borderSecondary,
            ),
          ),
          child: Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: hasIndicator
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            spacing: Sp.xsmall.w + 2,
            children: [
              if (hasIndicator) _SelectionDot(isSelected: isSelected),
              if (icon != null)
                Icon(icon, color: foreground, size: Sp.medium.r),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : 220.ms,
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
    final size = Sp.medium.r + 2;
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : 220.ms,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? context.colors.textPrimary
              : context.colors.border,
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: isSelected ? 1 : 0.4,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : 220.ms,
        curve: Curves.easeOutBack,
        child: Container(
          width: size * 0.45,
          height: size * 0.45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? context.colors.textPrimary
                : context.colors.border,
          ),
        ),
      ),
    );
  }
}
