part of '../pages/session_page.dart';

class SessionTrackInfo extends StatelessWidget {
  const SessionTrackInfo({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final tags = [
      for (final genre in track.genres) genre.labelKey.tr(),
      if (track.language != MusicLanguage.any) track.language.labelKey.tr(),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: trackTitleStyle(context),
                  ),
                  Sp.xsmall.heightBox,
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: bodyTextStyle(
                      context,
                    ).copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            Sp.small.widthBox,
            PillLabel(
              text: LocaleKeys.session_new_find.tr(),
              isStrong: false,
              dense: true,
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          Sp.small.heightBox,
          Wrap(
            spacing: Sp.xsmall.w,
            runSpacing: Sp.xsmall.h,
            children: [for (final tag in tags) _TrackTag(label: tag)],
          ),
        ],
        if (track.recommendationReason(context.locale.languageCode)
            case final String reason) ...[
          Sp.small.heightBox,
          Text(
            LocaleKeys.session_why_this_track.tr(),
            style: labelTextStyle(context),
          ),
          Sp.tiny.heightBox,
          Text(
            reason,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: bodyTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _TrackTag extends StatelessWidget {
  const _TrackTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sp.small.w,
        vertical: Sp.tiny.h,
      ),
      decoration: BoxDecoration(
        borderRadius: Sp.huge.radiusR,
        border: Border.all(color: context.colors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: labelTextStyle(
          context,
        ).copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}
