part of '../pages/collection_page.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({
    super.key,
    required this.tracks,
    required this.onPlay,
    required this.onManage,
  });
  final ValueChanged<Track>? onPlay;
  final ValueChanged<Track>? onManage;

  final List<Track> tracks;

  static const int _columns = 2;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < tracks.length; i += _columns)
        tracks.skip(i).take(_columns).toList(),
    ];
    return Column(
      spacing: Sp.xlarge.h,
      children: [
        for (final (rowIndex, row) in rows.indexed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sp.large.w,
            children: [
              for (final (columnIndex, track) in row.indexed)
                Expanded(
                  child: CollectionTile(
                    key: ValueKey(track.id),
                    track: track,
                    onPlay: onPlay == null ? null : () => onPlay!(track),
                    onManage: onManage == null ? null : () => onManage!(track),
                    order: rowIndex * _columns + columnIndex,
                  ),
                ),
              if (row.length < _columns) const Spacer(),
            ],
          ),
      ],
    );
  }
}

class CollectionTile extends StatelessWidget {
  const CollectionTile({
    super.key,
    required this.track,
    required this.order,
    required this.onPlay,
    required this.onManage,
  });
  final VoidCallback? onPlay;
  final VoidCallback? onManage;

  final Track track;

  final int order;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : (360 + order.clamp(0, 6) * 80).ms,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * Sp.xlarge.h),
          child: child,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            semanticLabel: LocaleKeys.collection_play_track.tr(
              args: [track.title, track.artist],
            ),
            onTap: onPlay,
            child: ExcludeSemantics(
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: JewelCase(
                        hasSpine: false,
                        contentPadding: Sp.xsmall.padAllR,
                        child: LayoutBuilder(
                          builder: (context, constraints) => MoodDisc(
                            mood: track.mood,
                            size: constraints.biggest.shortestSide,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: Sp.xsmall.r,
                      bottom: Sp.xsmall.r,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colors.surfaceSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: Sp.xsmall.padAllR,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: context.colors.textPrimary,
                            size: Sp.large.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Sp.medium.heightBox,
          Row(
            children: [
              Expanded(
                child: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: listTitleStyle(context),
                ),
              ),
              IconButton(
                tooltip: LocaleKeys.collection_manage.tr(args: [track.title]),
                onPressed: onManage,
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
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
    );
  }
}

class CollectionEmptyView extends StatelessWidget {
  const CollectionEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final slotSize = Sp.xxhuge.r;
    return Column(
      children: [
        SizedBox.square(
          dimension: slotSize + Sp.xxlarge.r,
          child: JewelCase(
            hasSpine: false,
            child: EmptyDiscSlot(size: slotSize),
          ),
        ),
        Sp.large.heightBox,
        Text(
          LocaleKeys.collection_empty.tr(),
          textAlign: TextAlign.center,
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
