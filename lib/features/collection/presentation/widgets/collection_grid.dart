part of '../pages/collection_page.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({
    super.key,
    required this.tracks,
    required this.onPlay,
    required this.onManage,
    this.shelfLabelOf,
  });
  final List<Track> tracks;
  final ValueChanged<Track>? onPlay;
  final ValueChanged<Track>? onManage;
  final String? Function(Track track)? shelfLabelOf;

  static const int _columns = 2;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < tracks.length; i += _columns)
        tracks.skip(i).take(_columns).toList(),
    ];
    return Column(
      spacing: Sp.s24.h,
      children: [
        for (final (rowIndex, row) in rows.indexed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sp.s20.w,
            children: [
              for (final (columnIndex, track) in row.indexed)
                Expanded(
                  child: CollectionTile(
                    key: ValueKey(track.id),
                    track: track,
                    shelfLabel: shelfLabelOf?.call(track),
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
    this.shelfLabel,
  });
  final Track track;
  final int order;
  final VoidCallback? onPlay;
  final VoidCallback? onManage;
  final String? shelfLabel;

  @override
  Widget build(BuildContext context) {
    final shelfLabel = this.shelfLabel;
    return FadeSlideIn(
      order: order,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileCover(track: track, onPlay: onPlay),
          Sp.s16.heightBox,
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
          Sp.s8.heightBox,
          Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: bodyTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
          if (shelfLabel != null) ...[
            Sp.s8.heightBox,
            _ShelfLabel(label: shelfLabel),
          ],
        ],
      ),
    );
  }
}

class _TileCover extends StatelessWidget {
  const _TileCover({required this.track, required this.onPlay});
  final Track track;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
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
                child: DiscCase(
                  hasSpine: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) => MoodDisc(
                      mood: track.mood,
                      size: constraints.biggest.shortestSide,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: Sp.s8.r,
                bottom: Sp.s8.r,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: Sp.s8.padAllR,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: colors.textPrimary,
                      size: Sp.s20.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShelfLabel extends StatelessWidget {
  const _ShelfLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textTertiary;
    return Row(
      spacing: Sp.s4.w,
      children: [
        Icon(Icons.album_outlined, size: Sp.s16.r - 2, color: color),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: secondaryTextStyle(context).copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class CollectionEmptyView extends StatelessWidget {
  const CollectionEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final slotSize = Sp.s128.r;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: slotSize + Sp.s32.r,
          child: DiscCase(
            hasSpine: false,
            child: DiscPlaceholder(size: slotSize),
          ),
        ),
        Sp.s20.heightBox,
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
