import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';

class Track extends Equatable {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.mood,
    this.noteKey = '',
    required this.duration,
    required this.youtubeId,
    this.genres = const [],
    this.language = MusicLanguage.any,
    this.energy = 0.5,
    this.hasVocals = true,
    this.recommendationReasons = const {},
  });

  final List<Genre> genres;
  final MusicLanguage language;
  final double energy;
  final bool hasVocals;
  final String id;
  final String title;
  final String artist;
  final Mood mood;
  final String noteKey;
  final Duration duration;
  final String youtubeId;
  final Map<String, String> recommendationReasons;

  String? recommendationReason(String languageCode) =>
      recommendationReasons[languageCode] ?? recommendationReasons['en'];

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    mood,
    noteKey,
    duration,
    youtubeId,
    genres,
    language,
    energy,
    hasVocals,
    recommendationReasons,
  ];
}
