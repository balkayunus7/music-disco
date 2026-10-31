part of '../pages/session_page.dart';

class SessionCompletedView extends StatelessWidget {
  const SessionCompletedView({
    super.key,
    required this.tracks,
    required this.savedIds,
  });
  final List<Track> tracks;
  final Set<String> savedIds;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Sp.large.heightBox,
      DisplayHeadline(
        first: LocaleKeys.session_completed.tr(),
        role: HeadlineRole.loadingResults,
      ),
      Sp.small.heightBox,
      Text(
        LocaleKeys.session_summary.tr(
          args: ['${tracks.length}', '${savedIds.length}'],
        ),
        style: bodyTextStyle(
          context,
        ).copyWith(color: context.colors.textSecondary),
      ),
      Sp.large.heightBox,
      for (final track in tracks)
        _RoundRecapRow(track: track, isSaved: savedIds.contains(track.id)),
    ],
  );
}

class SessionCompletedActions extends StatelessWidget {
  const SessionCompletedActions({
    super.key,
    required this.hasSaved,
    required this.onNewRound,
    required this.onCollection,
  });
  final bool hasSaved;
  final VoidCallback onNewRound;
  final VoidCallback onCollection;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CtaBar(text: LocaleKeys.session_new_round.tr(), onTap: onNewRound),
      if (hasSaved) ...[
        Sp.small.heightBox,
        CtaBar(
          text: LocaleKeys.session_listen_saved.tr(),
          icon: Icons.play_arrow_rounded,
          onTap: onCollection,
        ),
      ],
      Center(
        child: TextLink(
          text: LocaleKeys.collection_back_to_discover.tr(),
          onTap: () => context.go(AppRoutes.discover),
        ),
      ),
    ],
  );
}

class _RoundRecapRow extends StatelessWidget {
  const _RoundRecapRow({required this.track, required this.isSaved});

  final Track track;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final markSize = Sp.xlarge.r;
    final label = isSaved
        ? '${track.title}, ${track.artist}, ${LocaleKeys.session_saved.tr()}'
        : '${track.title}, ${track.artist}';
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          padding: Sp.small.padVR,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.colors.borderSecondary),
            ),
          ),
          child: Row(
            spacing: Sp.medium.w,
            children: [
              MoodDisc(mood: track.mood, size: Sp.xxxlarge.r - Sp.xsmall.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: listTitleStyle(context),
                    ),
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
              Container(
                width: markSize,
                height: markSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSaved
                      ? context.colors.textPrimary
                      : context.colors.textPrimary.withValues(alpha: 0),
                  border: Border.all(
                    color: isSaved
                        ? context.colors.textPrimary
                        : context.colors.borderSecondary,
                  ),
                ),
                child: isSaved
                    ? Icon(
                        Icons.check_rounded,
                        size: Sp.medium.r - 2,
                        color: context.colors.textOnPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
