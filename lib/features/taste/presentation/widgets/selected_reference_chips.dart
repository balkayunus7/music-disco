part of '../pages/taste_references_page.dart';

class SelectedReferenceChips extends StatelessWidget {
  const SelectedReferenceChips({
    super.key,
    required this.references,
    required this.onRemove,
  });
  final List<MusicReference> references;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return AdaptiveAnimatedSize(
      alignment: Alignment.topLeft,
      child: references.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: Sp.s12.padBottomR,
              child: Wrap(
                spacing: Sp.s8.w,
                runSpacing: Sp.s8.h,
                children: [
                  for (final reference in references)
                    _RemovableChip(
                      key: ValueKey(reference.id),
                      reference: reference,
                      onRemove: () => onRemove(reference.id),
                    ),
                ],
              ),
            ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({
    super.key,
    required this.reference,
    required this.onRemove,
  });
  final MusicReference reference;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: MotionScale.enter, end: 1),
      duration: context.motion(MotionDuration.base),
      curve: MotionCurve.overshoot,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Pressable(
        onTap: onRemove,
        semanticLabel: LocaleKeys.reference_remove.tr(args: [reference.name]),
        haptic: TapHaptic.selection,
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              Sp.s16.w,
              Sp.s10.h,
              Sp.s12.w,
              Sp.s10.h,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              borderRadius: Sp.s64.radiusR,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Sp.s8.w,
              children: [
                Text(reference.name, style: listTitleStyle(context)),
                Icon(
                  Icons.close_rounded,
                  size: Sp.s16.r,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
