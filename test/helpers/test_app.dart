import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/color_theme/color_theme_bloc.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/color_theme/color_theme_option.dart';
import 'package:mobile_boilerplate/infrastructure/color_theme/shared_pref_color_theme_cache.dart';
import 'package:mobile_boilerplate/presentation/app_colors.dart';
import 'package:music_disco/config/app_router.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/util/custom_app_colors.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';

/// Reads translations straight from the project files so tests do not
/// depend on asset bundle timing.
class FileTranslationLoader extends AssetLoader {
  const FileTranslationLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File('assets/translations/${locale.languageCode}.json');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

/// Loads the real fonts so text metrics and screenshots match the app.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> assets) async {
    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }

  const montserrat = 'packages/mobile_boilerplate/assets/fonts/Montserrat';
  await load('ArchivoBlack', ['assets/fonts/ArchivoBlack-Regular.ttf']);
  await load('packages/mobile_boilerplate/Montserrat', [
    for (final weight in ['Medium', 'SemiBold', 'Bold', 'ExtraBold'])
      '$montserrat-$weight.ttf',
  ]);
  await load('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
}

/// Registers the shell dependencies against [repository].
Future<void> registerTestDependencies(IDiscoveryRepository repository) async {
  await getIt.reset();
  getIt
    ..registerFactory<DiscoverCubit>(() => DiscoverCubit(repository))
    ..registerFactory<CollectionCubit>(CollectionCubit.new);
}

/// Router with only the tab shell; authentication is out of scope here.
GoRouter buildTestRouter({String initialLocation = AppRoutes.discover}) {
  return GoRouter(initialLocation: initialLocation, routes: [appShellRoute]);
}

/// Mirrors CoreApp's providers without network time or analytics.
class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.router,
    required this.colorThemeBloc,
    this.locale = const Locale('tr'),
  });

  final GoRouter router;
  final ColorThemeBloc colorThemeBloc;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppColorsDark>.value(value: const CustomAppColorsDark()),
        Provider<AppColorsLight>.value(value: const CustomAppColorsLight()),
        BlocProvider<ColorThemeBloc>.value(value: colorThemeBloc),
      ],
      child: EasyLocalization(
        path: 'assets/translations',
        assetLoader: const FileTranslationLoader(),
        supportedLocales: const [Locale('en'), Locale('tr')],
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        saveLocale: false,
        child: Builder(
          builder: (context) => ScreenUtilInit(
            designSize: const Size(402, 874),
            minTextAdapt: true,
            builder: (context, _) => MaterialApp.router(
              routerConfig: router,
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark(useMaterial3: false).copyWith(
                scaffoldBackgroundColor: const CustomAppColorsDark().background,
              ),
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            ),
          ),
        ),
      ),
    );
  }
}

/// Builds the shell app on a 402×874 phone and waits for it to settle.
Future<GoRouter> pumpTestApp(
  WidgetTester tester, {
  required IDiscoveryRepository repository,
  String initialLocation = AppRoutes.discover,
  Locale locale = const Locale('tr'),
}) async {
  SharedPreferences.setMockInitialValues({});
  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();
  await registerTestDependencies(repository);

  tester.view
    ..physicalSize = const Size(402 * 3, 874 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final preferences = await SharedPreferences.getInstance();
  final themeBloc = ColorThemeBloc(SharedPrefColorThemeCache(preferences))
    ..addThemeSelected(colorThemeOption: ColorThemeOption.dark);
  addTearDown(themeBloc.close);

  final router = buildTestRouter(initialLocation: initialLocation);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    TestApp(router: router, colorThemeBloc: themeBloc, locale: locale),
  );
  await tester.pumpAndSettle();
  return router;
}
