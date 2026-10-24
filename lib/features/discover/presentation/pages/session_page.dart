import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/duration_format.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/app_snack_bar.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/jewel_case.dart';
import 'package:music_disco/core/widgets/page_back_button.dart';
import 'package:music_disco/core/widgets/pill_label.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/core/home/helpers/home_page_scope.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/frequency_sheet.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

part '../widgets/session_actions.dart';
part '../widgets/session_disc_strip.dart';
part '../widgets/session_header.dart';
part '../widgets/session_player_card.dart';
part '../widgets/session_status_views.dart';
part '../widgets/session_track_info.dart';

/// Step 03: a round of five suggestions on the chosen frequency.
class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  final GlobalKey _saveButtonKey = GlobalKey();
  bool _isFeedbackOpen = false;

  DiscoverCubit get _discover => context.read<DiscoverCubit>();

  Future<void> _openFrequencySheet() async {
    final current = _discover.state.preferences;
    final next = await showFrequencySheet(context, initial: current);
    if (!mounted || next == null || next == current) return;
    await _discover.applyPreferences(next);
  }

  void _toggleFeedback() {
    HapticFeedback.selectionClick();
    setState(() => _isFeedbackOpen = !_isFeedbackOpen);
  }

  void _reject(TrackFeedback feedback) {
    HapticFeedback.lightImpact();
    setState(() => _isFeedbackOpen = false);
    _discover.rejectCurrent(feedback);
  }

  void _onSaveTap(Track track, {required bool isSaved}) {
    final collection = context.read<CollectionCubit>();
    if (isSaved) {
      collection.remove(track.id);
      return;
    }

    HapticFeedback.mediumImpact();
    collection.save(track);

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

    showAppSnackBar(
      context,
      message: LocaleKeys.session_saved_snackbar.tr(),
      actionLabel: LocaleKeys.session_undo.tr(),
      onAction: () => collection.remove(track.id),
    );
  }

  void _onNextTap(DiscoverState state) {
    HapticFeedback.selectionClick();
    if (state.isLastTrack) {
      _discover.finishRound();
      context.go(AppRoutes.collection);
    } else {
      _discover.next();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoverCubit, DiscoverState>(
      listenWhen: (previous, current) =>
          previous.currentTrack?.id != current.currentTrack?.id,
      listener: (context, state) {
        if (_isFeedbackOpen) setState(() => _isFeedbackOpen = false);
      },
      builder: (context, state) {
        final track = state.currentTrack;
        return BrandPageBody(
          children: [
            Sp.large.heightBox,
            SessionHeader(rangeLabel: track == null ? null : state.rangeLabel),
            Sp.medium.heightBox,
            DisplayHeadline(
              first: LocaleKeys.session_title_first.tr(),
              second: LocaleKeys.session_title_second.tr(),
            ),
            Sp.large.heightBox,
            PreferenceSummaryBar(
              preferences: state.preferences,
              onTap: _openFrequencySheet,
            ),
            Sp.large.heightBox,
            if (state.status == DiscoverRoundStatus.failure)
              SessionFailureView(onRetry: _discover.startRound)
            else if (track == null)
              SessionLoadingView(mood: state.preferences.mood)
            else ...[
              _buildTrackContent(state, track),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTrackContent(DiscoverState state, Track track) {
    final isSaved = context.select<CollectionCubit, bool>(
      (cubit) => cubit.state.contains(track.id),
    );
    final isBusy = state.isReplacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: Sp.xsmall.padHR,
          child: Row(
            children: [
              Expanded(child: EyebrowText(LocaleKeys.session_next_find.tr())),
              EyebrowText(state.progressLabel),
            ],
          ),
        ),
        Sp.small.heightBox,
        AnimatedOpacity(
          opacity: isBusy ? 0.45 : 1,
          duration: 200.ms,
          child: AnimatedSwitcher(
            duration: 360.ms,
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
              children: [
                SessionPlayerCard(track: track),
                Sp.medium.heightBox,
                SessionTrackInfo(track: track),
              ],
            ),
          ),
        ),
        Sp.large.heightBox,
        SessionDiscStrip(
          tracks: state.tracks,
          currentIndex: state.currentIndex,
          onSelected: isBusy ? null : _discover.goTo,
          onPrevious: state.hasPrevious && !isBusy ? _discover.previous : null,
        ),
        Sp.large.heightBox,
        Row(
          spacing: Sp.small.w,
          children: [
            Expanded(
              child: SessionSaveButton(
                key: _saveButtonKey,
                isSaved: isSaved,
                onTap: isBusy
                    ? null
                    : () => _onSaveTap(track, isSaved: isSaved),
              ),
            ),
            Expanded(
              child: SessionNextButton(
                isLast: state.isLastTrack,
                onTap: isBusy ? null : () => _onNextTap(state),
              ),
            ),
          ],
        ),
        Sp.small.heightBox,
        Row(
          spacing: Sp.small.w,
          children: [
            Expanded(
              child: SessionGhostAction(
                icon: Icons.album_outlined,
                label: LocaleKeys.session_known.tr(),
                onTap: isBusy
                    ? null
                    : () => _reject(TrackFeedback.alreadyKnown),
              ),
            ),
            Expanded(
              child: SessionGhostAction(
                icon: Icons.tune_rounded,
                label: LocaleKeys.session_not_for_me.tr(),
                isActive: _isFeedbackOpen,
                onTap: isBusy ? null : _toggleFeedback,
              ),
            ),
          ],
        ),
        SessionFeedbackPanel(isOpen: _isFeedbackOpen, onSelected: _reject),
        Sp.medium.heightBox,
        SessionNoticeText(notice: state.notice),
      ],
    );
  }
}
