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
    return AnimatedSize(
      duration: 240.ms,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: references.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: Sp.small.padBottomR,
              child: Wrap(
                spacing: Sp.xsmall.w,
                runSpacing: Sp.xsmall.h,
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
      tween: Tween(begin: 0.85, end: 1),
      duration: 260.ms,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Pressable(
        onTap: onRemove,
        semanticLabel: LocaleKeys.reference_remove.tr(args: [reference.name]),
        haptic: TapHaptic.selection,
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              Sp.medium.w,
              Sp.xsmall.h + 2,
              Sp.small.w,
              Sp.xsmall.h + 2,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              borderRadius: Sp.huge.radiusR,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Sp.xsmall.w,
              children: [
                Text(reference.name, style: m13w600(context)),
                Icon(
                  Icons.close_rounded,
                  size: Sp.medium.r,
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
