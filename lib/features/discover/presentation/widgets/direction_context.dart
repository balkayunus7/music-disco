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
    final size = Sp.s48.r;
    final eyebrow = reference == null
        ? LocaleKeys.direction_selected_frequency.tr()
        : LocaleKeys.direction_reference_sound.tr();
    final title = reference?.name ?? mood.labelKey.tr();
    final detail = reference == null
        ? mood.taglineKey.tr()
        : aspect.captionKey.tr();
    return Container(
      padding: Sp.s16.padAllR,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.borderSecondary),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            for (final alpha in const [0.26, 0.14, 0.05, 0.0])
              mood.palette.base.withValues(alpha: alpha),
          ],
          stops: const [0, 0.35, 0.7, 1],
        ),
      ),
      child: Row(
        spacing: Sp.s16.w,
        children: [
          reference == null
              ? MoodDisc(mood: mood, size: size)
              : ReferenceAvatar(reference: reference, size: size),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CaptionLabel(eyebrow),
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
