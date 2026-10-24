import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_boilerplate/application/analytics/analytics_cubit.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/application/color_theme/color_theme_bloc.dart';
import 'package:mobile_boilerplate/application/network_time/network_time_provider.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/common/rate_limiter.dart';
import 'package:mobile_boilerplate/infrastructure/analytics/impl_analytics_service.dart';
import 'package:mobile_boilerplate/infrastructure/app_tracking/impl_app_tracking_service.dart';
import 'package:mobile_boilerplate/infrastructure/auth/store_checker_service.dart';
import 'package:mobile_boilerplate/infrastructure/color_theme/shared_pref_color_theme_cache.dart';
import 'package:mobile_boilerplate/infrastructure/network_time/ntp_network_time_service.dart';
import 'package:mobile_boilerplate/wrapper/ntp_wrapper.dart';
import 'package:music_disco/config/env_config.dart';
import 'package:music_disco/features/auth/data/impl_auth_service.dart';
import 'package:music_disco/features/auth/data/impl_user_repository.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/data/mock_discovery_repository.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';
import 'package:supabase/supabase.dart';

Future<void> setupDependencies() async {
  final envConfig = EnvConfig.fromEnvironment()..validate();
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<EnvConfig>(envConfig)
    ..registerSingleton<SupabaseClient>(
      SupabaseClient(envConfig.supabaseUrl, envConfig.supabaseAnonKey),
      dispose: (client) => client.dispose(),
    )
    ..registerSingleton<SharedPreferences>(sharedPreferences)
    ..registerSingleton<NtpWrapper>(NtpWrapper())
    ..registerSingleton<RateLimiter>(
      RateLimiter(maxAttempts: 3, window: const Duration(seconds: 60)),
    )
    ..registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage())
    // Setup infrastructure dependencies
    ..registerSingleton<ImplAuthService>(
      ImplAuthService(
        getIt<SupabaseClient>(),
        getIt<FlutterSecureStorage>(),
        getIt<RateLimiter>(),
        projectUrl: envConfig.supabaseUrl,
      ),
      dispose: (service) => service.dispose(),
    )
    ..registerSingleton<ImplUserRepository>(
      ImplUserRepository(getIt<SupabaseClient>()),
    )
    ..registerSingleton<NtpNetworkTimeService>(
      NtpNetworkTimeService(getIt<SharedPreferences>(), getIt<NtpWrapper>()),
    )
    ..registerSingleton<SharedPrefColorThemeCache>(
      SharedPrefColorThemeCache(getIt<SharedPreferences>()),
    )
    ..registerSingleton<ImplAppTrackingService>(ImplAppTrackingService())
    ..registerSingleton<ImplAnalyticsService>(const ImplAnalyticsService())
    ..registerSingleton<StoreCheckerService>(const StoreCheckerService())
    ..registerSingleton<IDiscoveryRepository>(MockDiscoveryRepository())
    // Setup application dependencies
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        getIt<ImplAuthService>(),
        getIt<ImplUserRepository>(),
        getIt<ImplAppTrackingService>(),
        getIt<StoreCheckerService>(),
      ),
    )
    ..registerFactory<AnalyticsCubit>(
      () => AnalyticsCubit(getIt<ImplAnalyticsService>()),
    )
    ..registerFactory<NetworkTimeProvider>(
      () => NetworkTimeProvider(getIt<NtpNetworkTimeService>()),
    )
    ..registerFactory<ColorThemeBloc>(
      () => ColorThemeBloc(getIt<SharedPrefColorThemeCache>()),
    )
    ..registerFactory<DiscoverCubit>(
      () => DiscoverCubit(getIt<IDiscoveryRepository>()),
    )
    ..registerFactory<CollectionCubit>(CollectionCubit.new);
}
