part of '../pages/reference_page.dart';

class ReferenceAspectGrid extends StatelessWidget {
  const ReferenceAspectGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final ReferenceAspect selected;
  final ValueChanged<ReferenceAspect> onSelected;

  static const int _columns = 2;

  @override
  Widget build(BuildContext context) {
    const aspects = ReferenceAspect.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Sp.s8.h,
      children: [
        for (var i = 0; i < aspects.length; i += _columns)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Sp.s8.w,
              children: [
                for (final aspect in aspects.skip(i).take(_columns))
                  Expanded(
                    child: _AspectCard(
                      aspect: aspect,
                      isSelected: aspect == selected,
                      onTap: () => onSelected(aspect),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AspectCard extends StatelessWidget {
  const _AspectCard({
    required this.aspect,
    required this.isSelected,
    required this.onTap,
  });
  final ReferenceAspect aspect;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon => switch (aspect) {
    ReferenceAspect.atmosphere => Icons.blur_on_rounded,
    ReferenceAspect.vocals => Icons.mic_none_rounded,
    ReferenceAspect.rhythm => Icons.graphic_eq_rounded,
    ReferenceAspect.overallStyle => Icons.auto_awesome_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final label = aspect.labelKey.tr();
    final caption = aspect.captionKey.tr();
    final foreground = isSelected
        ? context.colors.textPrimary
        : context.colors.textSecondary;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: '$label, $caption',
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: context.motion(MotionDuration.base),
          curve: MotionCurve.enter,
          padding: EdgeInsets.all(Sp.s16.r),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.surfaceSecondary
                : context.colors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected
                  ? context.colors.textSecondary
                  : context.colors.borderSecondary,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sp.s4.h,
            children: [
              Icon(_icon, size: Sp.s24.r, color: foreground),
              Sp.s4.heightBox,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: listTitleStyle(context).copyWith(color: foreground),
              ),
              Text(
                caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: secondaryTextStyle(
                  context,
                ).copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReferenceSummary extends StatelessWidget {
  const ReferenceSummary({
    super.key,
    required this.reference,
    required this.aspect,
  });
  final MusicReference reference;
  final ReferenceAspect aspect;

  @override
  Widget build(BuildContext context) {
    final text = aspect.summaryKey.tr(args: [reference.name]);
    return Semantics(
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Sp.s12.w,
          children: [
            Icon(
              Icons.queue_music_rounded,
              size: Sp.s20.r,
              color: context.colors.textSecondary,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: context.motion(MotionDuration.base),
                child: Text(
                  text,
                  key: ValueKey(text),
                  style: bodyTextStyle(
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
