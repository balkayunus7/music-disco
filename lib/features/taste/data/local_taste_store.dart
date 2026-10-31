import 'dart:convert';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/domain/use_cases/i_taste_store.dart';

class LocalTasteStore implements ITasteStore {
  LocalTasteStore(this.preferences, {required String userId})
    : key = 'music_taste_v1_$userId';

  final SharedPreferences preferences;
  final String key;

  @override
  TasteProfile read() {
    try {
      final value = preferences.getString(key);
      if (value == null) return const TasteProfile();
      final data = jsonDecode(value) as Map<String, dynamic>;
      final references = <MusicReference>[];
      for (final row in data['references'] as List) {
        try {
          final reference = MusicReference(
            id: row['id'] as String,
            name: row['name'] as String,
            mood: Mood.values.byName(row['mood'] as String),
            imageUrl: row['imageUrl'] as String?,
            genres: _genres(row['genres']),
          );
          if (!references.any((r) => r.id == reference.id)) {
            references.add(reference);
          }
        } on Object {
          continue;
        }
      }
      return TasteProfile(
        genres: _genres(data['genres']),
        isMixed: data['isMixed'] as bool,
        references: references.take(TasteProfile.maxReferences).toList(),
        language:
            MusicLanguage.values
                .where((l) => l.name == data['language'])
                .firstOrNull ??
            MusicLanguage.any,
      );
    } on Object {
      return const TasteProfile();
    }
  }

  List<Genre> _genres(dynamic names) => [
    for (final genre in Genre.values)
      if ((names as List).contains(genre.name)) genre,
  ].take(TasteProfile.maxGenres).toList();

  @override
  Future<void> write(TasteProfile profile) async {
    final saved = await preferences.setString(
      key,
      jsonEncode({
        'genres': profile.genres.map((g) => g.name).toList(),
        'isMixed': profile.isMixed,
        'language': profile.language.name,
        'references': [
          for (final r in profile.references)
            {
              'id': r.id,
              'name': r.name,
              'mood': r.mood.name,
              'imageUrl': r.imageUrl,
              'genres': r.genres.map((g) => g.name).toList(),
            },
        ],
      }),
    );
    if (!saved) throw StateError('Taste could not be saved');
  }
}
