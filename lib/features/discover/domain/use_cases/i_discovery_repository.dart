import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';

abstract interface class IDiscoveryRepository {
  Future<List<Track>> fetchRound(
    DiscoveryPreferences preferences, {
    required int count,
    Set<String> excludeIds = const {},
  });

  Future<Track?> fetchReplacement(
    DiscoveryPreferences preferences, {
    required TrackFeedback feedback,
    required Set<String> excludeIds,
    String? rejectedTrackId,
  });
}
