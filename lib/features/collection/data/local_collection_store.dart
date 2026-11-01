import 'dart:convert';

import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/collection/domain/use_cases/i_collection_store.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';

typedef _ShelfData = ({
  List<CollectionShelf> shelves,
  Map<String, String> assignments,
});

class LocalCollectionStore implements ICollectionStore {
  LocalCollectionStore(this._preferences, {required String userId})
    : _key = 'music_collection_v1_$userId';
  final SharedPreferences _preferences;
  final String _key;

  static const Map<String, String> _legacyShelfNames = {
    'nightWalk': 'Night walk',
    'slowMornings': 'Slow mornings',
  };

  @override
  CollectionSnapshot read() {
    final tracks = <Track>[];
    var shelfData = (
      shelves: <CollectionShelf>[],
      assignments: <String, String>{},
    );
    try {
      final value = _preferences.getString(_key);
      if (value != null) {
        final data = jsonDecode(value) as Map<String, dynamic>;
        for (final row in data['tracks'] as List) {
          final track = _decodeTrack(row);
          if (track != null && !tracks.any((saved) => saved.id == track.id)) {
            tracks.add(track);
          }
        }
        shelfData = _decodeShelves(data, tracks);
      }
    } on Object {
      // Keep readable entries; never replace corrupt storage during startup.
    }
    return (
      tracks: tracks,
      shelves: shelfData.shelves,
      assignments: shelfData.assignments,
    );
  }

  @override
  Future<void> write(CollectionSnapshot snapshot) async {
    final saved = await _preferences.setString(
      _key,
      jsonEncode({
        'tracks': snapshot.tracks.map(_encodeTrack).toList(),
        'shelves': [
          for (final shelf in snapshot.shelves)
            {'id': shelf.id, 'name': shelf.name},
        ],
        'assignments': snapshot.assignments,
      }),
    );
    if (!saved) throw StateError('Collection could not be saved');
  }

  Track? _decodeTrack(dynamic row) {
    try {
      return Track(
        id: row['id'] as String,
        title: row['title'] as String,
        artist: row['artist'] as String,
        mood: Mood.values.byName(row['mood'] as String),
        noteKey: row['noteKey'] as String,
        duration: Duration(milliseconds: row['duration'] as int),
        youtubeId: row['youtubeId'] as String,
        genres: [
          for (final genre in Genre.values)
            if ((row['genres'] as List? ?? []).contains(genre.name)) genre,
        ],
        language:
            MusicLanguage.values
                .where((language) => language.name == row['language'])
                .firstOrNull ??
            MusicLanguage.any,
        energy: (row['energy'] as num?)?.toDouble() ?? 0.5,
        hasVocals: row['hasVocals'] as bool? ?? true,
        recommendationReasons: Map<String, String>.from(
          row['recommendationReasons'] as Map? ?? const {},
        ),
      );
    } on Object {
      return null;
    }
  }

  Map<String, dynamic> _encodeTrack(Track track) => {
    'id': track.id,
    'title': track.title,
    'artist': track.artist,
    'mood': track.mood.name,
    'noteKey': track.noteKey,
    'duration': track.duration.inMilliseconds,
    'youtubeId': track.youtubeId,
    'genres': track.genres.map((genre) => genre.name).toList(),
    'language': track.language.name,
    'energy': track.energy,
    'hasVocals': track.hasVocals,
    'recommendationReasons': track.recommendationReasons,
  };

  _ShelfData _decodeShelves(Map<String, dynamic> data, List<Track> tracks) {
    try {
      return _readShelves(data, tracks);
    } on Object {
      return (shelves: <CollectionShelf>[], assignments: <String, String>{});
    }
  }

  _ShelfData _readShelves(Map<String, dynamic> data, List<Track> tracks) {
    final shelves = <CollectionShelf>[];
    final assignments = <String, String>{};
    final raw = data['shelves'];
    bool hasTrack(String id) => tracks.any((track) => track.id == id);
    if (raw is Map<String, dynamic>) {
      for (final entry in raw.entries) {
        final name = _legacyShelfNames[entry.value];
        if (name == null || !hasTrack(entry.key)) continue;
        final id = 'legacy_${entry.value}';
        if (!shelves.any((shelf) => shelf.id == id)) {
          shelves.add(CollectionShelf(id: id, name: name));
        }
        assignments[entry.key] = id;
      }
      return (shelves: shelves, assignments: assignments);
    }
    for (final row in raw as List? ?? const []) {
      final id = row['id'];
      final name = row['name'];
      if (id is! String || name is! String) continue;
      if (shelves.any((shelf) => shelf.id == id)) continue;
      shelves.add(CollectionShelf(id: id, name: name));
    }
    final stored = data['assignments'];
    if (stored is Map<String, dynamic>) {
      for (final entry in stored.entries) {
        final shelfId = entry.value;
        if (shelfId is! String || !hasTrack(entry.key)) continue;
        if (shelves.any((shelf) => shelf.id == shelfId)) {
          assignments[entry.key] = shelfId;
        }
      }
    }
    return (shelves: shelves, assignments: assignments);
  }
}
