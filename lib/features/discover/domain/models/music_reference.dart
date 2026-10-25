import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';

enum ReferenceKind { artist, song }

class MusicReference extends Equatable {
  const MusicReference({
    required this.id,
    required this.name,
    required this.kind,
    required this.mood,
    this.artist,
    this.imageUrl,
  });

  final String id;
  final String name;
  final ReferenceKind kind;
  final Mood mood;
  final String? artist;
  final String? imageUrl;

  String get artistName => artist ?? name;

  @override
  List<Object?> get props => [id, name, kind, mood, artist, imageUrl];
}
