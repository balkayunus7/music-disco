import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/analytics/analytics_cubit.dart';
import 'package:mobile_boilerplate/domain/analytics/i_analytics_service.dart';
import 'package:mobile_boilerplate/domain/common/failure.dart';
import 'package:mobile_boilerplate/application/color_theme/color_theme_bloc.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/core_app.dart' show appConfig;
import 'package:mobile_boilerplate/domain/color_theme/color_theme_option.dart';
import 'package:mobile_boilerplate/presentation/app_colors.dart';
import 'package:music_disco/core/util/custom_app_colors.dart';
import 'package:music_disco/core/widgets/app_page_bar.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/config/app_router.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/config/app_config.dart';
import 'package:music_disco/core/util/music_color_theme_cache.dart';
import 'package:music_disco/features/settings/bloc/settings_cubit.dart';
import 'package:music_disco/features/settings/presentation/pages/settings_page.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/core/home/home_page.dart';
import 'package:music_disco/features/discover/data/mock_discovery_repository.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    appConfig = MusicAppConfig();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    final archivo = FontLoader('ArchivoBlack')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/ArchivoBlack-Regular.ttf').readAsBytesSync(),
          ),
        ),
      );
    final montserrat = FontLoader('packages/mobile_boilerplate/Montserrat');
    for (final weight in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
      montserrat.addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '../mobile-boilerplate/assets/fonts/Montserrat-$weight.ttf',
            ).readAsBytesSync(),
          ),
        ),
      );
    }
    await archivo.load();
    await montserrat.load();
    await icons.load();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
  });

  test('motion preference is restored by a new settings instance', () async {
    final preferences = await SharedPreferences.getInstance();
    final first = SettingsCubit(preferences);
    expect(first.state, isFalse);
    expect(await first.setReduceMotion(true), isTrue);
    await first.close();
    final restored = SettingsCubit(preferences);
    expect(restored.state, isTrue);
    expect(await restored.setReduceMotion(false), isTrue);
    expect(preferences.getBool(SettingsCubit.reduceMotionKey), isFalse);
    await restored.close();
  });

  test(
    'dark mode overrides previously saved system and light choices',
    () async {
      final cache = MusicColorThemeCache(await SharedPreferences.getInstance());
      expect(cache.readColorThemeOption(), ColorThemeOption.dark);
      for (final oldTheme in [
        ColorThemeOption.system,
        ColorThemeOption.light,
      ]) {
        await cache.writeColorThemeOption(colorThemeOption: oldTheme);
        expect(cache.readColorThemeOption(), ColorThemeOption.dark);
      }
    },
  );

  testWidgets(
    'profile rejects blank names and retains the name after a failed save',
    (tester) async {
      var calls = 0;
      String? submitted;
      await _pump(
        tester,
        SettingsProfileEditor(
          initialName: '',
          onSave: (name) async {
            calls++;
            submitted = name;
            return false;
          },
        ),
      );
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(find.text('1–80 karakter arasında bir isim yaz.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '  Yunus  ');
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(submitted, 'Yunus');
      expect(find.text('Kaydedilemedi. Lütfen tekrar dene.'), findsOneWidget);
      expect(find.text('  Yunus  '), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('choice sheet returns the selected value', (tester) async {
    int? result;
    await _pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showModalBottomSheet<int>(
              context: context,
              builder: (_) => const SettingsChoiceSheet(
                title: 'Görünüm',
                selected: 0,
                options: {0: 'Koyu', 1: 'Açık'},
              ),
            );
          },
          child: const Text('Open'),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Açık'));
    await tester.pumpAndSettle();
    expect(result, 1);
  });

  for (final width in [320.0, 402.0]) {
    testWidgets(
      'page bars keep title alignment with back and action at width $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 874);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var actions = 0;
        await _pump(
          tester,
          Column(
            children: [
              const AppPageBar(title: 'Root'),
              const AppPageBar(title: 'Detail', showBackButton: true),
              AppPageBar(
                title: 'Action',
                showBackButton: true,
                actionIcon: Icons.tune_rounded,
                actionLabel: 'Tune',
                onAction: () => actions++,
              ),
            ],
          ),
        );
        final bars = find.byType(AppPageBar);
        final rootHeight = tester.getSize(bars.at(0)).height;
        for (var i = 0; i < 3; i++) {
          final bar = bars.at(i);
          final title = find.descendant(of: bar, matching: find.byType(Text));
          expect(tester.getSize(bar).height, rootHeight);
          expect(tester.widget<Text>(title).textAlign, TextAlign.start);
          if (i == 0) {
            expect(tester.getTopLeft(title).dx, tester.getTopLeft(bar).dx);
          } else {
            expect(
              tester.getTopLeft(title).dx,
              greaterThan(tester.getTopLeft(bar).dx),
            );
            expect(
              tester.getTopLeft(title).dx,
              tester.getTopLeft(find.text('Detail')).dx,
            );
          }
          expect(
            tester.widget<Text>(title).style,
            tester.widget<Text>(find.text('Root')).style,
          );
        }
        await tester.tap(find.bySemanticsLabel('Tune'));
        expect(actions, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'page bar stays pinned with long text and scrolling at width $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 874);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _pump(
          tester,
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: BrandPageBody(
                appBar: const AppPageBar(
                  title: 'Uzun bir sayfa başlığı / A longer page title',
                  showBackButton: true,
                ),
                children: [
                  for (var i = 0; i < 30; i++)
                    SizedBox(height: 80, child: Text('Content $i')),
                ],
              ),
            ),
          ),
        );
        final before = tester.getRect(find.byType(AppPageBar));
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byType(AppPageBar)), before);
        expect(find.text('Content 0').hitTestable(), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('settings fits width $width and changes language and motion', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1130);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final preferences = await SharedPreferences.getInstance();
      final collection = CollectionCubit()
        ..save(MockDiscoveryRepository.catalog.first);
      final taste = TasteCubit();
      final motion = SettingsCubit(preferences);
      final pulse = ValueNotifier(0);
      addTearDown(pulse.dispose);
      final previewKey = GlobalKey();
      var selectedTab = 2;
      await _pump(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (_) => _TestAuthCubit()),
            BlocProvider(create: (_) => collection),
            BlocProvider(create: (_) => taste),
            BlocProvider(create: (_) => motion),
          ],
          child: RepaintBoundary(
            key: previewKey,
            child: Column(
              children: [
                const Expanded(child: SettingsPage()),
                HomeNavBar(
                  currentIndex: 2,
                  collectionTargetKey: GlobalKey(),
                  landingPulse: pulse,
                  onTap: (index) => selectedTab = index,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('1 şarkı · 0 koleksiyon'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (width == 402 && const bool.fromEnvironment('SETTINGS_PREVIEW')) {
        final boundary =
            previewKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            '/private/tmp/music-disco-settings.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.ensureVisible(find.text('Şarkı dili'));
      await tester.tap(find.text('Şarkı dili'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İngilizce'));
      await tester.pumpAndSettle();
      expect(taste.state.saved.language.name, 'english');
      expect(find.text('Görünüm'), findsNothing);
      expect(find.text('FIND YOUR FREQUENCY.'), findsNothing);
      await tester.ensureVisible(find.text('Destek'));
      await tester.tap(find.text('Destek'));
      await tester.pumpAndSettle();
      expect(find.text('Bu bağlantı henüz hazır değil.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Satın alımları geri yükle'));
      await tester.tap(find.text('Satın alımları geri yükle'));
      await tester.pumpAndSettle();
      expect(
        find.text('Satın alımları geri yükleme şu anda kullanılamıyor.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(motion.state, isTrue);
      await tester.tap(find.text('keşfet'));
      expect(selectedTab, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'settings taste flow returns to settings and all three tabs work',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(402, 874);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final preferences = await SharedPreferences.getInstance();
      getIt.registerFactory<DiscoverCubit>(
        () => DiscoverCubit(MockDiscoveryRepository()),
      );
      getIt.registerFactory<CollectionCubit>(CollectionCubit.new);
      getIt.registerFactory<TasteCubit>(TasteCubit.new);
      final router = GoRouter(
        initialLocation: AppRoutes.settings,
        routes: [appShellRoute],
      );
      await _pump(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (_) => _TestAuthCubit()),
            BlocProvider(create: (_) => SettingsCubit(preferences)),
            BlocProvider(
              create: (_) => AnalyticsCubit(_TestAnalyticsService()),
            ),
          ],
          child: Router.withConfig(config: router),
        ),
      );
      await tester.ensureVisible(find.text('Müzik zevkin'));
      await tester.tap(find.text('Müzik zevkin'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.settingsTaste,
      );
      await tester.tap(find.text('Düzenle').first);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.settingsTasteGenres,
      );
      await tester.tap(find.text('Pop'));
      await tester.tap(find.text('Tercihlerime dön'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tercihlerimi kaydet'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.settings,
      );
      expect(find.text('Pop'), findsOneWidget);
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(
        MediaQuery.disableAnimationsOf(
          tester.element(find.byType(SettingsPage)),
        ),
        isTrue,
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.tap(find.text('koleksiyon'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.collection,
      );
      await tester.tap(find.text('ayarlar'));
      await tester.pumpAndSettle();
      expect(find.text('PROFİL & AYARLAR'), findsOneWidget);
      await tester.tap(find.text('keşfet'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.discover,
      );
      await tester.tap(find.text('ayarlar'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.settings,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await getIt.reset();
    },
  );
}

class _TestAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _TestAuthCubit() : super(AuthState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAnalyticsService implements IAnalyticsService {
  @override
  Future<FailureOr<Unit>> logScreenViewEvent({
    required String screenName,
    required Type screenType,
    Map<String, String> parameters = const {},
  }) async => right(unit);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  final theme = ColorThemeBloc(
    MusicColorThemeCache(await SharedPreferences.getInstance()),
  )..addStarted();
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => theme,
      child: MultiProvider(
        providers: [
          Provider<AppColorsDark>.value(value: const CustomAppColorsDark()),
          Provider<AppColorsLight>.value(value: const CustomAppColorsLight()),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('tr'), Locale('en')],
          startLocale: const Locale('tr'),
          path: 'assets/translations',
          assetLoader: _TestAssetLoader(),
          child: ScreenUtilInit(
            designSize: const Size(402, 874),
            builder: (context, _) => MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(body: child),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _TestAssetLoader extends AssetLoader {
  final Map<String, dynamic> _translations =
      jsonDecode(File('assets/translations/tr.json').readAsStringSync())
          as Map<String, dynamic>;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _translations;
}
