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

  static const _rows = [
    [Mood.afterHours, Mood.turnItUp, Mood.softSide],
    [Mood.slowDown, Mood.oldFeeling, Mood.noRules],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Sp.xsmall.h,
      children: [
        for (final row in _rows)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final mood in row)
                  Expanded(
                    child: _MoodSlot(
                      mood: mood,
                      slotKey: slotKeys[mood]!,
                      isSelected: mood == selected,
                      isAirborne: airborne.contains(mood),
                      isBusy: airborne.isNotEmpty,
                      onTap: () => onSelected(mood),
                    ),
                  ),
              ],
            ),
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
    required this.isBusy,
    required this.onTap,
  });

  final Mood mood;
  final GlobalKey slotKey;
  final bool isSelected;
  final bool isAirborne;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final discSize = Sp.huge.r;
    return Pressable(
      onTap: isBusy ? null : onTap,
      selected: isSelected,
      semanticLabel: mood.labelKey.tr(),
      child: ExcludeSemantics(
        child: Column(
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : 220.ms,
                  padding: Sp.tiny.padAllR,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? context.colors.textPrimary
                          : context.colors.buttonGhost,
                      width: 2,
                    ),
                  ),
                  child: SizedBox.square(
                    key: slotKey,
                    dimension: discSize,
                    child: MoodDisc(
                      mood: mood,
                      size: discSize,
                      isDimmed: isSelected || isAirborne,
                      hasShadow: !isSelected,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: Sp.tiny.padAllR,
                      decoration: BoxDecoration(
                        color: context.colors.textPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.background,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: context.colors.textOnPrimary,
                        size: Sp.small.r,
                      ),
                    ),
                  ),
              ],
            ),
            Sp.tiny.heightBox,
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Sp.minTouchTarget),
              child: Padding(
                padding: Sp.tiny.padAllR,
                child: Text(
                  mood.labelKey.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: listTitleStyle(context).copyWith(
                    color: isSelected
                        ? context.colors.textPrimary
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
