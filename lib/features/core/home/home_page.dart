import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_arguments.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/features/core/home/helpers/home_page_mixin.dart';
import 'package:music_disco/features/core/home/helpers/home_page_scope.dart';

part 'widgets/guest_session_card.dart';
part 'widgets/home_welcome_view.dart';

class HomePageArguments extends RouteArguments {
  HomePageArguments(
    super.context, {
    this.initialTabIndex = 0,
    this.forceUpdateKey,
  });
  final int initialTabIndex;
  final String? forceUpdateKey;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'initial_tab_index': initialTabIndex,
      'force_update_key': forceUpdateKey,
    };
  }
}

class HomePage extends StatefulWidget {
  const HomePage({required this.arguments, super.key});
  final HomePageArguments arguments;

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
    return HomePageScope(
      state: this,
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: const [HomeWelcomeView()],
        ),
      ),
    );
  }
}
