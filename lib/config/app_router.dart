import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/config/app_page_transitions.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/widgets/fade_tab_stack.dart';
import 'package:music_disco/features/auth/presentation/pages/splash_page.dart';
import 'package:music_disco/features/collection/presentation/pages/collection_page.dart';
import 'package:music_disco/features/core/home/home_page.dart';
import 'package:music_disco/features/core/home/widgets/tab_root_reset.dart';
import 'package:music_disco/features/discover/presentation/pages/direction_page.dart';
import 'package:music_disco/features/discover/presentation/pages/discover_home_page.dart';
import 'package:music_disco/features/discover/presentation/pages/discovery_loading_page.dart';
import 'package:music_disco/features/discover/presentation/pages/mood_page.dart';
import 'package:music_disco/features/discover/presentation/pages/reference_page.dart';
import 'package:music_disco/features/discover/presentation/pages/session_page.dart';
import 'package:music_disco/features/settings/presentation/pages/settings_page.dart';
import 'package:music_disco/features/taste/presentation/pages/taste_genres_page.dart';
import 'package:music_disco/features/taste/presentation/pages/taste_page.dart';
import 'package:music_disco/features/taste/presentation/pages/taste_references_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    final navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null) return null;

    final authState = navigatorContext.read<AuthCubit>().state;
    final isPublicRoute = AppRoutes.publicRoutes.contains(
      state.matchedLocation,
    );

    if (!authState.isAuthenticated && !isPublicRoute) {
      return AppRoutes.splash;
    }

    if (authState.isAuthenticated && isPublicRoute) {
      return AppRoutes.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splash,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SplashPage()),
    ),
    appShellRoute,
  ],
);

final appShellRoute = StatefulShellRoute(
  builder: (context, state, navigationShell) => HomePage(
    navigationShell: navigationShell,
    isNavBarHidden: AppRoutes.fullscreenRoutes.contains(state.uri.path),
  ),
  navigatorContainerBuilder: (context, navigationShell, children) =>
      FadeTabStack(index: navigationShell.currentIndex, children: children),
  branches: [_discoverBranch(), _collectionBranch(), _settingsBranch()],
);

StatefulShellBranch _discoverBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.discover,
        name: AppRoutes.discover,
        pageBuilder: (context, state) => tabRootPage(
          state: state,
          child: const TabRootReset(branch: 0, child: DiscoverHomePage()),
        ),
        routes: [
          _flowRoute(
            segment: AppRoutes.moodSegment,
            name: AppRoutes.mood,
            page: const MoodPage(),
            directionName: AppRoutes.moodDirection,
            loadingName: AppRoutes.moodLoading,
            sessionName: AppRoutes.moodSession,
          ),
          _flowRoute(
            segment: AppRoutes.referenceSegment,
            name: AppRoutes.reference,
            page: const ReferencePage(),
            directionName: AppRoutes.referenceDirection,
            loadingName: AppRoutes.referenceLoading,
            sessionName: AppRoutes.referenceSession,
          ),
          _tasteRoute(
            name: AppRoutes.taste,
            page: const TastePage(),
            genresName: AppRoutes.tasteGenres,
            referencesName: AppRoutes.tasteReferences,
          ),
        ],
      ),
    ],
  );
}

StatefulShellBranch _collectionBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.collection,
        name: AppRoutes.collection,
        pageBuilder: (context, state) => tabRootPage(
          state: state,
          child: const TabRootReset(branch: 1, child: CollectionPage()),
        ),
      ),
    ],
  );
}

StatefulShellBranch _settingsBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        pageBuilder: (context, state) => tabRootPage(
          state: state,
          child: const TabRootReset(branch: 2, child: SettingsPage()),
        ),
        routes: [
          _tasteRoute(
            name: AppRoutes.settingsTaste,
            page: const TastePage(routeBase: AppRoutes.settingsTaste),
            genresName: AppRoutes.settingsTasteGenres,
            referencesName: AppRoutes.settingsTasteReferences,
          ),
        ],
      ),
    ],
  );
}

GoRoute _flowRoute({
  required String segment,
  required String name,
  required Widget page,
  required String directionName,
  required String loadingName,
  required String sessionName,
}) {
  return GoRoute(
    path: segment,
    name: name,
    pageBuilder: (context, state) => sharedAxisPage(state: state, child: page),
    routes: [
      GoRoute(
        path: AppRoutes.directionSegment,
        name: directionName,
        pageBuilder: (context, state) => sharedAxisPage(
          state: state,
          child: DirectionPage(loadingRoute: loadingName),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.loadingSegment,
            name: loadingName,
            pageBuilder: (context, state) => sharedAxisPage(
              state: state,
              child: DiscoveryLoadingPage(sessionRoute: sessionName),
            ),
          ),
          GoRoute(
            path: AppRoutes.sessionSegment,
            name: sessionName,
            pageBuilder: (context, state) =>
                sharedAxisPage(state: state, child: const SessionPage()),
          ),
        ],
      ),
    ],
  );
}

GoRoute _tasteRoute({
  required String name,
  required Widget page,
  required String genresName,
  required String referencesName,
}) {
  return GoRoute(
    path: AppRoutes.tasteSegment,
    name: name,
    pageBuilder: (context, state) => sharedAxisPage(state: state, child: page),
    routes: [
      GoRoute(
        path: AppRoutes.genresSegment,
        name: genresName,
        pageBuilder: (context, state) =>
            sharedAxisPage(state: state, child: const TasteGenresPage()),
      ),
      GoRoute(
        path: AppRoutes.referencesSegment,
        name: referencesName,
        pageBuilder: (context, state) =>
            sharedAxisPage(state: state, child: const TasteReferencesPage()),
      ),
    ],
  );
}
