import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/app_bottom_sheet.dart';
import 'package:music_disco/core/widgets/app_dialog.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/core/widgets/choice_tile.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/app_page_bar.dart';
import 'package:music_disco/core/widgets/holo_disc.dart';
import 'package:music_disco/core/widgets/jewel_case.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/collection/presentation/widgets/shelf_picker.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/app_snack_bar.dart';
import 'package:music_disco/features/player/bloc/youtube_player_cubit.dart';
import 'package:music_disco/features/player/presentation/widgets/track_player_card.dart';

part '../widgets/collection_track_sheets.dart';
part '../widgets/collection_grid.dart';
part '../widgets/collection_shelf_chips.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  String? _shelfId;

  Future<void> _play(Track track) async {
    await showAppBottomSheet<void>(
      context,
      builder: (_) => BlocProvider(
        create: (_) => getIt<YoutubePlayerCubit>(),
        child: CollectionPlayerSheet(track: track),
      ),
    );
  }

  Future<void> _manage(Track track) async {
    final collection = context.read<CollectionCubit>();
    final action = await showAppBottomSheet<CollectionTrackAction>(
      context,
      builder: (_) =>
          CollectionTrackSheet(track: track, collection: collection.state),
    );
    if (!mounted || action == null) return;
    final oldShelfId = collection.state.assignments[track.id];
    final saved = action.remove
        ? await collection.remove(track.id)
        : await collection.assignShelf(
            track.id,
            shelfId: action.pick?.existingId,
            newShelfName: action.pick?.newName,
          );
    if (!mounted) return;
    if (!saved) {
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
      return;
    }
    if (action.remove) {
      showAppSnackBar(
        context,
        message: LocaleKeys.collection_removed.tr(),
        actionLabel: LocaleKeys.session_undo.tr(),
        onAction: () async {
          final restored = await collection.save(track, shelfId: oldShelfId);
          if (!mounted || restored) return;
          showAppSnackBar(
            context,
            message: LocaleKeys.settings_save_error.tr(),
          );
        },
      );
    }
  }

  Future<void> _createShelf() async {
    final cubit = context.read<CollectionCubit>();
    final name = await showShelfNameDialog(context, collection: cubit.state);
    if (!mounted || name == null) return;
    final shelf = await cubit.createShelf(name);
    if (!mounted) return;
    if (shelf == null) {
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
      return;
    }
    setState(() => _shelfId = shelf.id);
  }

  Future<void> _renameShelf(CollectionShelf shelf) async {
    final cubit = context.read<CollectionCubit>();
    final name = await showShelfNameDialog(
      context,
      collection: cubit.state,
      editing: shelf,
    );
    if (!mounted || name == null) return;
    final renamed = await cubit.renameShelf(shelf.id, name);
    if (!mounted || renamed) return;
    showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
  }

  Future<void> _deleteShelf(CollectionShelf shelf) async {
    final cubit = context.read<CollectionCubit>();
    final confirmed = await showAppConfirmDialog(
      context,
      title: LocaleKeys.collection_delete_title.tr(),
      message: LocaleKeys.collection_delete_message.tr(),
      confirmLabel: LocaleKeys.collection_delete.tr(),
    );
    if (!mounted || !confirmed) return;
    final deleted = await cubit.deleteShelf(shelf.id);
    if (!mounted) return;
    if (!deleted) {
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
      return;
    }
    setState(() => _shelfId = null);
  }

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionCubit>().state;
    final shelf = collection.shelfById(_shelfId);
    final selectedId = shelf?.id;
    final tracks = collection.recentIn(selectedId);
    final isBlank = collection.isEmpty && collection.shelves.isEmpty;
    return BrandPageBody(
      appBar: AppPageBar(title: LocaleKeys.collection_eyebrow.tr()),
      footer: collection.isEmpty
          ? CtaBar(
              text: LocaleKeys.collection_start_discovering.tr(),
              onTap: () => context.go(AppRoutes.discover),
            )
          : null,
      fillRemaining: isBlank
          ? const Center(child: CollectionEmptyView())
          : null,
      children: [
        DisplayHeadline(
          first: LocaleKeys.collection_title_first.tr(),
          second: LocaleKeys.collection_title_second.tr(),
        ),
        Sp.medium.heightBox,
        Text(
          LocaleKeys.collection_subtitle.tr(),
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        if (!isBlank) ...[
          Sp.xlarge.heightBox,
          CollectionShelfChips(
            collection: collection,
            selectedId: selectedId,
            onSelected: (id) => setState(() => _shelfId = id),
            onCreate: collection.isSaving ? () {} : _createShelf,
          ),
          if (shelf != null)
            CollectionShelfActions(
              onRename: () => _renameShelf(shelf),
              onDelete: () => _deleteShelf(shelf),
            ),
          Sp.xlarge.heightBox,
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : 280.ms,
            switchInCurve: Curves.easeOutCubic,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: KeyedSubtree(
              key: ValueKey(selectedId),
              child: switch ((tracks.isEmpty, selectedId)) {
                (true, null) => const CollectionEmptyView(),
                (true, _) => Column(
                  children: [
                    const CollectionShelfEmptyView(),
                    TextLink(
                      text: LocaleKeys.collection_show_all.tr(),
                      onTap: () => setState(() => _shelfId = null),
                    ),
                  ],
                ),
                _ => CollectionGrid(
                  tracks: tracks,
                  shelfLabelOf: selectedId == null
                      ? (track) => collection.shelfOf(track.id)?.name
                      : null,
                  onPlay: collection.isSaving ? null : _play,
                  onManage: collection.isSaving ? null : _manage,
                ),
              },
            ),
          ),
        ],
      ],
    );
  }
}
