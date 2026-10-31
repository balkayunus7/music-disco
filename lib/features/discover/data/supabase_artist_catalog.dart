import 'package:music_disco/core/util/music_routes.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_reference_catalog.dart';
import 'package:supabase/supabase.dart';

class SupabaseArtistCatalog implements IReferenceCatalog {
  SupabaseArtistCatalog(this._client);

  final SupabaseClient _client;

  static const int resultLimit = 12;
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static const Map<String, Genre> _genreKeys = {
    'alternative': Genre.alternative,
    'pop': Genre.pop,
    'electronic': Genre.electronic,
    'rock': Genre.rock,
    'hip_hop': Genre.hipHop,
    'rnb_soul': Genre.rnbSoul,
    'jazz': Genre.jazz,
    'classical': Genre.classical,
  };

  static const Map<Genre, Mood> _genreMoods = {
    Genre.electronic: Mood.afterHours,
    Genre.rock: Mood.turnItUp,
    Genre.pop: Mood.softSide,
    Genre.rnbSoul: Mood.slowDown,
    Genre.classical: Mood.slowDown,
    Genre.jazz: Mood.oldFeeling,
    Genre.alternative: Mood.oldFeeling,
    Genre.hipHop: Mood.noRules,
  };

  @override
  Future<List<MusicReference>> search(String query) async {
    final rows = await _client.rpc<List<dynamic>>(
      searchArtistsFunction,
      params: {'query': query.trim(), 'result_limit': resultLimit},
    );
    return [for (final row in rows.cast<Map<String, dynamic>>()) _fromRow(row)];
  }

  @override
  Future<List<MusicReference>> findByIds(Set<String> ids) async {
    // Older local catalogs used slugs; they cannot be queried as UUIDs.
    final catalogIds = ids.where(_uuid.hasMatch).toList();
    if (catalogIds.isEmpty) return const [];
    final rows = await _client
        .from('artists')
        .select('id, name, genres, image_url')
        .inFilter('id', catalogIds);
    return [for (final row in rows) _fromRow(row)];
  }

  MusicReference _fromRow(Map<String, dynamic> row) {
    final id = row['id'] as String;
    final genres = [
      for (final key in (row['genres'] as List<dynamic>? ?? const []))
        ?_genreKeys[key],
    ];
    return MusicReference(
      id: id,
      name: row['name'] as String,
      genres: genres,
      mood: genres.isEmpty ? Mood.afterHours : _genreMoods[genres.first]!,
      imageUrl: row['image_url'] as String?,
    );
  }
}
