class AppRoutes {
  AppRoutes._();

  /// Auth not required
  static const Set<String> publicRoutes = {AppRoutes.splash};

  // Auth
  static const String splash = '/';

  static const String discover = '/discover';

  static const String mood = '$discover/mood';
  static const String moodDirection = '$mood/direction';
  static const String moodSession = '$moodDirection/session';

  static const String reference = '$discover/reference';
  static const String referenceDirection = '$reference/direction';
  static const String referenceSession = '$referenceDirection/session';

  static const String taste = '$discover/taste';
  static const String tasteGenres = '$taste/genres';
  static const String tasteReferences = '$taste/references';

  static const String collection = '/collection';

  static const String home = discover;

  static const Set<String> fullscreenRoutes = {tasteGenres, tasteReferences};
}
