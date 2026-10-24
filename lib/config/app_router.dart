import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/features/auth/presentation/pages/splash_page.dart';
import 'package:music_disco/features/core/home/home_page.dart';

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
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.home,
      pageBuilder: (context, state) {
        final args = state.extra as HomePageArguments?;
        return MaterialPage(
          key: state.pageKey,
          child: HomePage(arguments: args ?? HomePageArguments(context)),
        );
      },
    ),
  ],
);
