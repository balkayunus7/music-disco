part of 'discover_cubit.dart';

enum DiscoverRoundStatus { idle, loading, ready, failure, finished }

/// Where "back to discovery" should land.
enum DiscoverResumePoint { mood, direction, session }

/// Short confirmation shown under the session actions after feedback.
enum DiscoverNotice { none, feedbackTaken, knownSkipped }

class DiscoverState extends Equatable {
  const DiscoverState({
    this.preferences = const DiscoveryPreferences(),
    this.status = DiscoverRoundStatus.idle,
    this.tracks = const [],
    this.currentIndex = 0,
    this.notice = DiscoverNotice.none,
    this.isReplacing = false,
  });

  static const int roundSize = 5;

  final DiscoveryPreferences preferences;
  final DiscoverRoundStatus status;
  final List<Track> tracks;
  final int currentIndex;
  final DiscoverNotice notice;
  final bool isReplacing;

  Track? get currentTrack =>
      currentIndex < tracks.length ? tracks[currentIndex] : null;
  bool get hasPrevious => currentIndex > 0;
  bool get isLastTrack =>
      tracks.isNotEmpty && currentIndex == tracks.length - 1;

  /// "01 / 05" style counter for the session card.
  String get progressLabel =>
      '${_twoDigits(currentIndex + 1)} / ${_twoDigits(tracks.length)}';

  /// "01-05" style counter for the session header.
  String get rangeLabel =>
      '${_twoDigits(currentIndex + 1)}-${_twoDigits(tracks.length)}';

  /// An unfinished round is resumed; a finished one starts over from the
  /// direction step with the same feeling.
  DiscoverResumePoint get resumePoint => switch (status) {
    DiscoverRoundStatus.loading ||
    DiscoverRoundStatus.ready => DiscoverResumePoint.session,
    DiscoverRoundStatus.finished => DiscoverResumePoint.direction,
    DiscoverRoundStatus.idle ||
    DiscoverRoundStatus.failure => DiscoverResumePoint.mood,
  };

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  DiscoverState copyWith({
    DiscoveryPreferences? preferences,
    DiscoverRoundStatus? status,
    List<Track>? tracks,
    int? currentIndex,
    DiscoverNotice? notice,
    bool? isReplacing,
  }) {
    return DiscoverState(
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      currentIndex: currentIndex ?? this.currentIndex,
      notice: notice ?? this.notice,
      isReplacing: isReplacing ?? this.isReplacing,
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
  ];
}
