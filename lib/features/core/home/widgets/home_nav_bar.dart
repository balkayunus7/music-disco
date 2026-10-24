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
          padding: EdgeInsets.symmetric(
            horizontal: Sp.xlarge.w,
            vertical: Sp.medium.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                label: LocaleKeys.nav_discover.tr(),
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
                iconBuilder: (color) =>
                    Icon(Icons.album_outlined, color: color, size: Sp.xlarge.r),
              ),
              ValueListenableBuilder<int>(
                valueListenable: landingPulse,
                builder: (context, pulse, child) {
                  // Restarting the tween on every landing gives a small bounce.
                  return TweenAnimationBuilder<double>(
                    key: ValueKey(pulse),
                    tween: Tween(begin: pulse == 0 ? 1 : 1.12, end: 1),
                    duration: 360.ms,
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
                      size: Sp.xlarge.r,
                    ),
                    badge: _CountBadge(count: count),
                  ),
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
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: 260.ms,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: Sp.medium.w,
            vertical: Sp.small.h + Sp.tiny.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.navIndicator
                : context.colors.navIndicator.withValues(alpha: 0),
            borderRadius: Sp.huge.radiusR,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Sp.small.w,
            children: [
              iconBuilder(color),
              AnimatedDefaultTextStyle(
                duration: 260.ms,
                style: m18w700(context).copyWith(color: color),
                child: Text(label),
              ),
              ?badge,
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
      constraints: BoxConstraints(minWidth: Sp.xxlarge.r),
      padding: EdgeInsets.symmetric(
        horizontal: Sp.xsmall.w,
        vertical: Sp.xsmall.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: Sp.small.radiusR,
      ),
      child: AnimatedSwitcher(
        duration: 300.ms,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Text(
          '$count',
          key: ValueKey(count),
          textAlign: TextAlign.center,
          style: m14w600(context),
        ),
      ),
    );
  }
}
