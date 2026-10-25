import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
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
      padding: Sp.small.padVR,
      decoration: hasDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: context.colors.borderSecondary)),
            )
          : null,
      child: Row(
        spacing: Sp.medium.w,
        children: [
          ReferenceAvatar(reference: reference, size: Sp.xxxlarge.r - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(
                  reference.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: m15w500(context).copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  reference.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: m13w500(context).copyWith(color: context.colors.textSecondary),
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
      pressedScale: 0.98,
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
    final size = Sp.xlarge.r;
    return AnimatedContainer(
      duration: 220.ms,
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? context.colors.textPrimary : context.colors.textPrimary.withValues(alpha: 0),
        border: Border.all(color: isSelected ? context.colors.textPrimary : context.colors.border),
      ),
      child: AnimatedSwitcher(
        duration: 180.ms,
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: Icon(
          isSelected ? Icons.check_rounded : Icons.add_rounded,
          key: ValueKey(isSelected),
          size: Sp.medium.r - 2,
          color: isSelected ? context.colors.textOnPrimary : context.colors.textSecondary,
        ),
      ),
    );
  }
}
