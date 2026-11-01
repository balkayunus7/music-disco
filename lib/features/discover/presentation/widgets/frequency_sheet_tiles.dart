part of 'frequency_sheet.dart';

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: LocaleKeys.close.tr(),
      child: Container(
        width: Sp.s32.r + Sp.s4.r,
        height: Sp.s32.r + Sp.s4.r,
        decoration: BoxDecoration(
          color: context.colors.surfaceSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          color: context.colors.textPrimary,
          size: Sp.s16.r + 2,
        ),
      ),
    );
  }
}

class _MoodTileGrid extends StatelessWidget {
  const _MoodTileGrid({required this.selected, required this.onSelected});
  final Mood? selected;
  final ValueChanged<Mood> onSelected;

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < Mood.values.length; i += _columns)
        Mood.values.sublist(i, i + _columns),
    ];
    return Column(
      spacing: Sp.s8.h,
      children: [
        for (final row in rows)
          Row(
            spacing: Sp.s8.w,
            children: [
              for (final mood in row)
                Expanded(
                  child: _MoodTile(
                    mood: mood,
                    isSelected: mood == selected,
                    onTap: () => onSelected(mood),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: mood.labelKey.tr(),
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: context.motion(MotionDuration.base),
          curve: MotionCurve.enter,
          padding: EdgeInsets.symmetric(
            vertical: Sp.s12.h,
            horizontal: Sp.s4.w,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.surfaceSecondary
                : context.colors.surfaceSecondary.withValues(alpha: 0),
            borderRadius: Sp.s16.radiusR,
            border: Border.all(
              color: isSelected
                  ? context.colors.border
                  : context.colors.border.withValues(alpha: 0),
            ),
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isSelected ? 1.06 : 1,
                duration: context.motion(MotionDuration.base),
                child: MoodDisc(mood: mood, size: Sp.s48.r - Sp.s4.r),
              ),
              Sp.s8.heightBox,
              Text(
                mood.labelKey.tr(),
                textAlign: TextAlign.center,
                style: labelTextStyle(context).copyWith(
                  color: isSelected
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionPill extends StatelessWidget {
  const _DirectionPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? context.colors.textPrimary
        : context.colors.textSecondary;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: context.motion(MotionDuration.base),
          height: Sp.s48.h - Sp.s4.h,
          padding: Sp.s12.padHR,
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.surfaceSecondary
                : context.colors.surfaceSecondary.withValues(alpha: 0),
            borderRadius: Sp.s64.radiusR,
            border: Border.all(
              color: isSelected
                  ? context.colors.border
                  : context.colors.borderSecondary,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: Sp.s8.w,
            children: [
              Icon(icon, color: foreground, size: Sp.s16.r),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: listTitleStyle(context).copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
