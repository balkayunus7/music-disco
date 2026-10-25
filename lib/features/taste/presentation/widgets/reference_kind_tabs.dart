part of '../pages/taste_references_page.dart';

class ReferenceKindTabs extends StatelessWidget {
  const ReferenceKindTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ReferenceKind selected;
  final ValueChanged<ReferenceKind> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.borderSecondary),
        ),
      ),
      child: Row(
        spacing: Sp.xlarge.w,
        children: [
          for (final kind in ReferenceKind.values)
            _KindTab(
              label: switch (kind) {
                ReferenceKind.artist => LocaleKeys.reference_tab_artists.tr(),
                ReferenceKind.song => LocaleKeys.reference_tab_songs.tr(),
              },
              isSelected: kind == selected,
              onTap: () => onSelected(kind),
            ),
        ],
      ),
    );
  }
}

class _KindTab extends StatelessWidget {
  const _KindTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Sp.tiny.w,
                  vertical: Sp.small.h,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: 220.ms,
                  style: m15w500(context).copyWith(
                    color: isSelected
                        ? context.colors.textPrimary
                        : context.colors.textSecondary,
                  ),
                  child: Text(label),
                ),
              ),
              AnimatedScale(
                scale: isSelected ? 1 : 0,
                duration: 260.ms,
                curve: Curves.easeOutCubic,
                child: Container(
                  height: 2.h,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
