import 'dart:convert';

import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/domain/use_cases/i_taste_store.dart';

class LocalTasteStore implements ITasteStore {
  LocalTasteStore(this._preferences, {required String userId})
    : _key = 'music_taste_v1_$userId';
  final SharedPreferences _preferences;
  final String _key;

  @override
  TasteProfile read() {
    try {
      final value = _preferences.getString(_key);
      if (value == null) return const TasteProfile();
      final data = jsonDecode(value) as Map<String, dynamic>;
      final references = <MusicReference>[];
      for (final row in data['references'] as List) {
        final reference = _decodeReference(row);
        if (reference != null && !references.any((r) => r.id == reference.id)) {
          references.add(reference);
        }
      }
      return TasteProfile(
        genres: _decodeGenres(data['genres']),
        isMixed: data['isMixed'] as bool,
        references: references.take(TasteProfile.maxReferences).toList(),
        language:
            MusicLanguage.values
                .where((language) => language.name == data['language'])
                .firstOrNull ??
            MusicLanguage.any,
      );
    } on Object {
      return const TasteProfile();
    }
  }

  @override
  Future<void> write(TasteProfile profile) async {
    final saved = await _preferences.setString(
      _key,
      jsonEncode({
        'genres': profile.genres.map((genre) => genre.name).toList(),
        'isMixed': profile.isMixed,
        'language': profile.language.name,
        'references': profile.references.map(_encodeReference).toList(),
      }),
    );
    if (!saved) throw StateError('Taste could not be saved');
  }

  MusicReference? _decodeReference(dynamic row) {
    try {
      return MusicReference(
        id: row['id'] as String,
        name: row['name'] as String,
        mood: Mood.values.byName(row['mood'] as String),
        imageUrl: row['imageUrl'] as String?,
        genres: _decodeGenres(row['genres']),
      );
    } on Object {
      return null;
    }
  }

  Map<String, dynamic> _encodeReference(MusicReference reference) => {
    'id': reference.id,
    'name': reference.name,
    'mood': reference.mood.name,
    'imageUrl': reference.imageUrl,
    'genres': reference.genres.map((genre) => genre.name).toList(),
  };

  List<Genre> _decodeGenres(dynamic names) => [
    for (final genre in Genre.values)
      if ((names as List).contains(genre.name)) genre,
  ].take(TasteProfile.maxGenres).toList();
}
