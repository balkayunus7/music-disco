import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';

class MockDiscoveryRepository implements IDiscoveryRepository {
  MockDiscoveryRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  static const List<Track> catalog = [
    Track(
      id: 'bonobo-kerala',
      title: 'Kerala',
      artist: 'Bonobo',
      mood: Mood.afterHours,
      noteKey: LocaleKeys.track_note_kerala,
      duration: Duration(minutes: 4, seconds: 5),
      youtubeId: 'S0Q4gqBUs7c',
    ),
    Track(
      id: 'parcels-tieduprightnow',
      title: 'Tieduprightnow',
      artist: 'Parcels',
      mood: Mood.turnItUp,
      noteKey: LocaleKeys.track_note_tieduprightnow,
      duration: Duration(minutes: 4, seconds: 30),
      youtubeId: '_2qsU8FGU_E',
    ),
    Track(
      id: 'tycho-a-walk',
      title: 'A Walk',
      artist: 'Tycho',
      mood: Mood.oldFeeling,
      noteKey: LocaleKeys.track_note_a_walk,
      duration: Duration(minutes: 5, seconds: 13),
      youtubeId: 'SDNA934EEVk',
    ),
    Track(
      id: 'men-i-trust-show-me-how',
      title: 'Show Me How',
      artist: 'Men I Trust',
      mood: Mood.softSide,
      noteKey: LocaleKeys.track_note_show_me_how,
      duration: Duration(minutes: 3, seconds: 35),
      youtubeId: 'OZRYzH0Q0pU',
    ),
    Track(
      id: 'khruangbin-friday-morning',
      title: 'Friday Morning',
      artist: 'Khruangbin',
      mood: Mood.slowDown,
      noteKey: LocaleKeys.track_note_friday_morning,
      duration: Duration(minutes: 3, seconds: 57),
      youtubeId: 'KjQSSYOTXzk',
    ),
    Track(
      id: 'james-blake-retrograde',
      title: 'Retrograde',
      artist: 'James Blake',
      mood: Mood.noRules,
      noteKey: LocaleKeys.track_note_retrograde,
      duration: Duration(minutes: 3, seconds: 43),
      youtubeId: '6p6PcFFUm5I',
    ),
  ];

  static const Set<Mood> _energeticMoods = {Mood.turnItUp, Mood.noRules};
  static const Set<Mood> _calmMoods = {
    Mood.slowDown,
    Mood.softSide,
    Mood.oldFeeling,
  };

  @override
  Future<List<Track>> fetchRound(
    DiscoveryPreferences preferences, {
    required int count,
    Set<String> excludeIds = const {},
  }) async {
    await Future<void>.delayed(latency);
    return _ranked(
      preferences,
    ).where((track) => !excludeIds.contains(track.id)).take(count).toList();
  }

  @override
  Future<Track?> fetchReplacement(
    DiscoveryPreferences preferences, {
    required TrackFeedback feedback,
    required Set<String> excludeIds,
  }) async {
    await Future<void>.delayed(latency);
    final candidates = _ranked(
      preferences,
    ).where((track) => !excludeIds.contains(track.id)).toList();
    if (candidates.isEmpty) return null;

    final preferred = switch (feedback) {
      TrackFeedback.tooCalm => candidates.where(
        (track) => _energeticMoods.contains(track.mood),
      ),
      TrackFeedback.tooLively => candidates.where(
        (track) => _calmMoods.contains(track.mood),
      ),
      TrackFeedback.notMyStyle => candidates.where(
        (track) => track.mood != preferences.anchorMood,
      ),
      TrackFeedback.alreadyKnown => candidates,
    };
    return preferred.isEmpty ? candidates.first : preferred.first;
  }

  List<Track> _ranked(DiscoveryPreferences preferences) {
    final referenceArtist = preferences.activeReference?.artistName;
    int rank(Track track) {
      if (track.artist == referenceArtist) return 99;
      final matchesMood = track.mood == preferences.anchorMood;
      final moodRank = switch (preferences.distance) {
        DiscoveryDistance.close => matchesMood ? 0 : 2,
        DiscoveryDistance.bitDifferent => matchesMood ? 1 : 2,
        DiscoveryDistance.faraway => matchesMood ? 3 : 1,
      };
      final liftsEnergy =
          preferences.direction == DiscoveryDirection.lift &&
          _energeticMoods.contains(track.mood);
      return moodRank * 2 - (liftsEnergy ? 1 : 0);
    }

    final indexed = catalog.indexed.toList()
      ..sort((a, b) {
        final byRank = rank(a.$2).compareTo(rank(b.$2));
        return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
      });
    return [for (final entry in indexed) entry.$2];
  }
}
