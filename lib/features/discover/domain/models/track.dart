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
  });

  final String id;
  final String title;
  final String artist;

  /// The disc the track is presented on.
  final Mood mood;

  /// Translation key of the short editorial note shown under the artist.
  final String noteKey;
  final Duration duration;

  @override
  List<Object?> get props => [id, title, artist, mood, noteKey, duration];
}
