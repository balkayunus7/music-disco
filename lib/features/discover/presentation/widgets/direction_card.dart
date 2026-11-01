part of '../pages/direction_page.dart';

class DirectionCard extends StatelessWidget {
  const DirectionCard({
    super.key,
    required this.mood,
    required this.direction,
    required this.onSelected,
  });
  final Mood mood;
  final DiscoveryDirection direction;
  final ValueChanged<DiscoveryDirection> onSelected;

  IconData _icon(DiscoveryDirection option) => switch (option) {
    DiscoveryDirection.stay => Icons.repeat_rounded,
    DiscoveryDirection.lift => Icons.graphic_eq_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Sp.s8.w,
        children: [
          for (final option in DiscoveryDirection.values)
            Expanded(
              child: DirectionOptionTile(
                icon: _icon(option),
                label: option.shortLabelKey.tr(),
                caption: option.captionKey.tr(),
                energy: option.energy,
                accent: mood.palette.base,
                isSelected: option == direction,
                onTap: () => onSelected(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.energy, required this.isActive});
  final double energy;
  final bool isActive;

  static const List<double> _pattern = [
    0.35,
    0.6,
    0.45,
    0.9,
    0.55,
    1,
    0.55,
    0.9,
    0.45,
    0.6,
    0.35,
  ];

  @override
  Widget build(BuildContext context) {
    final maxHeight = Sp.s24.h;
    return ExcludeSemantics(
      child: SizedBox(
        height: maxHeight,
        child: Row(
          spacing: 3.w,
          children: [
            for (final (index, height) in _pattern.indexed)
              AnimatedContainer(
                duration: context.motion(
                  MotionDuration.base + MotionDuration.tick * (index - 5).abs(),
                ),
                curve: MotionCurve.overshoot,
                width: 2.w,
                height: maxHeight * height * energy,
                decoration: BoxDecoration(
                  color: isActive
                      ? context.colors.textPrimary
                      : context.colors.textDisabled,
                  borderRadius: Sp.s8.radiusR,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
