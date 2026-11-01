import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/features/auth/bloc/auth_state_ext.dart';

part '../widgets/splash_view.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_initialize());
    });
  }

  Future<void> _initialize() => context.read<AuthCubit>().initialize();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: context.colors.background,
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listenWhen: (previous, current) =>
                !previous.isAuthenticated && current.isAuthenticated,
            listener: (context, state) => context.go(AppRoutes.home),
          ),
          BlocListener<AuthCubit, AuthState>(
            listenWhen: (previous, current) =>
                !previous.canCreateGuest && current.canCreateGuest,
            listener: (context, state) =>
                context.read<AuthCubit>().signInAnonymously(),
          ),
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              previous.hasStartupFailed != current.hasStartupFailed,
          builder: (context, state) => SplashView(
            hasFailed: state.hasStartupFailed,
            onRetry: _initialize,
          ),
        ),
      ),
    );
  }
}
