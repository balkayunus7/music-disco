class AppRoutes {
  AppRoutes._();

  /// Auth not required
  static const Set<String> publicRoutes = {AppRoutes.splash};

  // Auth
  static const String splash = '/';

  // Home
  static const String home = '/home';
}
