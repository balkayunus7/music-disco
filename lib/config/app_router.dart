import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/config/app_page_transitions.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/widgets/branch_fade_container.dart';
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
import 'package:music_disco/features/taste/presentation/pages/taste_genres_page.dart';
import 'package:music_disco/features/taste/presentation/pages/taste_page.dart';
import 'package:music_disco/features/taste/presentation/pages/taste_references_page.dart';
import 'package:music_disco/features/settings/presentation/pages/settings_page.dart';

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
      pageBuilder: (context, state) {
        return MaterialPage(key: state.pageKey, child: const SplashPage());
      },
    ),
    appShellRoute,
  ],
);

final appShellRoute = StatefulShellRoute(
  builder: (context, state, navigationShell) {
    return HomePage(
      navigationShell: navigationShell,
      isNavBarHidden: AppRoutes.fullscreenRoutes.contains(state.uri.path),
    );
  },
  navigatorContainerBuilder: (context, navigationShell, children) {
    return BranchFadeContainer(
      currentIndex: navigationShell.currentIndex,
      children: children,
    );
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.discover,
          name: AppRoutes.discover,
          pageBuilder: (context, state) {
            return tabRootPage(
              state: state,
              child: const TabRootReset(branch: 0, child: DiscoverHomePage()),
            );
          },
          routes: [
            GoRoute(
              path: 'mood',
              name: AppRoutes.mood,
              pageBuilder: (context, state) {
                return sharedAxisPage(state: state, child: const MoodPage());
              },
              routes: [
                _directionRoute(
                  name: AppRoutes.moodDirection,
                  loadingName: AppRoutes.moodLoading,
                  sessionName: AppRoutes.moodSession,
                ),
              ],
            ),
            GoRoute(
              path: 'reference',
              name: AppRoutes.reference,
              pageBuilder: (context, state) {
                return sharedAxisPage(
                  state: state,
                  child: const ReferencePage(),
                );
              },
              routes: [
                _directionRoute(
                  name: AppRoutes.referenceDirection,
                  loadingName: AppRoutes.referenceLoading,
                  sessionName: AppRoutes.referenceSession,
                ),
              ],
            ),
            GoRoute(
              path: 'taste',
              name: AppRoutes.taste,
              pageBuilder: (context, state) {
                return sharedAxisPage(state: state, child: const TastePage());
              },
              routes: [
                GoRoute(
                  path: 'genres',
                  name: AppRoutes.tasteGenres,
                  pageBuilder: (context, state) {
                    return sharedAxisPage(
                      state: state,
                      child: const TasteGenresPage(),
                    );
                  },
                ),
                GoRoute(
                  path: 'references',
                  name: AppRoutes.tasteReferences,
                  pageBuilder: (context, state) {
                    return sharedAxisPage(
                      state: state,
                      child: const TasteReferencesPage(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.collection,
          name: AppRoutes.collection,
          pageBuilder: (context, state) {
            return tabRootPage(
              state: state,
              child: const TabRootReset(branch: 1, child: CollectionPage()),
            );
          },
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settings,
          pageBuilder: (context, state) => tabRootPage(
            state: state,
            child: const TabRootReset(branch: 2, child: SettingsPage()),
          ),
          routes: [
            GoRoute(
              path: 'taste',
              name: AppRoutes.settingsTaste,
              pageBuilder: (context, state) => sharedAxisPage(
                state: state,
                child: const TastePage(routeBase: AppRoutes.settingsTaste),
              ),
              routes: [
                GoRoute(
                  path: 'genres',
                  name: AppRoutes.settingsTasteGenres,
                  pageBuilder: (context, state) => sharedAxisPage(
                    state: state,
                    child: const TasteGenresPage(),
                  ),
                ),
                GoRoute(
                  path: 'references',
                  name: AppRoutes.settingsTasteReferences,
                  pageBuilder: (context, state) => sharedAxisPage(
                    state: state,
                    child: const TasteReferencesPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

GoRoute _directionRoute({
  required String name,
  required String loadingName,
  required String sessionName,
}) {
  return GoRoute(
    path: 'direction',
    name: name,
    pageBuilder: (context, state) {
      return sharedAxisPage(
        state: state,
        child: DirectionPage(loadingRoute: loadingName),
      );
    },
    routes: [
      GoRoute(
        path: 'loading',
        name: loadingName,
        pageBuilder: (context, state) => sharedAxisPage(
          state: state,
          child: DiscoveryLoadingPage(sessionRoute: sessionName),
        ),
      ),
      GoRoute(
        path: 'session',
        name: sessionName,
        pageBuilder: (context, state) {
          return sharedAxisPage(state: state, child: const SessionPage());
        },
      ),
    ],
  );
}
