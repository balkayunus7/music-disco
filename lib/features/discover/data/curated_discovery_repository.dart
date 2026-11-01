import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/reference_aspect.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';

class CuratedDiscoveryRepository implements IDiscoveryRepository {
  CuratedDiscoveryRepository({this.latency = Duration.zero});
  final Duration latency;

  static const List<Track> catalog = [
    Track(
      id: 'bonobo-kerala',
      genres: [Genre.electronic],
      language: MusicLanguage.any,
      energy: 0.65,
      hasVocals: false,
      title: 'Kerala',
      artist: 'Bonobo',
      mood: Mood.afterHours,
      noteKey: LocaleKeys.track_note_kerala,
      duration: Duration(minutes: 4, seconds: 5),
      youtubeId: 'S0Q4gqBUs7c',
    ),
    Track(
      id: 'parcels-tieduprightnow',
      genres: [Genre.pop, Genre.alternative],
      language: MusicLanguage.english,
      energy: 0.85,
      title: 'Tieduprightnow',
      artist: 'Parcels',
      mood: Mood.turnItUp,
      noteKey: LocaleKeys.track_note_tieduprightnow,
      duration: Duration(minutes: 4, seconds: 30),
      youtubeId: '_2qsU8FGU_E',
    ),
    Track(
      id: 'tycho-a-walk',
      genres: [Genre.electronic],
      language: MusicLanguage.any,
      energy: 0.35,
      hasVocals: false,
      title: 'A Walk',
      artist: 'Tycho',
      mood: Mood.oldFeeling,
      noteKey: LocaleKeys.track_note_a_walk,
      duration: Duration(minutes: 5, seconds: 13),
      youtubeId: 'SDNA934EEVk',
    ),
    Track(
      id: 'men-i-trust-show-me-how',
      genres: [Genre.alternative, Genre.pop],
      language: MusicLanguage.english,
      energy: 0.25,
      title: 'Show Me How',
      artist: 'Men I Trust',
      mood: Mood.softSide,
      noteKey: LocaleKeys.track_note_show_me_how,
      duration: Duration(minutes: 3, seconds: 35),
      youtubeId: 'OZRYzH0Q0pU',
    ),
    Track(
      id: 'khruangbin-friday-morning',
      genres: [Genre.alternative, Genre.rnbSoul],
      language: MusicLanguage.any,
      energy: 0.3,
      hasVocals: false,
      title: 'Friday Morning',
      artist: 'Khruangbin',
      mood: Mood.slowDown,
      noteKey: LocaleKeys.track_note_friday_morning,
      duration: Duration(minutes: 3, seconds: 57),
      youtubeId: 'KjQSSYOTXzk',
    ),
    Track(
      id: 'james-blake-retrograde',
      genres: [Genre.electronic, Genre.rnbSoul],
      language: MusicLanguage.english,
      energy: 0.55,
      title: 'Retrograde',
      artist: 'James Blake',
      mood: Mood.noRules,
      noteKey: LocaleKeys.track_note_retrograde,
      duration: Duration(minutes: 3, seconds: 43),
      youtubeId: '6p6PcFFUm5I',
    ),
    // Official videos: https://www.tarkan.com/video/
    Track(
      id: 'tarkan-kuzu-kuzu',
      title: 'Kuzu Kuzu',
      artist: 'Tarkan',
      mood: Mood.turnItUp,
      noteKey: LocaleKeys.track_note_turkish_pop,
      duration: Duration.zero,
      youtubeId: 'NAHRpEqgcL4',
      genres: [Genre.pop],
      language: MusicLanguage.turkish,
      energy: 0.8,
    ),
    Track(
      id: 'tarkan-simarik',
      title: 'Şımarık',
      artist: 'Tarkan',
      mood: Mood.noRules,
      noteKey: LocaleKeys.track_note_turkish_pop,
      duration: Duration.zero,
      youtubeId: 'cpp69ghR1IM',
      genres: [Genre.pop],
      language: MusicLanguage.turkish,
      energy: 0.9,
    ),
    Track(
      id: 'tarkan-kis-gunesi',
      title: 'Kış Güneşi',
      artist: 'Tarkan',
      mood: Mood.oldFeeling,
      noteKey: LocaleKeys.track_note_turkish_calm,
      duration: Duration.zero,
      youtubeId: '-CxauCeQ_SQ',
      genres: [Genre.pop],
      language: MusicLanguage.turkish,
      energy: 0.25,
    ),
    Track(
      id: 'tarkan-beni-cok-sev',
      title: 'Beni Çok Sev',
      artist: 'Tarkan',
      mood: Mood.softSide,
      noteKey: LocaleKeys.track_note_turkish_calm,
      duration: Duration.zero,
      youtubeId: 'NoV-_VupGHU',
      genres: [Genre.pop],
      language: MusicLanguage.turkish,
      energy: 0.35,
    ),
    // https://www.dumanlive.com/video/senden-daha-guzel-c0a6
    Track(
      id: 'duman-senden-daha-guzel',
      title: 'Senden Daha Güzel',
      artist: 'Duman',
      mood: Mood.turnItUp,
      noteKey: LocaleKeys.track_note_turkish_rock,
      duration: Duration.zero,
      youtubeId: '3bfkyXtuIXk',
      genres: [Genre.rock, Genre.alternative],
      language: MusicLanguage.turkish,
      energy: 0.75,
    ),
  ];

  @override
  Future<List<Track>> fetchRound(
    DiscoveryPreferences preferences, {
    required int count,
    Set<String> excludeIds = const {},
  }) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return _ranked(preferences, excludeIds).take(count).toList();
  }

  @override
  Future<Track?> fetchReplacement(
    DiscoveryPreferences preferences, {
    required TrackFeedback feedback,
    required Set<String> excludeIds,
    String? rejectedTrackId,
  }) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final candidates = _ranked(preferences, excludeIds);
    final matches = candidates.where(
      (track) => switch (feedback) {
        TrackFeedback.tooCalm => track.energy >= 0.6,
        TrackFeedback.tooLively => track.energy <= 0.4,
        TrackFeedback.notMyStyle => track.mood != preferences.anchorMood,
        TrackFeedback.alreadyKnown => true,
      },
    );
    return matches.firstOrNull;
  }

  List<Track> _ranked(DiscoveryPreferences preferences, Set<String> excluded) {
    final reference = preferences.activeReference;
    final taste = preferences.taste;
    final tasteGenres = taste.isGenreOpen
        ? taste.references.expand((artist) => artist.genres).toSet().toList()
        : taste.genres;
    final preferredGenres = reference?.genres.isNotEmpty == true
        ? reference!.genres
        : tasteGenres;
    double score(Track track) {
      final genreMatch = preferredGenres.any(track.genres.contains);
      final moodMatch = track.mood == preferences.anchorMood;
      final similarity = (genreMatch ? 4.0 : 0.0) + (moodMatch ? 3.0 : 0.0);
      var value = switch (preferences.distance) {
        DiscoveryDistance.close => similarity,
        DiscoveryDistance.bitDifferent => genreMatch != moodMatch ? 5.0 : 1.0,
        DiscoveryDistance.faraway => 7.0 - similarity,
      };
      if (preferences.direction == DiscoveryDirection.lift) {
        value += track.energy * 4;
      }
      if (reference != null) {
        value += switch (preferences.aspect) {
          ReferenceAspect.atmosphere => moodMatch ? 4 : 0,
          ReferenceAspect.vocals => track.hasVocals ? 4 : -4,
          ReferenceAspect.rhythm => track.energy * 4,
          ReferenceAspect.overallStyle => genreMatch ? 4 : 0,
        };
      }
      if (taste.references.any(
        (r) => r.name.toLowerCase() == track.artist.toLowerCase(),
      )) {
        value += 1;
      }
      return value;
    }

    final candidates = catalog
        .where(
          (track) =>
              !excluded.contains(track.id) &&
              (preferences.distance != DiscoveryDistance.close ||
                  preferredGenres.isEmpty ||
                  preferredGenres.any(track.genres.contains)) &&
              track.artist.toLowerCase() != reference?.name.toLowerCase() &&
              (taste.language == MusicLanguage.any ||
                  track.language == taste.language),
        )
        .indexed
        .toList();
    candidates.sort((a, b) {
      final compared = score(b.$2).compareTo(score(a.$2));
      return compared != 0 ? compared : a.$1.compareTo(b.$1);
    });
    return [for (final entry in candidates) entry.$2];
  }
}
