part of '../pages/discover_home_page.dart';

class StudioStartingPoint extends StatelessWidget {
  const StudioStartingPoint({super.key, required this.profile, required this.onEdit});

  final TasteProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onEdit,
      semanticLabel: '${profile.startingPoint}. ${LocaleKeys.taste_edit.tr()}',
      pressedScale: 0.98,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: AnimatedSize(
          duration: 280.ms,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: Sp.xsmall.w,
            runSpacing: Sp.xsmall.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final label in profile.startingGenreLabels) PillLabel(text: label, isStrong: false, dense: true),
              for (final reference in profile.references) _ReferenceTag(reference: reference),
              Padding(
                padding: Sp.tiny.padHR,
                child: Icon(Icons.edit_outlined, color: context.colors.textSecondary, size: Sp.medium.r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferenceTag extends StatelessWidget {
  const _ReferenceTag({required this.reference});

  final MusicReference reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(Sp.tiny.w + 2, Sp.tiny.h + 1, Sp.small.w, Sp.tiny.h + 1),
      decoration: BoxDecoration(
        borderRadius: Sp.huge.radiusR,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Sp.xsmall.w,
        children: [
          ReferenceAvatar(reference: reference, size: Sp.xlarge.r),
          Text(reference.name, style: m13w600(context).copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}
