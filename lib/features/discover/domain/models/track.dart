import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';

class Track extends Equatable {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.mood,
    required this.noteKey,
    required this.duration,
    required this.youtubeId,
  });

  final String id;
  final String title;
  final String artist;

  final Mood mood;

  final String noteKey;
  final Duration duration;

  final String youtubeId;

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    mood,
    noteKey,
    duration,
    youtubeId,
  ];
}
