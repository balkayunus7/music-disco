import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';

class MusicReference extends Equatable {
  const MusicReference({
    required this.id,
    required this.name,
    required this.mood,
    this.genres = const [],
    this.imageUrl,
  });
  final String id;
  final String name;
  final Mood mood;
  final List<Genre> genres;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, mood, genres, imageUrl];
}
