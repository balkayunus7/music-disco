class AppRoutes {
  AppRoutes._();

  /// Auth not required
  static const Set<String> publicRoutes = {AppRoutes.splash};

  // Auth
  static const String splash = '/';

  static const String discover = '/discover';
  static const String direction = '$discover/direction';
  static const String session = '$direction/session';

  static const String collection = '/collection';

  static const String home = discover;
}
