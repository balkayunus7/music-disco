part of '../home_page.dart';

class HomeNavBarReveal extends StatelessWidget {
  const HomeNavBarReveal({
    super.key,
    required this.isHidden,
    required this.child,
  });

  final bool isHidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isHidden,
      child: ExcludeSemantics(
        excluding: isHidden,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: isHidden ? 0 : 1),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : 320.ms,
          curve: Curves.easeOutCubic,
          builder: (context, factor, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: factor,
                  child: Opacity(opacity: factor, child: child),
                ),
              ),
              SizedBox(
                height: (1 - factor) * MediaQuery.paddingOf(context).bottom,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

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
          padding: EdgeInsets.symmetric(
            horizontal: Sp.screen.w,
            vertical: Sp.xsmall.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _NavItem(
                  label: LocaleKeys.nav_discover.tr(),
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                  iconBuilder: (color) => Icon(
                    Icons.album_outlined,
                    color: color,
                    size: Sp.large.r,
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: landingPulse,
                  builder: (context, pulse, child) {
                    return TweenAnimationBuilder<double>(
                      key: ValueKey(pulse),
                      tween: Tween(begin: pulse == 0 ? 1 : 1.12, end: 1),
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : 360.ms,
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: child,
                    );
                  },
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
                        size: Sp.large.r,
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
                      Icon(Icons.tune_rounded, color: color, size: Sp.large.r),
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
  final String? semanticLabel;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget Function(Color color) iconBuilder;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.colors.navIconActive
        : context.colors.navIconInactive;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: semanticLabel ?? label,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: Padding(
          padding: Sp.tiny.padAllR,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Sp.tiny.h,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : 260.ms,
                    curve: Curves.easeOutCubic,
                    width: Sp.huge.r,
                    padding: Sp.tiny.padVR,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.navIndicator
                          : context.colors.navIndicator.withValues(alpha: 0),
                      borderRadius: Sp.huge.radiusR,
                    ),
                    child: Center(child: iconBuilder(color)),
                  ),
                  if (badge != null)
                    Positioned(top: -Sp.tiny.r, right: 0, child: badge!),
                ],
              ),
              AnimatedDefaultTextStyle(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : 260.ms,
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

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: Sp.medium.r),
      padding: EdgeInsets.symmetric(horizontal: Sp.tiny.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: context.colors.buttonSecondary,
        borderRadius: Sp.huge.radiusR,
        border: Border.all(color: context.colors.navBackground, width: 2),
      ),
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : 300.ms,
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
