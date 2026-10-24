import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_disco/features/player/bloc/youtube_player_cubit.dart';
import 'package:music_disco/features/player/data/youtube_player_wrapper.dart';
import 'package:music_disco/features/player/domain/models/playback_status.dart';

class FakeYoutubePlayerWrapper implements YoutubePlayerWrapper {
  final statusEvents = StreamController<PlaybackStatus>.broadcast();
  final positionEvents = StreamController<Duration>.broadcast();
  final durationEvents = StreamController<Duration>.broadcast();
  final calls = <String>[];

  @override
  Stream<PlaybackStatus> get statusStream => statusEvents.stream;
  @override
  Stream<Duration> get positionStream => positionEvents.stream;
  @override
  Stream<Duration> get durationStream => durationEvents.stream;

  @override
  Future<void> cue(String videoId) async => calls.add('cue:$videoId');
  @override
  Future<void> load(String videoId) async => calls.add('load:$videoId');
  @override
  Future<void> play() async => calls.add('play');
  @override
  Future<void> pause() async => calls.add('pause');
  @override
  Future<void> stop() async => calls.add('stop');
  @override
  Future<void> seekTo(Duration target) async =>
      calls.add('seek:${target.inSeconds}');
  @override
  Future<void> close() async => calls.add('close');
  @override
  Widget buildView({Color? backgroundColor}) => const SizedBox();
}

void main() {
  late FakeYoutubePlayerWrapper player;
  late YoutubePlayerCubit cubit;

  setUp(() {
    player = FakeYoutubePlayerWrapper();
    cubit = YoutubePlayerCubit(player);
  });

  tearDown(() => cubit.close());

  Future<void> report(PlaybackStatus status) async {
    player.statusEvents.add(status);
    await Future<void>.delayed(Duration.zero);
  }

  test('first video is cued, not played', () async {
    await cubit.open('a', fallbackDuration: const Duration(minutes: 4));

    expect(player.calls, ['cue:a']);
    expect(cubit.state.videoId, 'a');
    expect(cubit.state.durationLabel, '4:00');
    expect(cubit.state.isPlaying, isFalse);
  });

  test('next video keeps playing when the previous one was playing', () async {
    await cubit.open('a');
    await report(PlaybackStatus.playing);

    await cubit.open('b');

    expect(player.calls, ['cue:a', 'load:b']);
  });

  test('next video plays after the previous one ended', () async {
    await cubit.open('a');
    await report(PlaybackStatus.ended);

    await cubit.open('b');

    expect(player.calls.last, 'load:b');
  });

  test('opening the same video again does nothing', () async {
    await cubit.open('a');
    await cubit.open('a');

    expect(player.calls, ['cue:a']);
  });

  test('togglePlay pauses while playing and plays otherwise', () async {
    await cubit.togglePlay();
    await report(PlaybackStatus.playing);
    await cubit.togglePlay();

    expect(player.calls, ['play', 'pause']);
  });

  test('seekToFraction uses the reported duration and clamps', () async {
    player.durationEvents.add(const Duration(seconds: 200));
    await Future<void>.delayed(Duration.zero);

    await cubit.seekToFraction(0.5);
    await cubit.seekToFraction(3);

    expect(player.calls, ['seek:100', 'seek:200']);
    expect(cubit.state.progress, 1);
  });

  test('seeking before the duration is known is ignored', () async {
    await cubit.seekToFraction(0.5);

    expect(player.calls, isEmpty);
  });

  test('stop rewinds the position', () async {
    player.positionEvents.add(const Duration(seconds: 30));
    await Future<void>.delayed(Duration.zero);

    await cubit.stop();

    expect(player.calls, ['stop']);
    expect(cubit.state.position, Duration.zero);
  });

  test('close releases the player', () async {
    await cubit.close();

    expect(player.calls, ['close']);
  });
}
