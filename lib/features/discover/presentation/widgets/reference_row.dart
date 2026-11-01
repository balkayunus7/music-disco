import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_avatar.dart';

class ReferenceRow extends StatelessWidget {
  const ReferenceRow({
    super.key,
    required this.reference,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.isSelected,
    this.hasDivider = false,
  });
  final MusicReference reference;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool? isSelected;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    final row = Container(
      padding: Sp.s8.padVR,
      decoration: hasDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.colors.borderSecondary),
              ),
            )
          : null,
      child: Row(
        spacing: Sp.s12.w,
        children: [
          ReferenceAvatar(reference: reference, size: Sp.s48.r - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(
                  reference.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: listTitleStyle(context),
                ),
                if (reference.genres.isNotEmpty)
                  Text(
                    reference.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: secondaryTextStyle(
                      context,
                    ).copyWith(color: context.colors.textSecondary),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
    if (onTap == null) {
      return Semantics(
        label: '${reference.name}, ${reference.subtitle}',
        child: ExcludeSemantics(child: row),
      );
    }
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: semanticLabel ?? reference.name,
      pressedScale: MotionScale.pressedSubtle,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(child: row),
    );
  }
}

class ReferenceToggleMark extends StatelessWidget {
  const ReferenceToggleMark({super.key, required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = Sp.s24.r;
    return AnimatedContainer(
      duration: context.motion(MotionDuration.base),
      curve: MotionCurve.enter,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? context.colors.textPrimary
            : context.colors.textPrimary.withValues(alpha: 0),
        border: Border.all(
          color: isSelected
              ? context.colors.textPrimary
              : context.colors.border,
        ),
      ),
      child: AnimatedSwitcher(
        duration: context.motion(MotionDuration.fast),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isSelected ? Icons.check_rounded : Icons.add_rounded,
          key: ValueKey(isSelected),
          size: Sp.s16.r - 2,
          color: isSelected
              ? context.colors.textOnPrimary
              : context.colors.textSecondary,
        ),
      ),
    );
  }
}
