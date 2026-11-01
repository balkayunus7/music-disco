part of '../home_page.dart';

class HomeNavBar extends StatelessWidget {
  const HomeNavBar({
    super.key,
    required this.currentIndex,
    required this.collectionTargetKey,
    required this.landingPulse,
    required this.onTap,
  });
  final int currentIndex;
  final GlobalKey collectionTargetKey;
  final ValueListenable<int> landingPulse;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.navBackground,
        border: Border(top: BorderSide(color: context.colors.borderSecondary)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: Sp.screen.padHVR(Sp.s8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _NavItem(
                  label: LocaleKeys.nav_discover.tr(),
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                  iconBuilder: (color) =>
                      Icon(Icons.album_outlined, color: color, size: Sp.s20.r),
                ),
              ),
              Expanded(
                child: _LandingPulse(
                  pulse: landingPulse,
                  child: BlocSelector<CollectionCubit, CollectionState, int>(
                    selector: (state) => state.count,
                    builder: (context, count) => _NavItem(
                      label: LocaleKeys.nav_collection.tr(),
                      semanticLabel: LocaleKeys.nav_collection_count.tr(
                        args: ['$count'],
                      ),
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                      iconBuilder: (color) => ShelfIcon(
                        key: collectionTargetKey,
                        color: color,
                        size: Sp.s20.r,
                      ),
                      badge: count == 0 ? null : _CountBadge(count: count),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: LocaleKeys.nav_settings.tr(),
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                  iconBuilder: (color) =>
                      Icon(Icons.tune_rounded, color: color, size: Sp.s20.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.iconBuilder,
    this.semanticLabel,
    this.badge,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget Function(Color color) iconBuilder;
  final String? semanticLabel;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badge = this.badge;
    final color = isSelected ? colors.navIconActive : colors.navIconInactive;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: semanticLabel ?? label,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: Padding(
          padding: Sp.s4.padAllR,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Sp.s4.h,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: context.motion(MotionDuration.base),
                    curve: MotionCurve.enter,
                    width: Sp.s64.r,
                    padding: Sp.s4.padVR,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.navIndicator
                          : colors.navIndicator.withValues(alpha: 0),
                      borderRadius: Sp.s64.radiusR,
                    ),
                    child: Center(child: iconBuilder(color)),
                  ),
                  if (badge != null)
                    Positioned(top: -Sp.s4.r, right: 0, child: badge),
                ],
              ),
              AnimatedDefaultTextStyle(
                duration: context.motion(MotionDuration.base),
                style: navigationTextStyle(context).copyWith(color: color),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingPulse extends StatelessWidget {
  const _LandingPulse({required this.pulse, required this.child});
  final ValueListenable<int> pulse;
  final Widget child;

  static const double _landingScale = 1.12;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: pulse,
      builder: (context, count, child) => TweenAnimationBuilder<double>(
        key: ValueKey(count),
        tween: Tween(begin: count == 0 ? 1 : _landingScale, end: 1),
        duration: context.motion(MotionDuration.slow),
        curve: MotionCurve.overshoot,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: child,
      ),
      child: child,
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  static const double _verticalPadding = 1;
  static const double _borderWidth = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: BoxConstraints(minWidth: Sp.s16.r),
      padding: Sp.s4.padHVR(_verticalPadding),
      decoration: BoxDecoration(
        color: colors.buttonSecondary,
        borderRadius: Sp.s64.radiusR,
        border: Border.all(color: colors.navBackground, width: _borderWidth),
      ),
      child: AnimatedSwitcher(
        duration: context.motion(MotionDuration.base),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Text(
          '$count',
          key: ValueKey(count),
          textAlign: TextAlign.center,
          style: labelTextStyle(context),
        ),
      ),
    );
  }
}
