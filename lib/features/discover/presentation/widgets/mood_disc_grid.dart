part of '../pages/mood_page.dart';

class MoodDiscGrid extends StatelessWidget {
  const MoodDiscGrid({
    super.key,
    required this.selected,
    required this.airborne,
    required this.slotKeys,
    required this.onSelected,
  });

  final Mood selected;
  final Set<Mood> airborne;
  final Map<Mood, GlobalKey> slotKeys;
  final ValueChanged<Mood> onSelected;

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < Mood.values.length; i += _columns)
        Mood.values.sublist(i, i + _columns),
    ];
    return Column(
      spacing: Sp.medium.h,
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final mood in row)
                Expanded(
                  child: _MoodSlot(
                    mood: mood,
                    slotKey: slotKeys[mood]!,
                    isSelected: mood == selected,
                    isAirborne: airborne.contains(mood),
                    onTap: () => onSelected(mood),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MoodSlot extends StatelessWidget {
  const _MoodSlot({
    required this.mood,
    required this.slotKey,
    required this.isSelected,
    required this.isAirborne,
    required this.onTap,
  });

  final Mood mood;
  final GlobalKey slotKey;
  final bool isSelected;
  final bool isAirborne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final discSize = Sp.huge.r;
    final isEmpty = isSelected || isAirborne;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: mood.labelKey.tr(),
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox.square(
              key: slotKey,
              dimension: discSize,
              child: AnimatedSwitcher(
                duration: 160.ms,
                child: isEmpty
                    ? EmptyDiscSlot(
                        key: const ValueKey('empty'),
                        size: discSize,
                      )
                    : MoodDisc(
                        key: const ValueKey('disc'),
                        mood: mood,
                        size: discSize,
                      ),
              ),
            ),
            Sp.small.heightBox,
            AnimatedSwitcher(
              duration: 220.ms,
              child: isSelected
                  ? PillLabel(
                      key: const ValueKey('pill'),
                      text: mood.labelKey.tr(),
                      dense: true,
                    )
                  : Padding(
                      key: const ValueKey('plain'),
                      padding: EdgeInsets.symmetric(vertical: Sp.xsmall.h),
                      child: Text(
                        mood.labelKey.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: m14w500(
                          context,
                        ).copyWith(color: context.colors.textSecondary),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
