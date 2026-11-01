import 'package:flutter/material.dart';
import 'package:music_disco/features/player/domain/models/playback_status.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayerWrapper {
  YoutubePlayerWrapper()
    : _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: false,
          showFullscreenButton: false,
          showVideoAnnotations: false,
          enableCaption: false,
          strictRelatedVideos: true,
        ),
      );

  final YoutubePlayerController _controller;

  Stream<PlaybackStatus> get statusStream =>
      _controller.stream.map(_statusOf).distinct();

  Stream<Duration> get positionStream =>
      _controller.videoStateStream.map((state) => state.position);

  Stream<Duration> get durationStream =>
      _controller.stream.map((value) => value.metaData.duration).distinct();

  Future<void> cue(String videoId) =>
      _controller.cueVideoById(videoId: videoId);

  Future<void> load(String videoId) =>
      _controller.loadVideoById(videoId: videoId);

  Future<void> setMuted(bool muted) =>
      muted ? _controller.mute() : _controller.unMute();

  Future<void> play() => _controller.playVideo();

  Future<void> pause() => _controller.pauseVideo();

  Future<void> stop() => _controller.stopVideo();

  Future<void> seekTo(Duration position) => _controller.seekTo(
    seconds: position.inMilliseconds / Duration.millisecondsPerSecond,
    allowSeekAhead: true,
  );

  Future<void> close() => _controller.close();

  Widget buildView({Color? backgroundColor}) {
    return YoutubePlayer(
      controller: _controller,
      backgroundColor: backgroundColor,
    );
  }

  static PlaybackStatus _statusOf(YoutubePlayerValue value) {
    if (value.hasError) return PlaybackStatus.error;
    return switch (value.playerState) {
      PlayerState.unknown || PlayerState.unStarted => PlaybackStatus.idle,
      PlayerState.cued => PlaybackStatus.cued,
      PlayerState.buffering => PlaybackStatus.buffering,
      PlayerState.playing => PlaybackStatus.playing,
      PlayerState.paused => PlaybackStatus.paused,
      PlayerState.ended => PlaybackStatus.ended,
    };
  }
}
