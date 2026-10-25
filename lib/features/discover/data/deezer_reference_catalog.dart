import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_reference_catalog.dart';

class DeezerCatalogException implements Exception {
  const DeezerCatalogException(this.message);

  final String message;

  @override
  String toString() => 'DeezerCatalogException: $message';
}

class DeezerReferenceCatalog implements IReferenceCatalog {
  DeezerReferenceCatalog(
    this._client, {
    this.timeout = const Duration(seconds: 8),
  });

  final http.Client _client;
  final Duration timeout;

  static const String _host = 'api.deezer.com';
  static const int resultLimit = 6;
  static const int _mixedLimit = 3;
  static const int _candidatePool = 15;

  @override
  Future<List<MusicReference>> search(
    String query, {
    ReferenceKind? kind,
  }) async {
    final needle = query.trim();
    if (kind != null) return _fetch(needle, kind, resultLimit);
    final results = await Future.wait([
      _fetch(needle, ReferenceKind.artist, _mixedLimit),
      _fetch(needle, ReferenceKind.song, _mixedLimit),
    ]);
    return [...results[0], ...results[1]];
  }

  Future<List<MusicReference>> _fetch(
    String query,
    ReferenceKind kind,
    int limit,
  ) async {
    final type = kind == ReferenceKind.artist ? 'artist' : 'track';
    final uri = query.isEmpty
        ? Uri.https(_host, '/chart/0/${type}s', {'limit': '$limit'})
        : Uri.https(_host, '/search/$type', {
            'q': query,
            'limit': '$_candidatePool',
          });
    final items = await _getData(uri);
    final references = [
      for (final item in items)
        if (kind == ReferenceKind.artist) _artist(item) else _track(item),
    ];
    if (query.isNotEmpty) {
      references.sort((a, b) => b.$2.compareTo(a.$2));
    }
    return [for (final reference in references.take(limit)) reference.$1];
  }

  Future<List<Map<String, dynamic>>> _getData(Uri uri) async {
    final response = await _client.get(uri).timeout(timeout);
    if (response.statusCode != 200) {
      throw DeezerCatalogException('HTTP ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map<String, dynamic>) {
      throw const DeezerCatalogException('Unexpected response');
    }
    final error = body['error'];
    if (error is Map) {
      throw DeezerCatalogException('${error['type']}: ${error['message']}');
    }
    final data = body['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  (MusicReference, int) _artist(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return (
      MusicReference(
        id: 'deezer-artist-$id',
        name: json['name'] as String,
        kind: ReferenceKind.artist,
        mood: _moodFor(id),
        imageUrl: json['picture_medium'] as String?,
      ),
      json['nb_fan'] as int? ?? 0,
    );
  }

  (MusicReference, int) _track(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final artist = json['artist'] as Map<String, dynamic>?;
    final album = json['album'] as Map<String, dynamic>?;
    return (
      MusicReference(
        id: 'deezer-track-$id',
        name: (json['title_short'] ?? json['title']) as String,
        artist: artist?['name'] as String?,
        kind: ReferenceKind.song,
        mood: _moodFor(id),
        imageUrl: album?['cover_medium'] as String?,
      ),
      json['rank'] as int? ?? 0,
    );
  }

  static Mood _moodFor(int id) => Mood.values[id % Mood.values.length];
}
