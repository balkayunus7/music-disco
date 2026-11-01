import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/opacities.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/adaptive_animated_size.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/app_snackbar.dart';
import 'package:music_disco/core/widgets/pill_label.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/presentation/widgets/shelf_picker.dart';
import 'package:music_disco/features/core/home/helpers/home_page_scope.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/broken_disc.dart';
import 'package:music_disco/features/discover/presentation/widgets/discovery_loading_view.dart';
import 'package:music_disco/features/discover/presentation/widgets/frequency_sheet.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';
import 'package:music_disco/features/player/bloc/youtube_player_cubit.dart';
import 'package:music_disco/features/player/domain/models/playback_status.dart';
import 'package:music_disco/features/player/presentation/widgets/track_player_card.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';

part '../widgets/session_completed_view.dart';
part '../widgets/session_actions.dart';
part '../widgets/session_disc_strip.dart';
part '../widgets/session_player_card.dart';
part '../widgets/session_status_views.dart';
part '../widgets/session_track_content.dart';
part '../widgets/session_track_footer.dart';
part '../widgets/session_track_info.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<YoutubePlayerCubit>(),
      child: const _SessionView(),
    );
  }
}

class _SessionView extends StatefulWidget {
  const _SessionView();

  @override
  State<_SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<_SessionView>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  final GlobalKey _saveButtonKey = GlobalKey();
  bool _isFeedbackOpen = false;
  ValueNotifier<int>? _activeBranch;

  DiscoverCubit get _discover => context.read<DiscoverCubit>();
  YoutubePlayerCubit get _player => context.read<YoutubePlayerCubit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openTrack(_discover.state.currentTrack);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final branch = HomePageScope.of(context).state.activeBranch;
    if (identical(branch, _activeBranch)) return;
    _activeBranch?.removeListener(_onBranchChanged);
    _activeBranch = branch..addListener(_onBranchChanged);
  }

  @override
  void dispose() {
    _activeBranch?.removeListener(_onBranchChanged);
    super.dispose();
  }

  void _onBranchChanged() {
    if (mounted && _activeBranch?.value != 0) _player.pause();
  }

  void _openTrack(Track? track) {
    if (track == null) return;
    _player.open(
      track.youtubeId,
      autoPlay: true,
      fallbackDuration: track.duration,
    );
  }

  void _onPlaybackChanged(BuildContext context, YoutubePlayerState player) {
    if (player.status != PlaybackStatus.ended || _activeBranch?.value != 0) {
      return;
    }
    if (_discover.state.canChangeRound) _onNextTap(_discover.state);
  }

  Future<void> _openFrequencySheet() async {
    final current = _discover.state.preferences;
    final next = await showFrequencySheet(context, initial: current);
    if (!mounted || next == null || next == current) return;
    await _discover.applyPreferences(next);
  }

  void _leave() => context.go(AppRoutes.home);

  Future<void> _startRound() =>
      _discover.startRound(taste: context.read<TasteCubit>().state.saved);

  void _showSaveError() =>
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());

  void _toggleFeedback() {
    setState(() => _isFeedbackOpen = !_isFeedbackOpen);
  }

  void _reject(TrackFeedback feedback) {
    setState(() => _isFeedbackOpen = false);
    _discover.rejectCurrent(feedback);
  }

  void _onNextTap(DiscoverState state) {
    if (state.isLastTrack) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _player.stop();
      _discover.finishRound();
    } else {
      _discover.next();
    }
  }

  Future<void> _onSaveTap(Track track, {required bool isSaved}) async {
    final collection = context.read<CollectionCubit>();
    if (isSaved) {
      final removed = await collection.remove(track.id);
      if (mounted && !removed) _showSaveError();
      return;
    }

    final pick = await showShelfPicker(context, collection: collection.state);
    if (!mounted || pick == null) return;
    final saved = await collection.save(
      track,
      shelfId: pick.existingId,
      newShelfName: pick.newName,
    );
    if (!mounted) return;
    if (!saved) return _showSaveError();

    _flyToCollection(track);
    _showSavedSnackBar(collection, track);
  }

  void _flyToCollection(Track track) {
    final box = _saveButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final buttonRect = box.localToGlobal(Offset.zero) & box.size;
    final discSize = Sp.control.r;
    HomePageScope.of(context).state.flyToCollection(
      from: Rect.fromCenter(
        center: buttonRect.centerLeft + Offset(Sp.s48.r, 0),
        width: discSize,
        height: discSize,
      ),
      disc: MoodDisc(mood: track.mood, size: discSize * 2),
    );
  }

  void _showSavedSnackBar(CollectionCubit collection, Track track) {
    final shelf = collection.state.shelfOf(track.id);
    showAppSnackBar(
      context,
      message: shelf == null
          ? LocaleKeys.session_saved_snackbar.tr()
          : LocaleKeys.collection_saved_to.tr(args: [shelf.name]),
      action: AppSnackBarAction(
        label: LocaleKeys.session_undo.tr(),
        onTap: () async {
          final removed = await collection.remove(track.id);
          if (mounted && !removed) _showSaveError();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionCubit>().state;
    return BlocListener<YoutubePlayerCubit, YoutubePlayerState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onPlaybackChanged,
      child: BlocConsumer<DiscoverCubit, DiscoverState>(
        listenWhen: (previous, current) =>
            previous.currentTrack?.id != current.currentTrack?.id,
        listener: (context, state) {
          _openTrack(state.currentTrack);
          if (_isFeedbackOpen) setState(() => _isFeedbackOpen = false);
        },
        builder: (context, state) => _buildRound(state, collection),
      ),
    );
  }

  Widget _buildRound(DiscoverState state, CollectionState collection) {
    final track = state.currentTrack;
    final isBusy = state.isReplacing || collection.isSaving;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !state.isLoading) _leave();
      },
      child: AppPageScaffold(
        key: ValueKey(state.isFinished),
        pageBar: _buildPageBar(state, track),
        footer: _buildFooter(state, track, collection, isBusy),
        stateView: state.isFailed
            ? Center(child: _buildFailureView(state))
            : null,
        children: [_buildContent(state, track, collection, isBusy)],
      ),
    );
  }

  AppPageBar _buildPageBar(DiscoverState state, Track? track) {
    final canTune = state.canChangeRound && !state.isLastTrack;
    return AppPageBar(
      title: state.isFinished
          ? LocaleKeys.session_completed_step.tr()
          : LocaleKeys.session_step.tr(
              args: [track == null ? '—' : state.progressLabel],
            ),
      showBackButton: !state.isLoading,
      onBack: _leave,
      action: canTune
          ? AppPageBarAction(
              icon: Icons.tune_rounded,
              label:
                  '${LocaleKeys.frequency_sheet_eyebrow.tr()}: ${state.preferences.summary}',
              onTap: _openFrequencySheet,
            )
          : null,
    );
  }

  Widget? _buildFooter(
    DiscoverState state,
    Track? track,
    CollectionState collection,
    bool isBusy,
  ) {
    if (state.isRoundActive && track != null) {
      return SessionTrackFooter(
        state: state,
        track: track,
        isBusy: isBusy,
        isFeedbackOpen: _isFeedbackOpen,
        saveButtonKey: _saveButtonKey,
        onSave: (isSaved) => _onSaveTap(track, isSaved: isSaved),
        onNext: () => _onNextTap(state),
        onToggleFeedback: _toggleFeedback,
        onReject: _reject,
        onCustomize: _openFrequencySheet,
      );
    }
    if (state.isFinished) {
      return SessionCompletedActions(
        hasSaved: collection.countOf(state.tracks) > 0,
        onNewRound: _startRound,
        onCollection: () => context.go(AppRoutes.collection),
      );
    }
    return null;
  }

  Widget _buildFailureView(DiscoverState state) {
    return SessionFailureView(
      failure: state.failure,
      onRetry: _startRound,
      onChangePreferences: () => context.go(AppRoutes.taste),
    );
  }

  Widget _buildContent(
    DiscoverState state,
    Track? track,
    CollectionState collection,
    bool isBusy,
  ) {
    if (state.isFinished) {
      return SessionCompletedView(
        tracks: state.tracks,
        savedIds: {
          for (final track in state.tracks)
            if (collection.contains(track.id)) track.id,
        },
      );
    }
    if (state.isFailed) return const SizedBox.shrink();
    if (track == null) {
      return DiscoveryLoadingView(isSearching: state.isLoading);
    }
    return SessionTrackContent(
      state: state,
      track: track,
      isBusy: isBusy,
      onSelected: _discover.goTo,
      onPrevious: _discover.previous,
    );
  }
}
