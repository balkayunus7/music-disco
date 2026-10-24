import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/fancy_button.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<AuthCubit>().initialize();
    });
  }

  Future<void> onRetry() => context.read<AuthCubit>().initialize();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) {
            return !previous.isAuthenticated && current.isAuthenticated;
          },
          listener: (context, state) => context.go(AppRoutes.home),
        ),
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) {
            return !previous.canCreateGuest && current.canCreateGuest;
          },
          listener: (context, state) async {
            await context.read<AuthCubit>().signInAnonymously();
          },
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) {
          return previous.hasStartupFailed != current.hasStartupFailed;
        },
        builder: (context, state) {
          return SplashView(
            hasFailed: state.hasStartupFailed,
            onRetry: onRetry,
          );
        },
      ),
    );
  }
}
