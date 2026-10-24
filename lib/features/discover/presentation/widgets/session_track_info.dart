part of '../pages/session_page.dart';

class SessionTrackInfo extends StatelessWidget {
  const SessionTrackInfo({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
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
                    style: a34(context),
                  ),
                  Sp.xsmall.heightBox,
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: m16w600(context).copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
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
        Sp.small.heightBox,
        Text(
          track.noteKey.tr(),
          style: m15w500(context).copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
