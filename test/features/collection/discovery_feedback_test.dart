import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/data/local_collection_store.dart';
import 'package:music_disco/features/collection/domain/use_cases/i_collection_store.dart';
import 'package:music_disco/features/discover/data/mock_discovery_repository.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_feedback_repository.dart';

void main() {
  test('queued feedback is skipped after the account changes', () async {
    var activeUser = true;
    final first = Completer<void>();
    final calls = <bool>[];
    final cubit = CollectionCubit(
      canRecordFeedback: () => activeUser,
      feedbackRepository: _Feedback((_, saved) async {
        calls.add(saved);
        await first.future;
      }),
    );
    addTearDown(cubit.close);
    final track = MockDiscoveryRepository.catalog.first;
    await cubit.save(track);
    await Future<void>.delayed(Duration.zero);
    await cubit.remove(track.id);
    activeUser = false;
    first.complete();
    await Future<void>.delayed(Duration.zero);
    expect(calls, [true]);
  });

  test(
    'save and undo remain local while cloud feedback is serialized',
    () async {
      final first = Completer<void>();
      final calls = <bool>[];
      final feedback = _Feedback((_, saved) async {
        calls.add(saved);
        if (saved) await first.future;
      });
      final cubit = CollectionCubit(feedbackRepository: feedback);
      addTearDown(cubit.close);
      final track = MockDiscoveryRepository.catalog.first;
      expect(await cubit.save(track), true);
      expect(await cubit.remove(track.id), true);
      await Future<void>.delayed(Duration.zero);
      expect(calls, [true]);
      expect(cubit.state.tracks, isEmpty);
      first.complete();
      await Future<void>.delayed(Duration.zero);
      expect(calls, [true, false]);
    },
  );

  test('failed local save produces no positive feedback', () async {
    var calls = 0;
    final cubit = CollectionCubit(
      store: _BrokenStore(),
      feedbackRepository: _Feedback((_, _) async {
        calls++;
      }),
    );
    addTearDown(cubit.close);
    expect(await cubit.save(MockDiscoveryRepository.catalog.first), false);
    await Future<void>.delayed(Duration.zero);
    expect(calls, 0);
    expect(cubit.state.tracks, isEmpty);
  });

  test('cloud feedback failure does not undo a saved collection', () async {
    final cubit = CollectionCubit(
      feedbackRepository: _Feedback(
        (_, _) async => throw StateError('Offline'),
      ),
    );
    addTearDown(cubit.close);
    final track = MockDiscoveryRepository.catalog.first;
    expect(await cubit.save(track), true);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.contains(track.id), true);
  });

  test('recommendation reasons survive collection persistence', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = LocalCollectionStore(preferences, userId: 'test-user');
    const track = Track(
      id: 'yt:abcdefghijk',
      title: 'Song',
      artist: 'Artist',
      mood: Mood.oldFeeling,
      duration: Duration(minutes: 4),
      youtubeId: 'abcdefghijk',
      recommendationReasons: {'en': 'Reflective.', 'tr': 'Düşünceli.'},
    );
    await store.write((tracks: [track], shelves: [], assignments: {}));
    expect(store.read().tracks.single, track);
  });
}

class _Feedback implements IDiscoveryFeedbackRepository {
  _Feedback(this.callback);
  final Future<void> Function(String, bool) callback;

  @override
  Future<void> recordSaved(String trackId, {required bool isSaved}) =>
      callback(trackId, isSaved);
}

class _BrokenStore implements ICollectionStore {
  @override
  CollectionSnapshot read() => (tracks: [], shelves: [], assignments: {});

  @override
  Future<void> write(CollectionSnapshot snapshot) async =>
      throw StateError('Storage unavailable');
}
