class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const Set<String> publicRoutes = {splash};

  static const String moodSegment = 'mood';
  static const String referenceSegment = 'reference';
  static const String tasteSegment = 'taste';
  static const String genresSegment = 'genres';
  static const String referencesSegment = 'references';
  static const String directionSegment = 'direction';
  static const String loadingSegment = 'loading';
  static const String sessionSegment = 'session';

  static const String discover = '/discover';

  static const String mood = '$discover/$moodSegment';
  static const String moodDirection = '$mood/$directionSegment';
  static const String moodLoading = '$moodDirection/$loadingSegment';
  static const String moodSession = '$moodDirection/$sessionSegment';

  static const String reference = '$discover/$referenceSegment';
  static const String referenceDirection = '$reference/$directionSegment';
  static const String referenceLoading = '$referenceDirection/$loadingSegment';
  static const String referenceSession = '$referenceDirection/$sessionSegment';

  static const String taste = '$discover/$tasteSegment';
  static const String tasteGenres = '$taste/$genresSegment';
  static const String tasteReferences = '$taste/$referencesSegment';

  static const String collection = '/collection';
  static const String settings = '/settings';
  static const String settingsTaste = '$settings/$tasteSegment';
  static const String settingsTasteGenres = '$settingsTaste/$genresSegment';
  static const String settingsTasteReferences =
      '$settingsTaste/$referencesSegment';

  static const String home = discover;

  static const Set<String> fullscreenRoutes = {
    moodLoading,
    referenceLoading,
    tasteGenres,
    tasteReferences,
    settingsTasteGenres,
    settingsTasteReferences,
  };
}
