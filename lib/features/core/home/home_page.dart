import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/shelf_icon.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/core/home/helpers/home_page_mixin.dart';
import 'package:music_disco/features/core/home/helpers/home_page_scope.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';

part 'widgets/home_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.navigationShell,
    this.isNavBarHidden = false,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final bool isNavBarHidden;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        HomePageMixin,
        RouteAwareAnalyticsMixin,
        RouteAwareAnalyticsPageParamsMixin {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<DiscoverCubit>()),
        BlocProvider(create: (_) => getIt<CollectionCubit>()),
        BlocProvider(create: (_) => getIt<TasteCubit>()),
      ],
      child: HomePageScope(
        state: this,
        child: Scaffold(
          backgroundColor: context.colors.background,
          body: widget.navigationShell,
          bottomNavigationBar: HomeNavBarReveal(
            isHidden: widget.isNavBarHidden,
            child: HomeNavBar(
              currentIndex: widget.navigationShell.currentIndex,
              collectionTargetKey: collectionTargetKey,
              landingPulse: landingPulse,
              onTap: onNavTap,
            ),
          ),
        ),
      ),
    );
  }
}
