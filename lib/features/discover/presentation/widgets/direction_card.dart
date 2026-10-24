part of '../pages/direction_page.dart';

/// A/B card: the disc rolls between "eşlik" and "enerji" while the waveform
/// grows with the energy of the chosen direction.
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
      padding: EdgeInsets.fromLTRB(
        Sp.large.w,
        Sp.xlarge.h,
        Sp.large.w,
        Sp.large.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: Sp.xxlarge.radiusR,
        border: Border.all(color: context.colors.borderSecondary),
      ),
      child: Column(
        children: [
          _DiscRail(mood: mood, isStay: isStay),
          Sp.medium.heightBox,
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
          Sp.xlarge.heightBox,
          Row(
            spacing: Sp.small.w,
            children: [
              Expanded(
                child: DirectionOptionTile(
                  icon: Icons.repeat_rounded,
                  firstLine: LocaleKeys.direction_stay_first.tr(),
                  secondLine: LocaleKeys.direction_stay_second.tr(),
                  isSelected: isStay,
                  onTap: () => onSelected(DiscoveryDirection.stay),
                ),
              ),
              Expanded(
                child: DirectionOptionTile(
                  icon: Icons.graphic_eq_rounded,
                  firstLine: LocaleKeys.direction_lift_first.tr(),
                  secondLine: LocaleKeys.direction_lift_second.tr(),
                  isSelected: !isStay,
                  onTap: () => onSelected(DiscoveryDirection.lift),
                ),
              ),
            ],
          ),
          Sp.medium.heightBox,
          AnimatedSwitcher(
            duration: 240.ms,
            child: Text(
              direction.captionKey.tr(),
              key: ValueKey(direction),
              textAlign: TextAlign.center,
              style: m14w500(
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
    final discSize = Sp.xxhuge.r + Sp.xlarge.r;
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

/// Faint concentric rings and a large letter marking an empty side.
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
              style: a56(context).copyWith(
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
      style: m12w600(context).copyWith(
        letterSpacing: 2.4,
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

  /// 0–1 multiplier for every bar.
  final double energy;

  static const List<double> _pattern = [
    0.35, 0.6, 0.45, 0.9, 0.55, 1, 0.55, 0.9, 0.45, 0.6, 0.35, //
  ];

  @override
  Widget build(BuildContext context) {
    final maxHeight = Sp.xxlarge.h + Sp.xsmall.h;
    return ExcludeSemantics(
      child: SizedBox(
        height: maxHeight,
        child: Row(
          spacing: Sp.tiny.w,
          children: [
            for (final (index, height) in _pattern.indexed)
              AnimatedContainer(
                // A small per-bar delay makes the change ripple outward.
                duration: (280 + (index - 5).abs() * 40).ms,
                curve: Curves.easeOutBack,
                width: 3.w,
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
