import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/data/local_collection_store.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/collection/domain/use_cases/i_collection_store.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/data/curated_discovery_repository.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/discovery_source.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/reference_aspect.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/data/local_taste_store.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/domain/use_cases/i_taste_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const first = CuratedDiscoveryRepository.catalog;
  late SharedPreferences preferences;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test(
    'collection and shelf survive reopening and are scoped to the listener',
    () async {
      final store = LocalCollectionStore(preferences, userId: 'listener-a');
      final collection = CollectionCubit(store: store);
      expect(await collection.save(first.first), isTrue);
      expect(
        await collection.assignShelf(first.first.id, CollectionShelf.nightWalk),
        isTrue,
      );
      await collection.close();
      final restored = CollectionCubit(
        store: LocalCollectionStore(preferences, userId: 'listener-a'),
      );
      expect(restored.state.tracks, [first.first]);
      expect(restored.state.tracksIn(CollectionShelf.nightWalk), [first.first]);
      final other = CollectionCubit(
        store: LocalCollectionStore(preferences, userId: 'listener-b'),
      );
      expect(other.state.isEmpty, isTrue);
      expect(await restored.assignShelf(first.first.id, null), isTrue);
      expect(CollectionCubit(store: store).state.shelfCount, 0);
      expect(await restored.remove(first.first.id), isTrue);
      expect(CollectionCubit(store: store).state.isEmpty, isTrue);
      await restored.close();
      await other.close();
    },
  );

  test('a failed collection write never reports a saved song', () async {
    final collection = CollectionCubit(store: _FailingCollectionStore());
    expect(await collection.save(first.first), isFalse);
    expect(collection.state.isEmpty, isTrue);
    expect(collection.state.isSaving, isFalse);
    await collection.close();
  });

  test('overlapping saves cannot lose or falsely confirm a song', () async {
    final store = _PendingCollectionStore();
    final collection = CollectionCubit(store: store);
    final saving = collection.save(first.first);
    expect(collection.state.isSaving, isTrue);
    expect(await collection.save(first.last), isFalse);
    store.writeCompleted.complete();
    expect(await saving, isTrue);
    expect(collection.state.tracks, [first.first]);
    await collection.close();
  });

  test('bad cached entries do not hide valid collection entries', () async {
    final store = LocalCollectionStore(preferences, userId: 'listener');
    final collection = CollectionCubit(store: store);
    await collection.save(first.first);
    final data = preferences.getString(store.key)!;
    await preferences.setString(
      store.key,
      data.replaceFirst('"tracks":[', '"tracks":[{"id":0},'),
    );
    expect(store.read().tracks, [first.first]);
    await preferences.setString(store.key, '{invalid');
    expect(store.read().tracks, isEmpty);
    await collection.close();
  });

  test('taste genres, artists and language survive reopening', () async {
    final store = LocalTasteStore(preferences, userId: 'listener-a');
    final taste = TasteCubit(store: store);
    taste.toggleGenre(Genre.rock);
    taste.selectLanguage(MusicLanguage.turkish);
    taste.toggleReference(
      const MusicReference(
        id: 'duman',
        name: 'Duman',
        mood: Mood.turnItUp,
        genres: [Genre.rock],
      ),
    );
    expect(await taste.save(), isTrue);
    final restored = TasteCubit(
      store: LocalTasteStore(preferences, userId: 'listener-a'),
    );
    expect(restored.state.saved, taste.state.saved);
    expect(
      LocalTasteStore(preferences, userId: 'listener-b').read(),
      const TasteProfile(),
    );
    await taste.close();
    await restored.close();
  });

  test(
    'failed taste save keeps the saved profile and editable draft',
    () async {
      final taste = TasteCubit(store: _FailingTasteStore());
      taste.selectLanguage(MusicLanguage.turkish);
      expect(await taste.save(), isFalse);
      expect(taste.state.saved.language, MusicLanguage.any);
      expect(taste.state.draft.language, MusicLanguage.turkish);
      expect(taste.state.isSaving, isFalse);
      await taste.close();
    },
  );

  test('language and genre choices constrain nearby recommendations', () async {
    final repository = CuratedDiscoveryRepository(latency: Duration.zero);
    final turkish = await repository.fetchRound(
      const DiscoveryPreferences(
        taste: TasteProfile(language: MusicLanguage.turkish),
      ),
      count: 5,
    );
    expect(turkish, isNotEmpty);
    expect(turkish.every((t) => t.language == MusicLanguage.turkish), isTrue);
    final electronic = await repository.fetchRound(
      const DiscoveryPreferences(
        taste: TasteProfile(genres: [Genre.electronic], isMixed: false),
      ),
      count: 5,
    );
    expect(electronic, isNotEmpty);
    expect(
      electronic.every((t) => t.genres.contains(Genre.electronic)),
      isTrue,
    );
    final unavailable = await repository.fetchRound(
      const DiscoveryPreferences(
        taste: TasteProfile(genres: [Genre.jazz], isMixed: false),
      ),
      count: 5,
    );
    expect(unavailable, isEmpty);
  });

  test(
    'artist references prefer their genres and exclude the reference artist',
    () async {
      final repository = CuratedDiscoveryRepository(latency: Duration.zero);
      final tracks = await repository.fetchRound(
        const DiscoveryPreferences(
          source: DiscoverySource.reference,
          reference: MusicReference(
            id: 'tarkan',
            name: 'Tarkan',
            mood: Mood.turnItUp,
            genres: [Genre.pop],
          ),
        ),
        count: 5,
      );
      expect(tracks, isNotEmpty);
      expect(
        tracks.every(
          (t) => t.artist != 'Tarkan' && t.genres.contains(Genre.pop),
        ),
        isTrue,
      );
    },
  );

  test('saved artists contribute genres to mood discovery', () async {
    final repository = CuratedDiscoveryRepository();
    final tracks = await repository.fetchRound(
      const DiscoveryPreferences(
        taste: TasteProfile(
          references: [
            MusicReference(
              id: 'duman',
              name: 'Duman',
              mood: Mood.turnItUp,
              genres: [Genre.rock],
            ),
          ],
        ),
      ),
      count: 5,
    );
    expect(tracks, isNotEmpty);
    expect(tracks.every((track) => track.genres.contains(Genre.rock)), isTrue);
  });

  test('vocal and rhythm priorities change the ordering', () async {
    final repository = CuratedDiscoveryRepository(latency: Duration.zero);
    const base = DiscoveryPreferences(
      source: DiscoverySource.reference,
      reference: MusicReference(
        id: 'sample',
        name: 'Sample',
        mood: Mood.afterHours,
      ),
      distance: DiscoveryDistance.faraway,
    );
    final vocals = await repository.fetchRound(
      base.copyWith(aspect: ReferenceAspect.vocals),
      count: 11,
    );
    final rhythm = await repository.fetchRound(
      base.copyWith(aspect: ReferenceAspect.rhythm),
      count: 11,
    );
    expect(vocals.first.hasVocals, isTrue);
    expect(
      vocals.map((t) => t.id).toList(),
      isNot(rhythm.map((t) => t.id).toList()),
    );
  });

  test('no alternative and network failures give distinct feedback', () async {
    final repository = _ControlledRepository();
    final discover = DiscoverCubit(repository);
    await discover.startRound();
    await discover.rejectCurrent(TrackFeedback.alreadyKnown);
    expect(discover.state.notice, DiscoverNotice.noAlternative);
    expect(discover.state.currentTrack, first.first);
    repository.fail = true;
    await discover.rejectCurrent(TrackFeedback.alreadyKnown);
    expect(discover.state.notice, DiscoverNotice.requestFailed);
    expect(discover.state.isReplacing, isFalse);
    await discover.close();
  });

  test('feedback in flight cannot replace a different song', () async {
    final repository = _ControlledRepository()..pending = Completer<Track?>();
    final discover = DiscoverCubit(repository);
    await discover.startRound();
    final replacing = discover.rejectCurrent(TrackFeedback.alreadyKnown);
    discover.next();
    expect(discover.state.currentIndex, 0);
    repository.pending!.complete(first.last);
    await replacing;
    expect(discover.state.tracks, [first.last, first[1]]);
    await discover.close();
  });

  test(
    'failed preference change retains the round and its original settings',
    () async {
      final repository = _ControlledRepository();
      final discover = DiscoverCubit(repository);
      await discover.startRound();
      final original = discover.state;
      repository.fail = true;
      await discover.applyPreferences(
        original.preferences.copyWith(distance: DiscoveryDistance.faraway),
      );
      expect(discover.state.preferences, original.preferences);
      expect(discover.state.tracks, original.tracks);
      expect(discover.state.notice, DiscoverNotice.requestFailed);
      await discover.close();
    },
  );

  test(
    'finished rounds are not offered as resumable and summaries count saved songs',
    () async {
      final discover = DiscoverCubit(_ControlledRepository());
      final collection = CollectionCubit();
      await discover.startRound();
      expect(discover.state.canResume, isTrue);
      expect(discover.state.isShortRound, isTrue);
      await collection.save(first.first);
      await collection.save(first.last);
      expect(collection.state.countOf(discover.state.tracks), 1);
      discover.finishRound();
      expect(discover.state.status, DiscoverRoundStatus.finished);
      expect(discover.state.canResume, isFalse);
      await collection.close();
      await discover.close();
    },
  );
}

class _FailingCollectionStore implements ICollectionStore {
  @override
  CollectionSnapshot read() => (tracks: [], shelves: {});
  @override
  Future<void> write(CollectionSnapshot snapshot) async =>
      throw StateError('disk unavailable');
}

class _PendingCollectionStore extends _FailingCollectionStore {
  final writeCompleted = Completer<void>();
  @override
  Future<void> write(CollectionSnapshot snapshot) => writeCompleted.future;
}

class _FailingTasteStore implements ITasteStore {
  @override
  TasteProfile read() => const TasteProfile();
  @override
  Future<void> write(TasteProfile profile) async =>
      throw StateError('disk unavailable');
}

class _ControlledRepository implements IDiscoveryRepository {
  bool fail = false;
  Completer<Track?>? pending;
  @override
  Future<List<Track>> fetchRound(
    DiscoveryPreferences preferences, {
    required int count,
    Set<String> excludeIds = const {},
  }) async {
    if (fail) throw StateError('offline');
    return CuratedDiscoveryRepository.catalog.take(2).toList();
  }

  @override
  Future<Track?> fetchReplacement(
    DiscoveryPreferences preferences, {
    required TrackFeedback feedback,
    required Set<String> excludeIds,
  }) async {
    if (fail) throw StateError('offline');
    return pending?.future;
  }
}
