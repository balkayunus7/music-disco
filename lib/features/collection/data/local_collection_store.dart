import 'dart:convert';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/collection/domain/use_cases/i_collection_store.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';

class LocalCollectionStore implements ICollectionStore {
  LocalCollectionStore(this.preferences, {required String userId})
    : key = 'music_collection_v1_$userId';

  final SharedPreferences preferences;
  final String key;

  @override
  CollectionSnapshot read() {
    final tracks = <Track>[];
    final shelves = <String, CollectionShelf>{};
    try {
      final value = preferences.getString(key);
      if (value == null) return (tracks: tracks, shelves: shelves);
      final data = jsonDecode(value) as Map<String, dynamic>;
      for (final row in data['tracks'] as List) {
        // A damaged entry must not hide the rest of a listener's collection.
        try {
          final track = Track(
            id: row['id'] as String,
            title: row['title'] as String,
            artist: row['artist'] as String,
            mood: Mood.values.byName(row['mood'] as String),
            noteKey: row['noteKey'] as String,
            duration: Duration(milliseconds: row['duration'] as int),
            youtubeId: row['youtubeId'] as String,
            genres: [
              for (final g in Genre.values)
                if ((row['genres'] as List? ?? []).contains(g.name)) g,
            ],
            language:
                MusicLanguage.values
                    .where((l) => l.name == row['language'])
                    .firstOrNull ??
                MusicLanguage.any,
            energy: (row['energy'] as num?)?.toDouble() ?? 0.5,
            hasVocals: row['hasVocals'] as bool? ?? true,
          );
          if (!tracks.any((saved) => saved.id == track.id)) tracks.add(track);
        } on Object {
          continue;
        }
      }
      for (final entry in (data['shelves'] as Map<String, dynamic>).entries) {
        if (!tracks.any((track) => track.id == entry.key)) continue;
        final shelf = CollectionShelf.values
            .where((s) => s.name == entry.value)
            .firstOrNull;
        if (shelf != null) shelves[entry.key] = shelf;
      }
    } on Object {
      // Keep readable entries; never replace corrupt storage during startup.
    }
    return (tracks: tracks, shelves: shelves);
  }

  @override
  Future<void> write(CollectionSnapshot snapshot) async {
    final saved = await preferences.setString(
      key,
      jsonEncode({
        'tracks': [
          for (final t in snapshot.tracks)
            {
              'genres': t.genres.map((g) => g.name).toList(),
              'language': t.language.name,
              'energy': t.energy,
              'hasVocals': t.hasVocals,
              'id': t.id,
              'title': t.title,
              'artist': t.artist,
              'mood': t.mood.name,
              'noteKey': t.noteKey,
              'duration': t.duration.inMilliseconds,
              'youtubeId': t.youtubeId,
            },
        ],
        'shelves': snapshot.shelves.map(
          (id, shelf) => MapEntry(id, shelf.name),
        ),
      }),
    );
    if (!saved) throw StateError('Collection could not be saved');
  }
}
