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
import 'package:music_disco/core/widgets/app_snack_bar.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/core/widgets/broken_disc.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/app_page_bar.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/pill_label.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/presentation/widgets/shelf_picker.dart';
import 'package:music_disco/features/core/home/helpers/home_page_scope.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/frequency_sheet.dart';
import 'package:music_disco/features/discover/presentation/widgets/discovery_loading_view.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';
import 'package:music_disco/features/player/bloc/youtube_player_cubit.dart';
import 'package:music_disco/features/player/domain/models/playback_status.dart';

import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/core/widgets/motion_size.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';
import 'package:music_disco/features/player/presentation/widgets/track_player_card.dart';

part '../widgets/session_completed_view.dart';
part '../widgets/session_actions.dart';
part '../widgets/session_disc_strip.dart';
part '../widgets/session_player_card.dart';
part '../widgets/session_status_views.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final branch = HomePageScope.of(context).state.activeBranch;
    if (identical(branch, _activeBranch)) return;
    _activeBranch?.removeListener(_onBranchChanged);
    _activeBranch = branch..addListener(_onBranchChanged);
  }

  void _onBranchChanged() {
    if (mounted && _activeBranch?.value != 0) _player.pause();
  }

  @override
  void dispose() {
    _activeBranch?.removeListener(_onBranchChanged);
    super.dispose();
  }

  DiscoverCubit get _discover => context.read<DiscoverCubit>();
  YoutubePlayerCubit get _player => context.read<YoutubePlayerCubit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openTrack(_discover.state.currentTrack);
    });
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
    if (_discover.state.isReplacing ||
        _discover.state.status != DiscoverRoundStatus.ready) {
      return;
    }
    _onNextTap(_discover.state);
  }

  Future<void> _openFrequencySheet() async {
    final current = _discover.state.preferences;
    final next = await showFrequencySheet(context, initial: current);
    if (!mounted || next == null || next == current) return;
    await _discover.applyPreferences(next);
  }

  void _leave() => context.go(AppRoutes.home);

  void _toggleFeedback() {
    setState(() => _isFeedbackOpen = !_isFeedbackOpen);
  }

  void _reject(TrackFeedback feedback) {
    setState(() => _isFeedbackOpen = false);
    _discover.rejectCurrent(feedback);
  }

  Future<void> _onSaveTap(Track track, {required bool isSaved}) async {
    final collection = context.read<CollectionCubit>();
    if (isSaved) {
      final removed = await collection.remove(track.id);
      if (!mounted || removed) return;
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
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
    if (!saved) {
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
      return;
    }

    final box = _saveButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final buttonRect = box.localToGlobal(Offset.zero) & box.size;
      final discSize = Sp.cont.r;
      HomePageScope.of(context).state.flyToCollection(
        from: Rect.fromCenter(
          center: buttonRect.centerLeft + Offset(Sp.xxxlarge.r, 0),
          width: discSize,
          height: discSize,
        ),
        disc: MoodDisc(mood: track.mood, size: discSize * 2),
      );
    }

    final shelf = collection.state.shelfOf(track.id);
    showAppSnackBar(
      context,
      message: shelf == null
          ? LocaleKeys.session_saved_snackbar.tr()
          : LocaleKeys.collection_saved_to.tr(args: [shelf.name]),
      actionLabel: LocaleKeys.session_undo.tr(),
      onAction: () async {
        final removed = await collection.remove(track.id);
        if (!mounted || removed) return;
        showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionCubit>().state;
    return BlocListener<YoutubePlayerCubit, YoutubePlayerState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onPlaybackChanged,
      child: _buildRound(context, collection),
    );
  }

  Widget _buildRound(BuildContext context, CollectionState collection) {
    return BlocConsumer<DiscoverCubit, DiscoverState>(
      listenWhen: (previous, current) =>
          previous.currentTrack?.id != current.currentTrack?.id,
      listener: (context, state) {
        _openTrack(state.currentTrack);
        if (_isFeedbackOpen) setState(() => _isFeedbackOpen = false);
      },
      builder: (context, state) {
        final track = state.currentTrack;
        final canTune =
            state.status == DiscoverRoundStatus.ready &&
            !state.isReplacing &&
            !state.isLastTrack;
        final isRoundActive =
            state.status != DiscoverRoundStatus.finished &&
            state.status != DiscoverRoundStatus.failure;
        final isLoading = state.status == DiscoverRoundStatus.loading;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && !isLoading) _leave();
          },
          child: BrandPageBody(
            key: ValueKey(state.status == DiscoverRoundStatus.finished),
            footer: isRoundActive && track != null
                ? _buildTrackFooter(state, track, isSaving: collection.isSaving)
                : state.status == DiscoverRoundStatus.finished
                ? SessionCompletedActions(
                    hasSaved: collection.countOf(state.tracks) > 0,
                    onNewRound: () => _discover.startRound(
                      taste: context.read<TasteCubit>().state.saved,
                    ),
                    onCollection: () => context.go(AppRoutes.collection),
                  )
                : null,
            fillRemaining: state.status == DiscoverRoundStatus.failure
                ? Center(
                    child: SessionFailureView(
                      failure: state.failure,
                      onRetry: () => _discover.startRound(
                        taste: context.read<TasteCubit>().state.saved,
                      ),
                      onChangePreferences: () => context.go(AppRoutes.taste),
                    ),
                  )
                : null,
            appBar: AppPageBar(
              title: state.status == DiscoverRoundStatus.finished
                  ? LocaleKeys.session_completed_step.tr()
                  : LocaleKeys.session_step.tr(
                      args: [track == null ? '—' : state.progressLabel],
                    ),
              showBackButton: !isLoading,
              onBack: _leave,
              actionIcon: canTune ? Icons.tune_rounded : null,
              actionLabel: canTune
                  ? '${LocaleKeys.frequency_sheet_eyebrow.tr()}: ${state.preferences.summary}'
                  : null,
              onAction: canTune ? _openFrequencySheet : null,
            ),
            children: [
              if (state.status == DiscoverRoundStatus.finished)
                SessionCompletedView(
                  tracks: state.tracks,
                  savedIds: {
                    for (final track in state.tracks)
                      if (collection.contains(track.id)) track.id,
                  },
                )
              else if (state.status == DiscoverRoundStatus.failure)
                const SizedBox.shrink()
              else if (track == null)
                DiscoveryLoadingView(
                  isSearching: state.status == DiscoverRoundStatus.loading,
                )
              else ...[
                _buildTrackContent(state, track, isSaving: collection.isSaving),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackContent(
    DiscoverState state,
    Track track, {
    required bool isSaving,
  }) {
    final isBusy = state.isReplacing || isSaving;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.isShortRound) ...[
          Text(
            LocaleKeys.session_short_round.tr(args: ['${state.tracks.length}']),
            style: secondaryTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
          Sp.small.heightBox,
        ],
        SessionPlayerCard(track: track),
        Sp.large.heightBox,
        AnimatedOpacity(
          opacity: isBusy ? 0.45 : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : 200.ms,
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : 360.ms,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(track.id),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [SessionTrackInfo(track: track)],
            ),
          ),
        ),
        Sp.medium.heightBox,
        SessionDiscStrip(
          tracks: state.tracks,
          currentIndex: state.currentIndex,
          onSelected: isBusy ? null : _discover.goTo,
          onPrevious: state.hasPrevious && !isBusy ? _discover.previous : null,
        ),
      ],
    );
  }

  Widget _buildTrackFooter(
    DiscoverState state,
    Track track, {
    required bool isSaving,
  }) {
    final isBusy = state.isReplacing || isSaving;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Sp.xsmall.w,
          children: [
            Expanded(
              child: BlocSelector<CollectionCubit, CollectionState, bool>(
                selector: (collection) => collection.contains(track.id),
                builder: (context, isSaved) => SessionSaveButton(
                  key: _saveButtonKey,
                  isSaved: isSaved,
                  onTap: isBusy
                      ? null
                      : () => _onSaveTap(track, isSaved: isSaved),
                ),
              ),
            ),
            Expanded(
              child: CtaBar(
                compact: true,
                text: state.isLastTrack
                    ? LocaleKeys.session_finish.tr()
                    : LocaleKeys.session_next.tr(),
                icon: Icons.arrow_forward_rounded,
                onTap: isBusy ? null : () => _onNextTap(state),
                playerAction: true,
              ),
            ),
          ],
        ),
        Sp.xsmall.heightBox,
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Sp.xsmall.w,
          runSpacing: Sp.tiny.h,
          children: [
            SessionGhostAction(
              icon: Icons.album_outlined,
              label: LocaleKeys.session_known.tr(),
              onTap: isBusy ? null : () => _reject(TrackFeedback.alreadyKnown),
            ),
            SessionGhostAction(
              icon: Icons.tune_rounded,
              label: LocaleKeys.session_not_for_me.tr(),
              isActive: _isFeedbackOpen,
              onTap: isBusy ? null : _toggleFeedback,
            ),
          ],
        ),
        SessionFeedbackPanel(isOpen: _isFeedbackOpen, onSelected: _reject),
        if (state.isReplacing)
          Center(
            child: SizedBox.square(
              dimension: Sp.large.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            ),
          ),
        SessionNoticeText(notice: state.notice),
        if (state.notice == DiscoverNotice.noAlternative)
          TextLink(
            text: LocaleKeys.discovery_customize.tr(),
            onTap: _openFrequencySheet,
          ),
      ],
    );
  }
}
