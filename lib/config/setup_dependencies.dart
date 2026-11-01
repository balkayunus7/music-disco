import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_boilerplate/application/analytics/analytics_cubit.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/application/color_theme/color_theme_bloc.dart';
import 'package:mobile_boilerplate/application/network_time/network_time_provider.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/color_theme/i_color_theme_cache.dart';
import 'package:mobile_boilerplate/domain/common/rate_limiter.dart';
import 'package:mobile_boilerplate/infrastructure/analytics/impl_analytics_service.dart';
import 'package:mobile_boilerplate/infrastructure/app_tracking/impl_app_tracking_service.dart';
import 'package:mobile_boilerplate/infrastructure/auth/store_checker_service.dart';
import 'package:mobile_boilerplate/infrastructure/network_time/ntp_network_time_service.dart';
import 'package:mobile_boilerplate/wrapper/ntp_wrapper.dart';
import 'package:music_disco/config/env_config.dart';
import 'package:music_disco/core/design_system/color_theme_cache.dart';
import 'package:music_disco/features/auth/data/impl_auth_service.dart';
import 'package:music_disco/features/auth/data/impl_user_repository.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/data/local_collection_store.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/bloc/reference_search_cubit.dart';
import 'package:music_disco/features/discover/data/supabase_artist_catalog.dart';
import 'package:music_disco/features/discover/data/supabase_discovery_repository.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_feedback_repository.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_reference_catalog.dart';
import 'package:music_disco/features/player/bloc/youtube_player_cubit.dart';
import 'package:music_disco/features/player/data/youtube_player_wrapper.dart';
import 'package:music_disco/features/settings/bloc/settings_cubit.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/data/local_taste_store.dart';
import 'package:supabase/supabase.dart';

Future<bool> trySetupDependencies() async {
  try {
    await setupDependencies();
    return true;
  } on Object catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
    await getIt.reset();
    return false;
  }
}

Future<void> setupDependencies() async {
  final envConfig = EnvConfig.fromEnvironment()..validate();
  final sharedPreferences = await SharedPreferences.getInstance();
  _registerInfrastructure(envConfig, sharedPreferences);
  _registerApplication(sharedPreferences);
}

void _registerInfrastructure(
  EnvConfig envConfig,
  SharedPreferences sharedPreferences,
) {
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
    ..registerSingleton<IColorThemeCache>(const ColorThemeCache())
    ..registerSingleton<ImplAppTrackingService>(ImplAppTrackingService())
    ..registerSingleton<ImplAnalyticsService>(const ImplAnalyticsService())
    ..registerSingleton<StoreCheckerService>(const StoreCheckerService())
    ..registerSingleton<SupabaseDiscoveryRepository>(
      SupabaseDiscoveryRepository(getIt<SupabaseClient>()),
    )
    ..registerSingleton<IDiscoveryRepository>(
      getIt<SupabaseDiscoveryRepository>(),
    )
    ..registerSingleton<IDiscoveryFeedbackRepository>(
      getIt<SupabaseDiscoveryRepository>(),
    )
    ..registerSingleton<IReferenceCatalog>(
      SupabaseArtistCatalog(getIt<SupabaseClient>()),
    );
}

void _registerApplication(SharedPreferences sharedPreferences) {
  getIt
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
      () => ColorThemeBloc(getIt<IColorThemeCache>()),
    )
    ..registerFactory<DiscoverCubit>(
      () => DiscoverCubit(getIt<IDiscoveryRepository>()),
    )
    ..registerFactoryParam<CollectionCubit, String?, void>(
      (userId, _) => CollectionCubit(
        feedbackRepository: getIt<IDiscoveryFeedbackRepository>(),
        canRecordFeedback: () =>
            userId != null &&
            getIt<SupabaseClient>().auth.currentUser?.id == userId,
        store: userId == null
            ? null
            : LocalCollectionStore(sharedPreferences, userId: userId),
      ),
    )
    ..registerFactoryParam<TasteCubit, String?, void>(
      (userId, _) => TasteCubit(
        store: userId == null
            ? null
            : LocalTasteStore(sharedPreferences, userId: userId),
      ),
    )
    ..registerFactory<SettingsCubit>(
      () => SettingsCubit(getIt<SharedPreferences>()),
    )
    ..registerFactory<ReferenceSearchCubit>(
      () => ReferenceSearchCubit(getIt<IReferenceCatalog>()),
    )
    ..registerFactory<YoutubePlayerWrapper>(YoutubePlayerWrapper.new)
    ..registerFactory<YoutubePlayerCubit>(
      () => YoutubePlayerCubit(getIt<YoutubePlayerWrapper>()),
    );
}
