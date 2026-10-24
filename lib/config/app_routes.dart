class AppRoutes {
  AppRoutes._();

  /// Auth not required
  static const Set<String> publicRoutes = {AppRoutes.splash};

  // Auth
  static const String splash = '/';

  // Discover branch
  static const String discover = '/discover';
  static const String direction = '$discover/direction';
  static const String session = '$direction/session';

  // Collection branch
  static const String collection = '/collection';

  /// Landing route after authentication.
  static const String home = discover;
}
