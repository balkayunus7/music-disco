import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/core/util/duration_format.dart';
import 'package:music_disco/features/player/data/youtube_player_wrapper.dart';
import 'package:music_disco/features/player/domain/models/playback_status.dart';

part 'youtube_player_state.dart';

class YoutubePlayerCubit extends Cubit<YoutubePlayerState> {
  YoutubePlayerCubit(this._player) : super(const YoutubePlayerState()) {
    _subscriptions = [
      _player.statusStream.listen(
        (status) => emit(state.copyWith(status: status)),
      ),
      _player.positionStream.listen(
        (position) => emit(state.copyWith(position: position)),
      ),
      _player.durationStream.listen((duration) {
        if (duration > Duration.zero) emit(state.copyWith(duration: duration));
      }),
    ];
  }

  final YoutubePlayerWrapper _player;
  late final List<StreamSubscription<Object?>> _subscriptions;

  Future<void> open(
    String videoId, {
    bool? autoPlay,
    Duration fallbackDuration = Duration.zero,
  }) async {
    if (videoId == state.videoId) return;
    final shouldPlay =
        autoPlay ?? (state.isPlaying || state.status == PlaybackStatus.ended);
    emit(
      YoutubePlayerState(
        videoId: videoId,
        isMuted: state.isMuted,
        status: shouldPlay ? PlaybackStatus.buffering : PlaybackStatus.idle,
        duration: fallbackDuration,
      ),
    );
    if (shouldPlay) {
      await _player.load(videoId);
    } else {
      await _player.cue(videoId);
    }
  }

  Future<void> toggleMute() async {
    final muted = !state.isMuted;
    await _player.setMuted(muted);
    if (!isClosed) emit(state.copyWith(isMuted: muted));
  }

  Future<void> retry() async {
    final id = state.videoId;
    if (id == null) return;
    emit(
      state.copyWith(status: PlaybackStatus.buffering, position: Duration.zero),
    );
    await _player.load(id);
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> togglePlay() => state.isPlaying ? pause() : play();

  Future<void> stop() async {
    await _player.stop();
    emit(state.copyWith(position: Duration.zero));
  }

  Future<void> seekToFraction(double fraction) async {
    if (state.duration == Duration.zero) return;
    final target = state.duration * fraction.clamp(0.0, 1.0);
    emit(state.copyWith(position: target));
    await _player.seekTo(target);
  }

  Widget buildView({Color? backgroundColor}) =>
      _player.buildView(backgroundColor: backgroundColor);

  @override
  Future<void> close() async {
    await Future.wait<void>([
      for (final subscription in _subscriptions) subscription.cancel(),
      _player.close(),
    ]);
    return super.close();
  }
}
