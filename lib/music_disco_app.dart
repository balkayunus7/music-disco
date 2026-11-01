import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/application/analytics/analytics_cubit.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/application/color_theme/color_theme_bloc.dart';
import 'package:mobile_boilerplate/application/network_time/network_time_provider.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/core_app.dart';
import 'package:music_disco/features/settings/bloc/settings_cubit.dart';
import 'package:music_disco/config/app_router.dart';
import 'package:music_disco/core/design_system/colors.dart';
import 'package:music_disco/core/localization/locale_language.dart';
import 'package:music_disco/features/auth/presentation/widgets/auth_session_listener.dart';

class MusicDiscoApp extends StatelessWidget {
  const MusicDiscoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ColorThemeBloc>()..addStarted()),
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<AnalyticsCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        Provider<NetworkTimeProvider>(
          create: (_) => getIt<NetworkTimeProvider>(),
        ),
      ],
      child: AuthSessionListener(
        child: CoreApp(
          darkColors: const CustomAppColorsDark(),
          lightColors: const CustomAppColorsLight(),
          routerConfig: appRouter,
          fontFamily: 'Manrope',
          supportedLocales: LocaleLanguage.supportedLocales,
        ),
      ),
    );
  }
}
