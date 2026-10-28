import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/analytics/analytics_cubit.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/application/color_theme/color_theme_bloc.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/analytics/i_analytics_service.dart';
import 'package:mobile_boilerplate/domain/common/failure.dart';
import 'package:mobile_boilerplate/presentation/app_colors.dart';
import 'package:music_disco/config/app_router.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/features/core/home/home_page.dart';
import 'package:music_disco/core/util/custom_app_colors.dart';
import 'package:music_disco/core/util/music_color_theme_cache.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/bloc/reference_search_cubit.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/discovery_source.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_reference_catalog.dart';
import 'package:music_disco/features/discover/presentation/pages/discovery_loading_page.dart';
import 'package:music_disco/features/discover/presentation/widgets/discovery_loading_view.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';
import 'package:music_disco/features/discover/presentation/pages/session_page.dart';
import 'package:music_disco/features/discover/presentation/pages/mood_page.dart';
import 'package:music_disco/features/discover/presentation/pages/discover_home_page.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/data/curated_discovery_repository.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/player/bloc/youtube_player_cubit.dart';
import 'package:music_disco/features/player/data/youtube_player_wrapper.dart';
import 'package:music_disco/features/player/domain/models/playback_status.dart';
import 'package:music_disco/features/player/presentation/widgets/track_player_card.dart';
import 'package:music_disco/features/settings/bloc/settings_cubit.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DiscoverCubit discover;
  late CollectionCubit collection;
  late _DiscoveryRepository repository;
  late GoRouter router;
  final players = <_Player>[];

  setUpAll(() async {
    for (final (family, asset) in [
      ('Manrope', 'assets/fonts/Manrope-Variable.ttf'),
      ('ArchivoBlack', 'assets/fonts/ArchivoBlack-Regular.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    repository = _DiscoveryRepository();
    discover = DiscoverCubit(repository);
    collection = CollectionCubit();
    players.clear();
    getIt.registerFactory<DiscoverCubit>(() => discover);
    getIt.registerFactory<CollectionCubit>(() => collection);
    getIt.registerFactory<TasteCubit>(TasteCubit.new);
    getIt.registerFactory<ReferenceSearchCubit>(
      () => ReferenceSearchCubit(_ReferenceCatalog()),
    );
    getIt.registerFactory<YoutubePlayerCubit>(() {
      final player = _Player();
      players.add(player);
      return YoutubePlayerCubit(player);
    });
    router = GoRouter(
      initialLocation: AppRoutes.discover,
      routes: [appShellRoute],
    );
  });

  tearDown(() async {
    router.dispose();
    await getIt.reset();
  });

  for (final width in [320.0, 430.0]) {
    for (final locale in [const Locale('tr'), const Locale('en')]) {
      testWidgets('typography preserves 2x system text at $width in $locale', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 874);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _pump(tester, router, locale: locale, textScale: 2);
        final headline = tester.widget<DisplayHeadline>(
          find.byType(DisplayHeadline).first,
        );
        expect(headline.role, HeadlineRole.home);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: find.byType(DisplayHeadline).first,
            matching: find.byType(RichText),
          ),
        );
        // The heading uses content width after horizontal page padding.
        final expectedSize = width == 320 ? 34.32 : 38.0;
        final headingText = tester.widget<Text>(
          find.descendant(
            of: find.byType(DisplayHeadline).first,
            matching: find.byType(Text),
          ),
        );
        expect(
          headingText.textSpan!.style!.fontSize,
          closeTo(expectedSize, 0.01),
        );
        expect(headingText.textSpan!.style!.fontFamily, 'ArchivoBlack');
        expect(headingText.textSpan!.style!.fontWeight, FontWeight.w400);
        expect(paragraph.textScaler.scale(expectedSize), expectedSize * 2);
        expect(tester.takeException(), isNull);
        for (final route in [
          AppRoutes.mood,
          AppRoutes.moodDirection,
          AppRoutes.reference,
          AppRoutes.taste,
          AppRoutes.tasteGenres,
          AppRoutes.tasteReferences,
          AppRoutes.settings,
          AppRoutes.collection,
        ]) {
          router.go(route);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: route);
          if (width == 320 && locale.languageCode == 'tr') {
            await _captureTypography(
              tester,
              'scaled-${route.replaceAll('/', '-')}',
            );
          }
        }
        repository.pending = Completer<List<Track>>();
        router.go(AppRoutes.moodLoading);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        repository.pending!.complete(
          CuratedDiscoveryRepository.catalog.take(3).toList(),
        );
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(find.byType(TrackPlayerCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  test('player cleanup closes its underlying player', () async {
    final player = _Player();
    final cubit = YoutubePlayerCubit(player);
    await cubit.close();
    expect(player.closed, isTrue);
  });

  for (final width in [320.0, 402.0]) {
    testWidgets(
      'guided discovery, completion, collection playback and shelf management at $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 874);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _pump(tester, router);
        final taste = tester
            .element(find.byType(DiscoverHomePage))
            .read<TasteCubit>();
        taste.toggleGenre(Genre.rock);
        taste.toggleGenre(Genre.rnbSoul);
        for (final name in ['Duman', 'Tarkan', 'Sezen Aksu']) {
          taste.toggleReference(
            MusicReference(id: name, name: name, mood: Mood.afterHours),
          );
        }
        await taste.save();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Düzenle'));
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, AppRoutes.taste);
        router.go(AppRoutes.discover);
        await tester.pumpAndSettle();
        if (width == 402) await _captureTypography(tester, 'home');
        await tester.tap(find.text('Ruh haline göre keşfet'));
        await tester.pumpAndSettle();
        expect(find.text('Keşfi özelleştir').hitTestable(), findsOneWidget);
        expect(find.text('Hemen dinle'), findsNothing);
        await tester.tap(find.text('biraz yüksel'));
        await tester.pumpAndSettle();
        expect(discover.state.preferences.mood, Mood.turnItUp);
        expect(find.text('biraz yüksel'), findsOneWidget);
        expect(find.text('Gününe biraz enerji kat.'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(MoodDiscGrid),
            matching: find.byType(MoodDisc),
          ),
          findsNWidgets(6),
        );
        if (width == 402) await _captureTypography(tester, 'mood');
        expect(discover.state.status, DiscoverRoundStatus.idle);
        await _continueToMusic(tester, router, AppRoutes.moodLoading);
        expect(
          router.routeInformationProvider.value.uri.path,
          AppRoutes.moodSession,
        );
        expect(find.byType(TrackPlayerCard), findsOneWidget);
        final track = discover.state.currentTrack!;
        await tester.ensureVisible(find.text('Kaydet'));
        await tester.tap(find.text('Kaydet'));
        await tester.pumpAndSettle();
        expect(collection.state.contains(track.id), isTrue);
        router.go(AppRoutes.discover);
        await tester.pumpAndSettle();
        expect(find.text('Son keşfin').hitTestable(), findsOneWidget);
        final resumeBottom = tester
            .getBottomRight(find.byType(StudioResumeCard))
            .dy;
        final navTop = tester.getTopLeft(find.byType(HomeNavBar)).dy;
        expect(resumeBottom, lessThan(navTop));
        if (width == 402) await _captureTypography(tester, 'home-resume');
        await tester.tap(find.text('Son keşfin'));
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          AppRoutes.moodSession,
        );
        expect(discover.state.currentTrack, track);
        discover.goTo(discover.state.tracks.length - 1);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('turu tamamla'));
        await tester.tap(find.text('turu tamamla'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(SessionCompletedView),
            matching: find.text('Keşif tamamlandı'),
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Bu turda ${discover.state.tracks.length} şarkı vardı. 1 tanesi koleksiyonunda.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Kaydettiklerimi dinle'));
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          AppRoutes.collection,
        );
        await tester.tap(
          find.bySemanticsLabel('${track.title} — ${track.artist}, dinle'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TrackPlayerCard), findsOneWidget);
        expect(players.last.video, track.youtubeId);
        expect(players.last.playing, isTrue);
        await tester.tap(find.byTooltip('Sesi kapat'));
        await tester.pumpAndSettle();
        expect(players.last.muted, isTrue);
        expect(find.byTooltip('Sesi aç'), findsOneWidget);
        final sheetPlayer = players.last;
        await tester.tap(find.byTooltip('Kapat'));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Kapat'), findsNothing);
        expect(sheetPlayer.closed, isTrue);
        await tester.tap(find.byTooltip('${track.title} seçenekleri'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Gece yürüyüşü'));
        await tester.pumpAndSettle();
        expect(collection.state.shelves[track.id], CollectionShelf.nightWalk);
        await tester.tap(find.text('gece yürüyüşü · 1'));
        await tester.pumpAndSettle();
        expect(find.text(track.title), findsOneWidget);
        await tester.tap(find.byTooltip('${track.title} seçenekleri'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Koleksiyonumdan kaldır'));
        await tester.pumpAndSettle();
        expect(collection.state.isEmpty, isTrue);
        await tester.tap(find.text('Geri al'));
        await tester.pumpAndSettle();
        expect(collection.state.contains(track.id), isTrue);
        expect(collection.state.shelves[track.id], CollectionShelf.nightWalk);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'artist discovery requires a choice and customization before loading',
    (tester) async {
      await _pump(tester, router);
      await tester.tap(find.text('Sanatçıdan keşfet'));
      await tester.pumpAndSettle();
      expect(find.text('Keşfi özelleştir'), findsNothing);
      expect(find.text('Hemen dinle'), findsNothing);
      expect(find.text('Devam et'), findsNothing);
      await tester.tap(find.text('Test Artist'));
      await tester.pumpAndSettle();
      expect(find.text('Devam et').hitTestable(), findsOneWidget);
      expect(discover.state.status, DiscoverRoundStatus.idle);
      await _continueToMusic(tester, router, AppRoutes.referenceLoading);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.referenceSession,
      );
      expect(discover.state.preferences.source, DiscoverySource.reference);
      expect(discover.state.preferences.reference?.id, 'test-artist');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final width in [320.0, 402.0]) {
    testWidgets(
      'artist picker starts empty despite saved artists and can cancel a change at $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 874);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _pump(tester, router);
        final taste = tester
            .element(find.byType(DiscoverHomePage))
            .read<TasteCubit>();
        taste.toggleReference(
          const MusicReference(
            id: 'saved-artist',
            name: 'Saved Artist',
            mood: Mood.afterHours,
          ),
        );
        await taste.save();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sanatçıdan keşfet'));
        await tester.pumpAndSettle();
        expect(find.text('Devam et'), findsNothing);
        expect(find.text('Önce bir sanatçı seç'), findsOneWidget);
        expect(find.text('Değiştir'), findsNothing);
        expect(find.text('sanatçıların'), findsOneWidget);
        expect(find.text('önerilenler'), findsOneWidget);
        expect(find.text('Vazgeç'), findsNothing);
        await tester.tap(find.text('Test Artist'));
        await tester.pumpAndSettle();
        expect(find.text('Devam et').hitTestable(), findsOneWidget);
        expect(find.text('Değiştir'), findsOneWidget);
        expect(
          find.text('Test Artist ile aynı hissi veren en fazla 5 şarkı.'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('ritim'));
        await tester.tap(find.text('ritim'));
        await tester.pumpAndSettle();
        expect(
          find.text('Test Artist enerjisinde en fazla 5 şarkı.'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Saved Artist'));
        await tester.tap(find.text('Saved Artist'));
        await tester.pumpAndSettle();
        expect(
          find.text('Saved Artist enerjisinde en fazla 5 şarkı.'),
          findsOneWidget,
        );
        expect(
          find.text('Test Artist enerjisinde en fazla 5 şarkı.'),
          findsNothing,
        );
        expect(find.text('Devam et').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Değiştir'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Vazgeç'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Değiştir'));
        await tester.pumpAndSettle();
        expect(find.text('Önce bir sanatçı seç'), findsOneWidget);
        expect(find.text('Test Artist'), findsOneWidget);
        await tester.tap(find.text('Vazgeç'));
        await tester.pumpAndSettle();
        expect(find.text('Devam et').hitTestable(), findsOneWidget);
        expect(find.text('Saved Artist'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final width in [320.0, 402.0]) {
    testWidgets('direction page summarizes choices and links back at $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 874);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pump(tester, router);
      await tester.tap(find.text('Sanatçıdan keşfet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Artist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devam et'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.referenceDirection,
      );
      expect(find.text('SEVDİĞİN SANATÇI'), findsOneWidget);
      expect(find.text('tanıdık tarzlar'), findsOneWidget);
      expect(find.text('biraz farklı'), findsOneWidget);
      expect(find.text('yeni tarzlar'), findsOneWidget);
      expect(
        find.text(
          'Test Artist · atmosfer · bu histe kalalım · tanıdık tarzlar',
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('yükselt beni'));
      await tester.tap(find.text('yükselt beni'));
      await tester.pumpAndSettle();
      expect(discover.state.preferences.direction, DiscoveryDirection.lift);
      expect(
        find.text('Test Artist · atmosfer · yükselt beni · tanıdık tarzlar'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Değiştir'));
      await tester.tap(find.text('Değiştir'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.reference,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final width in [320.0, 390.0, 430.0]) {
    for (final locale in [const Locale('tr'), const Locale('en')]) {
      testWidgets(
        'sound trace loading fits $width in ${locale.languageCode} with reduced motion',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 844);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          repository.pending = Completer<List<Track>>();
          await _pump(tester, router, locale: locale);
          router.go(AppRoutes.moodLoading);
          await tester.pumpAndSettle();
          expect(find.byType(DiscoveryLoadingView), findsOneWidget);
          if (width == 390 && locale.languageCode == 'tr') {
            await _captureTypography(tester, 'loading');
          }
          expect(find.byType(MoodDisc), findsNothing);
          for (var row = 0; row < 5; row++) {
            expect(find.byKey(ValueKey('sound-trace-$row')), findsOneWidget);
            expect(find.text('0${row + 1}'), findsOneWidget);
          }
          expect(tester.binding.transientCallbackCount, 0);
          await tester.pump(const Duration(seconds: 12));
          expect(
            router.routeInformationProvider.value.uri.path,
            AppRoutes.moodLoading,
          );
          expect(players, isEmpty);
          expect(tester.binding.transientCallbackCount, 0);
          expect(tester.takeException(), isNull);
          router.pop();
          await tester.pumpAndSettle();
          expect(discover.state.status, DiscoverRoundStatus.idle);
          expect(repository.pending!.isCompleted, isFalse);
          repository.pending!.complete([]);
          await tester.pumpAndSettle();
          expect(
            router.routeInformationProvider.value.uri.path,
            AppRoutes.moodDirection,
          );
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets('waveforms pause in the background during the minimum display', (
    tester,
  ) async {
    repository.pending = Completer<List<Track>>();
    await _pump(tester, router, reducedMotion: false);
    router.go(AppRoutes.moodLoading);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    repository.pending!.complete(
      CuratedDiscoveryRepository.catalog.take(3).toList(),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.moodSession,
    );
    expect(discover.state.tracks.length, 3);
    expect(find.byType(DiscoveryLoadingView), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('empty discovery offers retry without inventing results', (
    tester,
  ) async {
    repository.pending = Completer<List<Track>>();
    await _pump(tester, router);
    router.go(AppRoutes.moodLoading);
    await tester.pumpAndSettle();
    repository.pending!.complete([]);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(discover.state.status, DiscoverRoundStatus.failure);
    expect(discover.state.tracks, isEmpty);
    expect(find.text('Tekrar dene').hitTestable(), findsOneWidget);
    expect(find.byType(TrackPlayerCard), findsNothing);
    expect(find.byType(DiscoveryLoadingView), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('loading waits for the request before opening the player', (
    tester,
  ) async {
    repository.pending = Completer<List<Track>>();
    await _pump(tester, router);
    await tester.tap(find.text('Ruh haline göre keşfet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keşfi özelleştir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('İlk şarkımı bul'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.moodLoading,
    );
    expect(players, isEmpty);
    repository.pending!.complete(
      CuratedDiscoveryRepository.catalog.take(5).toList(),
    );
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.moodSession,
    );
    expect(players.single.playing, isTrue);
    router.pop();
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.moodDirection,
    );
    expect(find.byType(DiscoveryLoadingPage), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'leaving loading cancels stale results and allows a fresh search',
    (tester) async {
      repository.pending = Completer<List<Track>>();
      await _pump(tester, router);
      await tester.tap(find.text('Ruh haline göre keşfet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keşfi özelleştir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İlk şarkımı bul'));
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(discover.state.status, DiscoverRoundStatus.idle);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.moodDirection,
      );
      final oldRequest = repository.pending!;
      repository.pending = Completer<List<Track>>();
      discover.selectMood(Mood.softSide);
      await tester.tap(find.text('İlk şarkımı bul'));
      await tester.pumpAndSettle();
      oldRequest.complete(CuratedDiscoveryRepository.catalog.take(5).toList());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.moodLoading,
      );
      expect(discover.state.status, DiscoverRoundStatus.loading);
      expect(players, isEmpty);
      repository.pending!.complete([CuratedDiscoveryRepository.catalog.last]);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.moodSession,
      );
      expect(discover.state.preferences.mood, Mood.softSide);
      expect(
        players.single.video,
        CuratedDiscoveryRepository.catalog.last.youtubeId,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('failed discovery leaves loading and offers retry', (
    tester,
  ) async {
    repository.pending = Completer<List<Track>>();
    await _pump(tester, router);
    await tester.tap(find.text('Ruh haline göre keşfet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keşfi özelleştir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('İlk şarkımı bul'));
    await tester.pumpAndSettle();
    repository.pending!.completeError(StateError('catalog unavailable'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.moodSession,
    );
    expect(find.text('Tekrar dene').hitTestable(), findsOneWidget);
    expect(find.byType(TrackPlayerCard), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'leaving discovery pauses playback before opening another player',
    (tester) async {
      await _pump(tester, router);
      await tester.tap(find.text('Ruh haline göre keşfet'));
      await tester.pumpAndSettle();
      await _continueToMusic(tester, router, AppRoutes.moodLoading);
      expect(players.first.playing, isTrue);
      await tester.tap(find.text('koleksiyon'));
      await tester.pumpAndSettle();
      expect(players.first.playing, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'exhausted replacements show an explanation and a way to change choices',
    (tester) async {
      await _pump(tester, router);
      await tester.tap(find.text('Ruh haline göre keşfet'));
      await tester.pumpAndSettle();
      await _continueToMusic(tester, router, AppRoutes.moodLoading);
      for (var i = 0; i < CuratedDiscoveryRepository.catalog.length; i++) {
        await discover.rejectCurrent(TrackFeedback.alreadyKnown);
      }
      await tester.pumpAndSettle();
      expect(discover.state.notice, DiscoverNotice.noAlternative);
      expect(
        find.text(
          'Bu seçimlerle başka şarkı kalmadı. Keşif ayarlarını değiştirebilirsin.',
        ),
        findsOneWidget,
      );
      expect(find.text('Keşfi özelleştir'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

class _Player implements YoutubePlayerWrapper {
  final statuses = StreamController<PlaybackStatus>.broadcast(sync: true);
  String? video;
  bool playing = false;
  bool muted = false;
  bool closed = false;
  @override
  Stream<PlaybackStatus> get statusStream => statuses.stream;
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<Duration> get durationStream => const Stream.empty();
  @override
  Future<void> cue(String videoId) async {
    video = videoId;
    statuses.add(PlaybackStatus.cued);
  }

  @override
  Future<void> load(String videoId) async {
    video = videoId;
    await play();
  }

  @override
  Future<void> play() async {
    playing = true;
    statuses.add(PlaybackStatus.playing);
  }

  @override
  Future<void> pause() async {
    playing = false;
    statuses.add(PlaybackStatus.paused);
  }

  @override
  Future<void> stop() => pause();
  @override
  Future<void> setMuted(bool value) async {
    muted = value;
  }

  @override
  Future<void> seekTo(Duration position) async {}
  @override
  Widget buildView({Color? backgroundColor}) => const AspectRatio(
    aspectRatio: 16 / 9,
    child: ColoredBox(color: Color(0xFF121212)),
  );
  @override
  Future<void> close() async {
    closed = true;
    await statuses.close();
  }
}

class _Auth extends Cubit<AuthState> implements AuthCubit {
  _Auth() : super(AuthState.initial());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Analytics implements IAnalyticsService {
  @override
  Future<FailureOr<Unit>> logScreenViewEvent({
    required String screenName,
    required Type screenType,
    Map<String, String> parameters = const {},
  }) async => right(unit);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Translations extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

Future<void> _pump(
  WidgetTester tester,
  GoRouter router, {
  bool reducedMotion = true,
  Locale locale = const Locale('tr'),
  double textScale = 1,
}) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ColorThemeBloc(MusicColorThemeCache(preferences))..addStarted(),
        ),
        BlocProvider<AuthCubit>(create: (_) => _Auth()),
        BlocProvider(create: (_) => SettingsCubit(preferences)),
        BlocProvider(create: (_) => AnalyticsCubit(_Analytics())),
      ],
      child: MultiProvider(
        providers: [
          Provider<AppColorsDark>.value(value: const CustomAppColorsDark()),
          Provider<AppColorsLight>.value(value: const CustomAppColorsLight()),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('tr'), Locale('en')],
          startLocale: locale,
          path: 'assets/translations',
          assetLoader: _Translations(),
          child: ScreenUtilInit(
            designSize: const Size(402, 874),
            builder: (context, _) => MaterialApp.router(
              routerConfig: router,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: reducedMotion,
                  textScaler: TextScaler.linear(textScale),
                ),
                child: RepaintBoundary(
                  key: const ValueKey('typography-preview'),
                  child: child!,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  if (reducedMotion) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _continueToMusic(
  WidgetTester tester,
  GoRouter router,
  String loadingRoute,
) async {
  await tester.tap(
    find.text(
      loadingRoute == AppRoutes.moodLoading ? 'Keşfi özelleştir' : 'Devam et',
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('İlk şarkımı bul').hitTestable(), findsOneWidget);
  expect(find.byType(TrackPlayerCard), findsNothing);
  await tester.tap(find.text('İlk şarkımı bul'));
  await tester.pumpAndSettle();
  expect(router.routeInformationProvider.value.uri.path, loadingRoute);
  expect(find.byType(DiscoveryLoadingPage), findsOneWidget);
  await tester.pump(const Duration(seconds: 4));
  expect(router.routeInformationProvider.value.uri.path, loadingRoute);
  expect(find.byType(TrackPlayerCard), findsNothing);
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  expect(
    router.routeInformationProvider.value.uri.path,
    loadingRoute.replaceFirst('/loading', '/session'),
  );
  expect(find.byType(DiscoveryLoadingPage), findsNothing);
  expect(find.byType(TrackPlayerCard), findsOneWidget);
}

class _ReferenceCatalog implements IReferenceCatalog {
  @override
  Future<List<MusicReference>> search(String query) async => const [
    MusicReference(
      id: 'test-artist',
      name: 'Test Artist',
      mood: Mood.afterHours,
    ),
  ];
}

class _DiscoveryRepository implements IDiscoveryRepository {
  final _catalog = CuratedDiscoveryRepository(latency: Duration.zero);
  Completer<List<Track>>? pending;

  @override
  Future<List<Track>> fetchRound(
    DiscoveryPreferences preferences, {
    int count = 5,
    Set<String> excludeIds = const {},
  }) =>
      pending?.future ??
      _catalog.fetchRound(preferences, count: count, excludeIds: excludeIds);

  @override
  Future<Track?> fetchReplacement(
    DiscoveryPreferences preferences, {
    required TrackFeedback feedback,
    Set<String> excludeIds = const {},
  }) => _catalog.fetchReplacement(
    preferences,
    feedback: feedback,
    excludeIds: excludeIds,
  );
}

Future<void> _captureTypography(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('TYPOGRAPHY_PREVIEW')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('typography-preview')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(
      '/private/tmp/music-disco-typography-$name.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
