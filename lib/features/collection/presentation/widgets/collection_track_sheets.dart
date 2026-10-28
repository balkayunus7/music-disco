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
  const CollectionTrackAction({this.shelf, this.remove = false});
  final CollectionShelf? shelf;
  final bool remove;
}

class CollectionTrackSheet extends StatelessWidget {
  const CollectionTrackSheet({
    super.key,
    required this.track,
    required this.shelf,
  });
  final Track track;
  final CollectionShelf? shelf;

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
          for (final choice in <CollectionShelf?>[
            null,
            ...CollectionShelf.values,
          ])
            SheetOptionTile(
              label: (switch (choice) {
                null => LocaleKeys.collection_no_shelf,
                CollectionShelf.nightWalk => LocaleKeys.collection_night_walk,
                CollectionShelf.slowMornings =>
                  LocaleKeys.collection_slow_mornings,
              }).tr(),
              isSelected: choice == shelf,
              onTap: () => Navigator.of(
                context,
              ).pop(CollectionTrackAction(shelf: choice)),
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
