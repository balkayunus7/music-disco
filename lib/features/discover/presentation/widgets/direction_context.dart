part of '../pages/direction_page.dart';

class DirectionContext extends StatelessWidget {
  const DirectionContext({
    super.key,
    required this.reference,
    required this.mood,
    required this.aspect,
    required this.onChange,
  });

  final MusicReference? reference;
  final Mood mood;
  final ReferenceAspect aspect;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final reference = this.reference;
    final size = Sp.xxxlarge.r;
    final eyebrow = reference == null
        ? LocaleKeys.direction_selected_frequency.tr()
        : LocaleKeys.direction_reference_sound.tr();
    final title = reference?.name ?? mood.labelKey.tr();
    final detail = reference == null
        ? mood.taglineKey.tr()
        : aspect.captionKey.tr();
    return Container(
      padding: Sp.medium.padAllR,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.borderSecondary),
        gradient: RadialGradient(
          center: const Alignment(-0.9, 0),
          radius: 1.6,
          colors: [
            mood.palette.base.withValues(alpha: 0.22),
            context.colors.surface,
          ],
        ),
      ),
      child: Row(
        spacing: Sp.medium.w,
        children: [
          reference == null
              ? MoodDisc(mood: mood, size: size)
              : ReferenceAvatar(reference: reference, size: size),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EyebrowText(eyebrow),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sectionTitleStyle(context),
                ),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: bodyTextStyle(
                    context,
                  ).copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          TextLink(text: LocaleKeys.reference_change.tr(), onTap: onChange),
        ],
      ),
    );
  }
}

class DirectionSummary extends StatelessWidget {
  const DirectionSummary({super.key, required this.preferences});

  final DiscoveryPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final reference = preferences.activeReference;
    final text = [
      reference?.name ?? preferences.mood.labelKey.tr(),
      if (reference != null) preferences.aspect.labelKey.tr(),
      preferences.direction.shortLabelKey.tr(),
      preferences.distance.labelKey.tr(),
    ].join(' · ');
    return Semantics(
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Sp.small.w,
          children: [
            Icon(
              Icons.tune_rounded,
              size: Sp.large.r,
              color: context.colors.textSecondary,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : 240.ms,
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
