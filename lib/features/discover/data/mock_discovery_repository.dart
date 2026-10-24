import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';

/// Local catalog used until the recommendation backend exists. Ordering is
/// deterministic so the UI and tests are reproducible.
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
      duration: Duration(minutes: 3, seconds: 57),
    ),
    Track(
      id: 'parcels-tieduprightnow',
      title: 'Tieduprightnow',
      artist: 'Parcels',
      mood: Mood.turnItUp,
      noteKey: LocaleKeys.track_note_tieduprightnow,
      duration: Duration(minutes: 4, seconds: 30),
    ),
    Track(
      id: 'tycho-a-walk',
      title: 'A Walk',
      artist: 'Tycho',
      mood: Mood.oldFeeling,
      noteKey: LocaleKeys.track_note_a_walk,
      duration: Duration(minutes: 5, seconds: 13),
    ),
    Track(
      id: 'men-i-trust-show-me-how',
      title: 'Show Me How',
      artist: 'Men I Trust',
      mood: Mood.softSide,
      noteKey: LocaleKeys.track_note_show_me_how,
      duration: Duration(minutes: 3, seconds: 35),
    ),
    Track(
      id: 'khruangbin-friday-morning',
      title: 'Friday Morning',
      artist: 'Khruangbin',
      mood: Mood.slowDown,
      noteKey: LocaleKeys.track_note_friday_morning,
      duration: Duration(minutes: 3, seconds: 57),
    ),
    Track(
      id: 'james-blake-retrograde',
      title: 'Retrograde',
      artist: 'James Blake',
      mood: Mood.noRules,
      noteKey: LocaleKeys.track_note_retrograde,
      duration: Duration(minutes: 3, seconds: 43),
    ),
    Track(
      id: 'jungle-busy-earnin',
      title: "Busy Earnin'",
      artist: 'Jungle',
      mood: Mood.turnItUp,
      noteKey: LocaleKeys.track_note_busy_earnin,
      duration: Duration(minutes: 3, seconds: 2),
    ),
    Track(
      id: 'nujabes-aruarian-dance',
      title: 'Aruarian Dance',
      artist: 'Nujabes',
      mood: Mood.oldFeeling,
      noteKey: LocaleKeys.track_note_aruarian_dance,
      duration: Duration(minutes: 4, seconds: 27),
    ),
    Track(
      id: 'mac-demarco-chamber-of-reflection',
      title: 'Chamber of Reflection',
      artist: 'Mac DeMarco',
      mood: Mood.softSide,
      noteKey: LocaleKeys.track_note_chamber_of_reflection,
      duration: Duration(minutes: 3, seconds: 51),
    ),
    Track(
      id: 'bonobo-cirrus',
      title: 'Cirrus',
      artist: 'Bonobo',
      mood: Mood.slowDown,
      noteKey: LocaleKeys.track_note_cirrus,
      duration: Duration(minutes: 5, seconds: 49),
    ),
    Track(
      id: 'moderat-a-new-error',
      title: 'A New Error',
      artist: 'Moderat',
      mood: Mood.afterHours,
      noteKey: LocaleKeys.track_note_a_new_error,
      duration: Duration(minutes: 5, seconds: 47),
    ),
    Track(
      id: 'glass-animals-gooey',
      title: 'Gooey',
      artist: 'Glass Animals',
      mood: Mood.noRules,
      noteKey: LocaleKeys.track_note_gooey,
      duration: Duration(minutes: 4, seconds: 49),
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
        (track) => track.mood != preferences.mood,
      ),
      TrackFeedback.alreadyKnown => candidates,
    };
    return preferred.isEmpty ? candidates.first : preferred.first;
  }

  List<Track> _ranked(DiscoveryPreferences preferences) {
    int rank(Track track) {
      final matchesMood = track.mood == preferences.mood;
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
