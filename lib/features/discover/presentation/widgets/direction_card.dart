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

  @override
  Widget build(BuildContext context) {
    final isStay = direction == DiscoveryDirection.stay;
    return Container(
      padding: Sp.medium.padAllR,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: Sp.xxlarge.radiusR,
        border: Border.all(color: context.colors.borderSecondary),
      ),
      child: Column(
        children: [
          _DiscRail(mood: mood, isStay: isStay),
          Sp.small.heightBox,
          Row(
            children: [
              Expanded(
                child: _SideLabel(
                  text: LocaleKeys.direction_company.tr(),
                  isActive: isStay,
                ),
              ),
              _Waveform(energy: direction.energy),
              Expanded(
                child: _SideLabel(
                  text: LocaleKeys.direction_energy.tr(),
                  isActive: !isStay,
                ),
              ),
            ],
          ),
          Sp.medium.heightBox,
          Row(
            spacing: Sp.xsmall.w,
            children: [
              Expanded(
                child: DirectionOptionTile(
                  icon: Icons.repeat_rounded,
                  label: DiscoveryDirection.stay.shortLabelKey.tr(),
                  isSelected: isStay,
                  onTap: () => onSelected(DiscoveryDirection.stay),
                ),
              ),
              Expanded(
                child: DirectionOptionTile(
                  icon: Icons.graphic_eq_rounded,
                  label: DiscoveryDirection.lift.shortLabelKey.tr(),
                  isSelected: !isStay,
                  onTap: () => onSelected(DiscoveryDirection.lift),
                ),
              ),
            ],
          ),
          Sp.small.heightBox,
          AnimatedSwitcher(
            duration: 240.ms,
            child: Text(
              direction.captionKey.tr(),
              key: ValueKey(direction),
              textAlign: TextAlign.center,
              style: m12w500(
                context,
              ).copyWith(color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscRail extends StatelessWidget {
  const _DiscRail({required this.mood, required this.isStay});

  final Mood mood;
  final bool isStay;

  @override
  Widget build(BuildContext context) {
    final discSize = Sp.xhuge.r + Sp.small.r;
    return SizedBox(
      height: discSize,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _GhostSide(letter: 'A', size: discSize),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _GhostSide(letter: 'B', size: discSize),
          ),
          AnimatedAlign(
            alignment: isStay ? Alignment.centerLeft : Alignment.centerRight,
            duration: 560.ms,
            curve: Curves.easeInOutCubic,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: isStay ? 0 : 0.5),
              duration: 560.ms,
              curve: Curves.easeInOutCubic,
              builder: (context, turns, _) =>
                  MoodDisc(mood: mood, size: discSize, turns: turns),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostSide extends StatelessWidget {
  const _GhostSide({required this.letter, required this.size});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = context.colors.textPrimary.withValues(alpha: 0.07);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final factor in [1.0, 0.72, 0.42])
              Container(
                width: size * factor,
                height: size * factor,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ring, width: 1.2),
                ),
              ),
            Text(
              letter,
              style: a32(context).copyWith(
                fontSize: size * 0.62,
                color: context.colors.textPrimary.withValues(alpha: 0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideLabel extends StatelessWidget {
  const _SideLabel({required this.text, required this.isActive});

  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: 240.ms,
      textAlign: TextAlign.center,
      style: m10w700(context).copyWith(
        letterSpacing: 2,
        color: isActive
            ? context.colors.textPrimary
            : context.colors.textDisabled,
      ),
      child: Text(text),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.energy});

  final double energy;

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
    final maxHeight = Sp.large.h + Sp.tiny.h;
    return ExcludeSemantics(
      child: SizedBox(
        height: maxHeight,
        child: Row(
          spacing: 3.w,
          children: [
            for (final (index, height) in _pattern.indexed)
              AnimatedContainer(
                duration: (280 + (index - 5).abs() * 40).ms,
                curve: Curves.easeOutBack,
                width: 2.w,
                height: maxHeight * height * energy,
                decoration: BoxDecoration(
                  color: energy > 0.5
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                  borderRadius: Sp.xsmall.radiusR,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
