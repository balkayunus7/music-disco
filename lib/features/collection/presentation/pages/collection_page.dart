import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_bottom_sheet.dart';
import 'package:music_disco/core/widgets/app_choice_chip.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/app_dialog.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/app_snackbar.dart';
import 'package:music_disco/core/widgets/disc_case.dart';
import 'package:music_disco/core/widgets/disc_placeholder.dart';
import 'package:music_disco/core/widgets/fade_slide_in.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/collection/presentation/widgets/shelf_picker.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';
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

  void _showSaveError() =>
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());

  Future<void> _play(Track track) {
    return showAppBottomSheet<void>(
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
    if (!saved) return _showSaveError();
    if (action.remove) {
      showAppSnackBar(
        context,
        message: LocaleKeys.collection_removed.tr(),
        action: AppSnackBarAction(
          label: LocaleKeys.session_undo.tr(),
          onTap: () async {
            final restored = await collection.save(track, shelfId: oldShelfId);
            if (!mounted || restored) return;
            _showSaveError();
          },
        ),
      );
    }
  }

  Future<void> _createShelf() async {
    final cubit = context.read<CollectionCubit>();
    final name = await showShelfNameDialog(context, collection: cubit.state);
    if (!mounted || name == null) return;
    final shelf = await cubit.createShelf(name);
    if (!mounted) return;
    if (shelf == null) return _showSaveError();
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
    _showSaveError();
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
    if (!deleted) return _showSaveError();
    setState(() => _shelfId = null);
  }

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionCubit>().state;
    final shelf = collection.shelfById(_shelfId);
    final selectedId = shelf?.id;
    final tracks = collection.recentIn(selectedId);
    final isBlank = collection.isEmpty && collection.shelves.isEmpty;
    return AppPageScaffold(
      pageBar: AppPageBar(title: LocaleKeys.collection_eyebrow.tr()),
      footer: collection.isEmpty
          ? AppCtaButton(
              text: LocaleKeys.collection_start_discovering.tr(),
              onTap: () => context.go(AppRoutes.discover),
            )
          : null,
      stateView: isBlank ? const Center(child: CollectionEmptyView()) : null,
      children: [
        AppPageHeadline(
          first: LocaleKeys.collection_title_first.tr(),
          second: LocaleKeys.collection_title_second.tr(),
        ),
        Sp.s16.heightBox,
        Text(
          LocaleKeys.collection_subtitle.tr(),
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        if (!isBlank) ...[
          Sp.s24.heightBox,
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
          Sp.s24.heightBox,
          AnimatedSwitcher(
            duration: context.motion(MotionDuration.base),
            switchInCurve: MotionCurve.enter,
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
