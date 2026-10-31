import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/discovery_source.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/reference_aspect.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';

import 'package:music_disco/features/taste/domain/models/taste_profile.dart';

part 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit(
    this._repository, {
    this.requestTimeout = const Duration(seconds: 60),
  }) : super(const DiscoverState());

  final IDiscoveryRepository _repository;
  final Duration requestTimeout;

  final Set<String> _rejectedIds = {};
  int _request = 0;

  void selectMood(Mood mood) => _updatePreferences(mood: mood);

  void selectDirection(DiscoveryDirection direction) =>
      _updatePreferences(direction: direction);

  void selectDistance(DiscoveryDistance distance) =>
      _updatePreferences(distance: distance);

  void useMoodSource() => _updatePreferences(source: DiscoverySource.mood);

  void selectReference(MusicReference reference, ReferenceAspect aspect) {
    _updatePreferences(
      source: DiscoverySource.reference,
      reference: reference,
      aspect: aspect,
    );
  }

  void _updatePreferences({
    Mood? mood,
    DiscoveryDirection? direction,
    DiscoveryDistance? distance,
    DiscoverySource? source,
    MusicReference? reference,
    ReferenceAspect? aspect,
  }) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(
          mood: mood,
          direction: direction,
          distance: distance,
          source: source,
          reference: reference,
          aspect: aspect,
        ),
      ),
    );
  }

  Future<void> startRound({TasteProfile? taste}) async {
    if (state.status == DiscoverRoundStatus.loading || state.isReplacing) {
      return;
    }
    final request = ++_request;
    final preferences = state.preferences.copyWith(taste: taste);

    emit(
      state.copyWith(
        preferences: preferences,
        status: DiscoverRoundStatus.loading,
        tracks: const [],
        currentIndex: 0,
        notice: DiscoverNotice.none,
        isReplacing: false,
        failure: DiscoverFailure.none,
        roundSource: state.preferences.source,
      ),
    );
    try {
      final tracks = await _repository
          .fetchRound(
            preferences,
            count: DiscoverState.roundSize,
            excludeIds: _rejectedIds,
          )
          .timeout(requestTimeout);
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          status: tracks.isEmpty
              ? DiscoverRoundStatus.failure
              : DiscoverRoundStatus.ready,
          failure: tracks.isEmpty ? DiscoverFailure.noResults : null,
          tracks: tracks,
        ),
      );
    } on Object {
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          status: DiscoverRoundStatus.failure,
          failure: DiscoverFailure.unavailable,
        ),
      );
    }
  }

  void cancelLoadingRound() {
    if (state.status != DiscoverRoundStatus.loading) return;
    _request++;
    emit(state.copyWith(status: DiscoverRoundStatus.idle));
  }

  void finishRound() {
    if (state.status != DiscoverRoundStatus.ready || state.isReplacing) return;
    emit(
      state.copyWith(
        status: DiscoverRoundStatus.finished,
        notice: DiscoverNotice.none,
      ),
    );
  }

  void goTo(int index) {
    if (state.status != DiscoverRoundStatus.ready || state.isReplacing) return;
    if (index < 0 || index >= state.tracks.length) return;
    if (index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index, notice: DiscoverNotice.none));
  }

  void next() => goTo(state.currentIndex + 1);

  void previous() => goTo(state.currentIndex - 1);

  Future<void> rejectCurrent(TrackFeedback feedback) async {
    final current = state.currentTrack;
    if (current == null ||
        state.isReplacing ||
        state.status != DiscoverRoundStatus.ready) {
      return;
    }
    final request = ++_request;
    final index = state.currentIndex;

    _rejectedIds.add(current.id);
    emit(state.copyWith(isReplacing: true, notice: DiscoverNotice.none));
    try {
      final replacement = await _repository
          .fetchReplacement(
            state.preferences,
            feedback: feedback,
            rejectedTrackId: current.id,
            excludeIds: {..._rejectedIds, ...state.tracks.map((t) => t.id)},
          )
          .timeout(requestTimeout);
      if (isClosed || request != _request) return;
      if (replacement == null) {
        emit(
          state.copyWith(
            isReplacing: false,
            notice: DiscoverNotice.noAlternative,
          ),
        );
        return;
      }
      final tracks = [...state.tracks];
      tracks[index] = replacement;
      emit(
        state.copyWith(
          tracks: tracks,
          isReplacing: false,
          notice: feedback == TrackFeedback.alreadyKnown
              ? DiscoverNotice.knownSkipped
              : DiscoverNotice.feedbackTaken,
        ),
      );
    } on Object {
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          isReplacing: false,
          notice: DiscoverNotice.requestFailed,
        ),
      );
    }
  }

  Future<void> applyPreferences(DiscoveryPreferences preferences) async {
    if (state.status != DiscoverRoundStatus.ready || state.isReplacing) return;
    if (state.isLastTrack) {
      emit(state.copyWith(notice: DiscoverNotice.noAlternative));
      return;
    }
    final request = ++_request;
    final kept = state.tracks.sublist(0, state.currentIndex + 1);
    emit(state.copyWith(isReplacing: true, notice: DiscoverNotice.none));
    try {
      final upcoming = await _repository
          .fetchRound(
            preferences,
            count: DiscoverState.roundSize - kept.length,
            excludeIds: {..._rejectedIds, ...kept.map((t) => t.id)},
          )
          .timeout(requestTimeout);
      if (isClosed || request != _request) return;
      if (upcoming.isEmpty) {
        emit(
          state.copyWith(
            isReplacing: false,
            notice: DiscoverNotice.noAlternative,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          preferences: preferences,
          tracks: [...kept, ...upcoming],
          isReplacing: false,
        ),
      );
    } on Object {
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          isReplacing: false,
          notice: DiscoverNotice.requestFailed,
        ),
      );
    }
  }
}
