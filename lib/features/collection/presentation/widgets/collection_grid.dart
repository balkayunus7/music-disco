part of '../pages/collection_page.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({super.key, required this.tracks});

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
  const CollectionTile({super.key, required this.track, required this.order});

  final Track track;

  final int order;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: (360 + order.clamp(0, 6) * 80).ms,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * Sp.xlarge.h),
          child: child,
        ),
      ),
      child: Semantics(
        label: '${track.title}, ${track.artist}',
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
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
              Sp.medium.heightBox,
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: m16w700(context),
              ),
              Sp.xsmall.heightBox,
              Text(
                track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: m14w500(
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
          style: m14w500(context).copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
