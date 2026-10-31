import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';

extension MusicLanguageStyle on MusicLanguage {
  String get labelKey => switch (this) {
    MusicLanguage.any => LocaleKeys.language_any,
    MusicLanguage.turkish => LocaleKeys.language_turkish,
    MusicLanguage.english => LocaleKeys.language_english,
  };
}

extension TasteProfileStyle on TasteProfile {
  List<String> get genreLabels => isGenreOpen
      ? [LocaleKeys.taste_mixed.tr()]
      : [for (final genre in genres) genre.labelKey.tr()];

  List<String> get startingGenreLabels => isGenreOpen
      ? [LocaleKeys.studio_mixed_sounds.tr()]
      : [for (final genre in genres) genre.labelKey.tr()];

  String get startingPoint => [
    ...startingGenreLabels,
    for (final reference in references) reference.name,
  ].join(' · ');

  String get selectionLabel => isMixed
      ? LocaleKeys.taste_genres_open.tr()
      : genres.isEmpty
      ? LocaleKeys.taste_genres_none.tr()
      : LocaleKeys.taste_genres_count.tr(
          args: ['${genres.length}', '${TasteProfile.maxGenres}'],
        );

  String get genreStatus => isMixed
      ? LocaleKeys.taste_genres_open_status.tr()
      : LocaleKeys.taste_genres_status.tr(
          args: ['${genres.length}', '${TasteProfile.maxGenres}'],
        );

  String get referenceStatus => LocaleKeys.taste_references_count.tr(
    args: ['${references.length}', '${TasteProfile.maxReferences}'],
  );
}
