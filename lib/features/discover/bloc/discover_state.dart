part of 'discover_cubit.dart';

enum DiscoverRoundStatus { idle, loading, ready, failure, finished }

enum DiscoverFailure { none, noResults, unavailable }

enum DiscoverNotice {
  none,
  feedbackTaken,
  knownSkipped,
  noAlternative,
  requestFailed,
}

class DiscoverState extends Equatable {
  const DiscoverState({
    this.preferences = const DiscoveryPreferences(),
    this.status = DiscoverRoundStatus.idle,
    this.tracks = const [],
    this.currentIndex = 0,
    this.notice = DiscoverNotice.none,
    this.isReplacing = false,
    this.roundSource,
    this.failure = DiscoverFailure.none,
  });

  static const int roundSize = 4;

  final DiscoveryPreferences preferences;
  final DiscoverRoundStatus status;
  final List<Track> tracks;
  final int currentIndex;
  final DiscoverNotice notice;
  final bool isReplacing;
  final DiscoverFailure failure;

  final DiscoverySource? roundSource;

  Track? get currentTrack =>
      currentIndex < tracks.length ? tracks[currentIndex] : null;
  bool get hasPrevious => currentIndex > 0;
  bool get canResume =>
      roundSource != null && status == DiscoverRoundStatus.ready;
  bool get isShortRound => tracks.isNotEmpty && tracks.length < roundSize;
  bool get isLastTrack =>
      tracks.isNotEmpty && currentIndex == tracks.length - 1;

  String get progressLabel =>
      '${_twoDigits(currentIndex + 1)} / ${_twoDigits(tracks.length)}';

  String get rangeLabel =>
      '${_twoDigits(currentIndex + 1)}-${_twoDigits(tracks.length)}';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  DiscoverState copyWith({
    DiscoveryPreferences? preferences,
    DiscoverRoundStatus? status,
    List<Track>? tracks,
    int? currentIndex,
    DiscoverNotice? notice,
    bool? isReplacing,
    DiscoverySource? roundSource,
    DiscoverFailure? failure,
  }) {
    return DiscoverState(
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      currentIndex: currentIndex ?? this.currentIndex,
      notice: notice ?? this.notice,
      isReplacing: isReplacing ?? this.isReplacing,
      roundSource: roundSource ?? this.roundSource,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    preferences,
    status,
    tracks,
    currentIndex,
    notice,
    isReplacing,
    roundSource,
    failure,
  ];
}
