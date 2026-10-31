part of 'youtube_player_cubit.dart';

class YoutubePlayerState extends Equatable {
  const YoutubePlayerState({
    this.videoId,
    this.isMuted = false,
    this.status = PlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  final bool isMuted;
  final String? videoId;
  final PlaybackStatus status;
  final Duration position;
  final Duration duration;

  bool get isPlaying => status.isActive;
  bool get hasError => status == PlaybackStatus.error;

  double get progress => duration.inMilliseconds == 0
      ? 0
      : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  String get elapsedLabel => formatPlaybackTime(position);
  String get durationLabel => formatPlaybackTime(duration);

  YoutubePlayerState copyWith({
    bool? isMuted,
    String? videoId,
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
  }) {
    return YoutubePlayerState(
      isMuted: isMuted ?? this.isMuted,
      videoId: videoId ?? this.videoId,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [videoId, status, position, duration, isMuted];
}
