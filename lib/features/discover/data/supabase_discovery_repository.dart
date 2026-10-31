import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_feedback_repository.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:supabase/supabase.dart';

class SupabaseDiscoveryRepository
    implements IDiscoveryRepository, IDiscoveryFeedbackRepository {
  SupabaseDiscoveryRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Track>> fetchRound(
    DiscoveryPreferences preferences, {
    required int count,
    Set<String> excludeIds = const {},
  }) => _fetch(preferences, count: count, excludeIds: excludeIds);

  @override
  Future<Track?> fetchReplacement(
    DiscoveryPreferences preferences, {
    required TrackFeedback feedback,
    required Set<String> excludeIds,
    String? rejectedTrackId,
  }) async {
    final tracks = await _fetch(
      preferences,
      count: 1,
      excludeIds: excludeIds,
      feedback: rejectedTrackId == null
          ? null
          : {'trackId': rejectedTrackId, 'kind': feedback.name},
    );
    return tracks.firstOrNull;
  }

  Future<List<Track>> _fetch(
    DiscoveryPreferences preferences, {
    required int count,
    required Set<String> excludeIds,
    Map<String, String>? feedback,
  }) async {
    if (count < 1 || count > 4) throw ArgumentError.value(count, 'count');
    final reference = preferences.activeReference;
    final taste = preferences.taste;
    final result = await _client.functions.invoke(
      'recommend-tracks',
      abortSignal: Future<void>.delayed(const Duration(seconds: 55)),
      body: {
        'action': 'recommend',
        'count': count,
        'excludeIds': excludeIds.take(256).toList(),
        'feedback': feedback,
        'preferences': {
          'source': preferences.source.name,
          'mood': preferences.mood.name,
          'direction': preferences.direction.name,
          'distance': preferences.distance.name,
          'aspect': preferences.aspect.name,
          'reference': reference == null ? null : {'name': reference.name},
          'taste': {
            'language': taste.language.name,
            'genres': taste.isGenreOpen
                ? <String>[]
                : taste.genres.map((genre) => genre.name).toList(),
            'artists': taste.references.map((artist) => artist.name).toList(),
          },
        },
      },
    );
    if (result.status != 200) throw const FormatException('Discovery failed');
    final data = result.data as Map<String, dynamic>;
    final rows = data['tracks'] as List<dynamic>;
    if (rows.length > count) {
      throw const FormatException('Unexpected discovery response');
    }
    final seen = {...excludeIds};
    return [
      for (final row in rows)
        if (_parseTrack(row as Map<String, dynamic>) case final track)
          if (seen.add(track.id) &&
              (taste.language == MusicLanguage.any ||
                  track.language == taste.language))
            track,
    ];
  }

  static Track _parseTrack(Map<String, dynamic> row) {
    final id = row['id'] as String;
    final youtubeId = row['youtubeId'] as String;
    final duration = row['durationSeconds'] as int;
    final energy = (row['energy'] as num).toDouble();
    final title = row['title'] as String;
    final artist = row['artist'] as String;
    final reasons = Map<String, String>.from(row['reasons'] as Map);
    if (!RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(youtubeId) ||
        id != 'yt:$youtubeId' ||
        duration < 30 ||
        duration > 1200 ||
        !energy.isFinite ||
        energy < 0 ||
        energy > 1 ||
        title.trim().isEmpty ||
        title.length > 160 ||
        artist.trim().isEmpty ||
        artist.length > 160 ||
        !['en', 'tr'].every(
          (language) =>
              reasons[language]?.trim().isNotEmpty == true &&
              reasons[language]!.length <= 260,
        )) {
      throw const FormatException('Invalid discovery track');
    }
    return Track(
      id: id,
      title: title,
      artist: artist,
      mood: Mood.values.byName(row['mood'] as String),
      duration: Duration(seconds: duration),
      youtubeId: youtubeId,
      genres: [
        for (final genre in row['genres'] as List)
          Genre.values.byName(genre as String),
      ],
      language: MusicLanguage.values.byName(row['language'] as String),
      energy: energy,
      hasVocals: row['hasVocals'] as bool,
      recommendationReasons: reasons,
    );
  }

  @override
  Future<void> recordSaved(String trackId, {required bool isSaved}) async {
    // Collections may still contain tracks from the previous local catalog.
    if (!trackId.startsWith('yt:')) return;
    final result = await _client.functions.invoke(
      'recommend-tracks',
      abortSignal: Future<void>.delayed(const Duration(seconds: 8)),
      body: {
        'action': 'feedback',
        'feedback': {'trackId': trackId, 'kind': isSaved ? 'saved' : 'removed'},
      },
    );
    if (result.status != 200 || result.data['success'] != true) {
      throw const FormatException('Feedback failed');
    }
  }
}
