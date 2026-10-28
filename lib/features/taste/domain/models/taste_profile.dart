import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';

class TasteProfile extends Equatable {
  const TasteProfile({
    this.genres = const [],
    this.isMixed = true,
    this.references = const [],
    this.language = MusicLanguage.any,
  });

  static const int maxGenres = 3;
  static const int maxReferences = 3;

  final List<Genre> genres;
  final bool isMixed;
  final List<MusicReference> references;
  final MusicLanguage language;

  bool get isGenreOpen => isMixed || genres.isEmpty;
  bool get isGenreFull => genres.length >= maxGenres;
  bool get isReferenceFull => references.length >= maxReferences;

  bool hasReference(String id) =>
      references.any((reference) => reference.id == id);

  TasteProfile copyWith({
    List<Genre>? genres,
    bool? isMixed,
    List<MusicReference>? references,
    MusicLanguage? language,
  }) {
    return TasteProfile(
      genres: genres ?? this.genres,
      isMixed: isMixed ?? this.isMixed,
      references: references ?? this.references,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [genres, isMixed, references, language];
}
