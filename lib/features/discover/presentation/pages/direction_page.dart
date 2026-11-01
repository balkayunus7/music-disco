import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/opacities.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/caption_label.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/reference_aspect.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/distance_slider.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';
import 'package:music_disco/features/discover/presentation/widgets/preferences_summary.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_avatar.dart';

part '../widgets/direction_card.dart';
part '../widgets/direction_context.dart';
part '../widgets/direction_option_tile.dart';

class DirectionPage extends StatefulWidget {
  const DirectionPage({super.key, required this.loadingRoute});
  final String loadingRoute;

  @override
  State<DirectionPage> createState() => _DirectionPageState();
}

class _DirectionPageState extends State<DirectionPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  void _onDirectionSelected(DiscoveryDirection direction) {
    context.read<DiscoverCubit>().selectDirection(direction);
  }

  void _onChangeSource(bool isReference) {
    context.go(isReference ? AppRoutes.reference : AppRoutes.mood);
  }

  void _onContinue() {
    context.go(widget.loadingRoute);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.select<DiscoverCubit, DiscoveryPreferences>(
      (cubit) => cubit.state.preferences,
    );
    final reference = preferences.activeReference;
    return AppPageScaffold(
      pageBar: AppPageBar(
        title: LocaleKeys.direction_step.tr(),
        showBackButton: true,
      ),
      footer: AppCtaButton(
        text: LocaleKeys.direction_continue.tr(),
        onTap: _onContinue,
      ),
      children: [
        AppPageHeadline(
          first: LocaleKeys.direction_title_first.tr(),
          second: LocaleKeys.direction_title_second.tr(),
        ),
        Sp.s16.heightBox,
        Text(
          LocaleKeys.direction_subtitle.tr(),
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        Sp.s20.heightBox,
        DirectionContext(
          reference: reference,
          mood: preferences.anchorMood,
          aspect: preferences.aspect,
          onChange: () => _onChangeSource(reference != null),
        ),
        Sp.s24.heightBox,
        Text(
          LocaleKeys.direction_choice_title.tr(),
          style: buttonTextStyle(context),
        ),
        Sp.s12.heightBox,
        DirectionCard(
          mood: preferences.anchorMood,
          direction: preferences.direction,
          onSelected: _onDirectionSelected,
        ),
        Sp.s24.heightBox,
        Text(LocaleKeys.distance_title.tr(), style: buttonTextStyle(context)),
        Sp.s12.heightBox,
        DistanceSlider(
          value: preferences.distance,
          mood: preferences.anchorMood,
          onChanged: context.read<DiscoverCubit>().selectDistance,
        ),
        DistanceSliderLabels(value: preferences.distance),
        Sp.s20.heightBox,
        PreferencesSummary(preferences: preferences),
      ],
    );
  }
}
