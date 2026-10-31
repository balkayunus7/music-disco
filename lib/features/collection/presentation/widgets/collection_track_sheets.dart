part of '../pages/collection_page.dart';

class CollectionPlayerSheet extends StatefulWidget {
  const CollectionPlayerSheet({super.key, required this.track});
  final Track track;
  @override
  State<CollectionPlayerSheet> createState() => _CollectionPlayerSheetState();
}

class _CollectionPlayerSheetState extends State<CollectionPlayerSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<YoutubePlayerCubit>().open(
          widget.track.youtubeId,
          autoPlay: true,
          fallbackDuration: widget.track.duration,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: Sp.large.padAllR,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.track.title,
                  style: sheetTitleStyle(context),
                ),
              ),
              IconButton(
                tooltip: LocaleKeys.close.tr(),
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          Sp.medium.heightBox,
          TrackPlayerCard(track: widget.track),
        ],
      ),
    ),
  );
}

class CollectionTrackAction {
  const CollectionTrackAction({this.pick, this.remove = false});
  final ShelfPick? pick;
  final bool remove;
}

class CollectionTrackSheet extends StatelessWidget {
  const CollectionTrackSheet({
    super.key,
    required this.track,
    required this.collection,
  });
  final Track track;
  final CollectionState collection;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: Sp.large.padAllR,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(track.title, style: sheetTitleStyle(context)),
          Sp.small.heightBox,
          Text(
            LocaleKeys.collection_move_to.tr(),
            style: bodyTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
          Sp.small.heightBox,
          ShelfOptions(
            collection: collection,
            selectedId: collection.assignments[track.id],
            onPicked: (pick) =>
                Navigator.of(context).pop(CollectionTrackAction(pick: pick)),
          ),
          Divider(color: context.colors.border),
          SheetOptionTile(
            label: LocaleKeys.collection_remove.tr(),
            icon: Icons.delete_outline_rounded,
            color: context.colors.error,
            onTap: () => Navigator.of(
              context,
            ).pop(const CollectionTrackAction(remove: true)),
          ),
        ],
      ),
    ),
  );
}
