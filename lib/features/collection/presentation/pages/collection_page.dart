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
  CollectionShelf? _shelf;

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
      builder: (_) => CollectionTrackSheet(
        track: track,
        shelf: collection.state.shelves[track.id],
      ),
    );
    if (!mounted || action == null) return;
    final oldShelf = collection.state.shelves[track.id];
    final saved = action.remove
        ? await collection.remove(track.id)
        : await collection.assignShelf(track.id, action.shelf);
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
          final restored = await collection.save(track, shelf: oldShelf);
          if (!mounted || restored) return;
          showAppSnackBar(
            context,
            message: LocaleKeys.settings_save_error.tr(),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionCubit>().state;
    final tracks = collection.tracksIn(_shelf);
    return BrandPageBody(
      appBar: AppPageBar(title: LocaleKeys.collection_eyebrow.tr()),
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
        Sp.xlarge.heightBox,
        CollectionShelfChips(
          collection: collection,
          selected: _shelf,
          onSelected: (shelf) => setState(() => _shelf = shelf),
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
            key: ValueKey(_shelf),
            child: switch ((tracks.isEmpty, _shelf)) {
              (true, null) => const CollectionEmptyView(),
              (true, _) => Column(
                children: [
                  const CollectionShelfEmptyView(),
                  TextLink(
                    text: LocaleKeys.collection_show_all.tr(),
                    onTap: () => setState(() => _shelf = null),
                  ),
                ],
              ),
              _ => CollectionGrid(
                tracks: tracks,
                onPlay: collection.isSaving ? null : _play,
                onManage: collection.isSaving ? null : _manage,
              ),
            },
          ),
        ),
        Sp.xxlarge.heightBox,
        CtaBar(
          text: LocaleKeys.collection_back_to_discover.tr(),
          onTap: () => context.go(AppRoutes.discover),
        ),
        Sp.small.heightBox,
        Center(
          child: TextLink(
            text: LocaleKeys.taste_edit.tr(),
            onTap: () => context.go(AppRoutes.taste),
          ),
        ),
      ],
    );
  }
}
