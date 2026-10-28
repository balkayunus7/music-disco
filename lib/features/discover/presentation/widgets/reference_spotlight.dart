part of '../pages/reference_page.dart';

class ReferenceSpotlight extends StatelessWidget {
  const ReferenceSpotlight({
    super.key,
    required this.reference,
    required this.onChange,
  });

  final MusicReference reference;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final glow = reference.mood.palette.base;
    final hasGenres = reference.genres.isNotEmpty;
    final avatarSize = 88.r;
    return Container(
      padding: EdgeInsets.fromLTRB(
        Sp.medium.w,
        Sp.medium.h,
        Sp.medium.w,
        Sp.large.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.borderSecondary),
        gradient: RadialGradient(
          center: const Alignment(0, -0.55),
          radius: 1,
          colors: [glow.withValues(alpha: 0.28), context.colors.surface],
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _ChangeReferenceButton(onTap: onChange),
          ),
          Semantics(
            label: reference.name,
            image: true,
            child: ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                key: ValueKey(reference.id),
                tween: Tween(begin: 0.86, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : 420.ms,
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glow.withValues(alpha: 0.4),
                        blurRadius: 36.r,
                        spreadRadius: 2.r,
                      ),
                    ],
                  ),
                  child: ReferenceAvatar(
                    reference: reference,
                    size: avatarSize,
                  ),
                ),
              ),
            ),
          ),
          Sp.medium.heightBox,
          Semantics(
            label: '${reference.name}, ${reference.subtitle}',
            child: ExcludeSemantics(
              child: Column(
                children: [
                  Text(
                    reference.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: referenceTitleStyle(context),
                  ),
                  if (hasGenres)
                    Text(
                      reference.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: bodyTextStyle(
                        context,
                      ).copyWith(color: context.colors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeReferenceButton extends StatelessWidget {
  const _ChangeReferenceButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = LocaleKeys.reference_change.tr();
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Sp.minTouchTarget),
          child: Align(
            widthFactor: 1,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Sp.small.w,
                vertical: Sp.xsmall.h,
              ),
              decoration: BoxDecoration(
                borderRadius: Sp.huge.radiusR,
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Sp.xsmall.w,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: Sp.medium.r,
                    color: context.colors.textPrimary,
                  ),
                  Text(
                    label,
                    style: labelTextStyle(
                      context,
                    ).copyWith(color: context.colors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
