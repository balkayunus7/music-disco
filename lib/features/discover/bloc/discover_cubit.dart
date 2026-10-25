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

part 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit(this._repository) : super(const DiscoverState());

  final IDiscoveryRepository _repository;

  final Set<String> _rejectedIds = {};

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

  Future<void> startRound() async {
    if (state.status == DiscoverRoundStatus.loading) return;
    emit(
      state.copyWith(
        status: DiscoverRoundStatus.loading,
        tracks: const [],
        currentIndex: 0,
        notice: DiscoverNotice.none,
        isReplacing: false,
        roundSource: state.preferences.source,
      ),
    );
    try {
      final tracks = await _repository.fetchRound(
        state.preferences,
        count: DiscoverState.roundSize,
        excludeIds: _rejectedIds,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: tracks.isEmpty
              ? DiscoverRoundStatus.failure
              : DiscoverRoundStatus.ready,
          tracks: tracks,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(state.copyWith(status: DiscoverRoundStatus.failure));
    }
  }

  void finishRound() {
    if (state.status != DiscoverRoundStatus.ready) return;
    emit(
      state.copyWith(
        status: DiscoverRoundStatus.finished,
        notice: DiscoverNotice.none,
      ),
    );
  }

  void goTo(int index) {
    if (index < 0 || index >= state.tracks.length) return;
    if (index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index, notice: DiscoverNotice.none));
  }

  void next() => goTo(state.currentIndex + 1);

  void previous() => goTo(state.currentIndex - 1);

  Future<void> rejectCurrent(TrackFeedback feedback) async {
    final current = state.currentTrack;
    if (current == null || state.isReplacing) return;

    _rejectedIds.add(current.id);
    emit(state.copyWith(isReplacing: true, notice: DiscoverNotice.none));
    try {
      final replacement = await _repository.fetchReplacement(
        state.preferences,
        feedback: feedback,
        excludeIds: {..._rejectedIds, ...state.tracks.map((t) => t.id)},
      );
      if (isClosed) return;
      if (replacement == null) {
        emit(state.copyWith(isReplacing: false));
        return;
      }
      final tracks = [...state.tracks];
      tracks[state.currentIndex] = replacement;
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
      if (isClosed) return;
      emit(state.copyWith(isReplacing: false));
    }
  }

  Future<void> applyPreferences(DiscoveryPreferences preferences) async {
    emit(state.copyWith(preferences: preferences));
    if (state.status != DiscoverRoundStatus.ready) return;

    final kept = state.tracks.sublist(0, state.currentIndex + 1);
    emit(state.copyWith(isReplacing: true, notice: DiscoverNotice.none));
    try {
      final upcoming = await _repository.fetchRound(
        preferences,
        count: DiscoverState.roundSize - kept.length,
        excludeIds: {..._rejectedIds, ...kept.map((t) => t.id)},
      );
      if (isClosed) return;
      emit(state.copyWith(tracks: [...kept, ...upcoming], isReplacing: false));
    } on Object {
      if (isClosed) return;
      emit(state.copyWith(isReplacing: false));
    }
  }
}
