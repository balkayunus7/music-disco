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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sp.medium.w,
        vertical: Sp.medium.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.borderSecondary),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            for (final alpha in const [0.26, 0.14, 0.05, 0.0])
              glow.withValues(alpha: alpha),
          ],
          stops: const [0, 0.35, 0.7, 1],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          spacing: Sp.medium.w,
          children: [
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
                          color: glow.withValues(alpha: 0.35),
                          blurRadius: 24.r,
                        ),
                      ],
                    ),
                    child: ReferenceAvatar(
                      reference: reference,
                      size: Sp.xxxlarge.r + Sp.medium.r,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                label: '${reference.name}, ${reference.subtitle}',
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reference.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: profileNameStyle(context),
                      ),
                      if (hasGenres)
                        Text(
                          reference.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: bodyTextStyle(
                            context,
                          ).copyWith(color: context.colors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _ChangeReferenceButton(
              onTap: onChange,
              showLabel: constraints.maxWidth >= 300,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeReferenceButton extends StatelessWidget {
  const _ChangeReferenceButton({required this.onTap, required this.showLabel});

  final VoidCallback onTap;
  final bool showLabel;

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
                  if (showLabel)
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
