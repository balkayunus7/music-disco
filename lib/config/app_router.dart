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
import 'package:music_disco/features/discover/presentation/pages/direction_page.dart';
import 'package:music_disco/features/discover/presentation/pages/mood_page.dart';
import 'package:music_disco/features/discover/presentation/pages/session_page.dart';

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

/// Bottom-navigation shell: keşfet and koleksiyon keep their own stacks.
final appShellRoute = StatefulShellRoute(
  builder: (context, state, navigationShell) {
    return HomePage(navigationShell: navigationShell);
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
            return tabRootPage(state: state, child: const MoodPage());
          },
          routes: [
            GoRoute(
              path: 'direction',
              name: AppRoutes.direction,
              pageBuilder: (context, state) {
                return sharedAxisPage(
                  state: state,
                  child: const DirectionPage(),
                );
              },
              routes: [
                GoRoute(
                  path: 'session',
                  name: AppRoutes.session,
                  pageBuilder: (context, state) {
                    return sharedAxisPage(
                      state: state,
                      child: const SessionPage(),
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
            return tabRootPage(state: state, child: const CollectionPage());
          },
        ),
      ],
    ),
  ],
);
