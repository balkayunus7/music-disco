import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/page_back_button.dart';
import 'package:music_disco/core/widgets/pill_label.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/distance_slider.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

part '../widgets/direction_card.dart';
part '../widgets/direction_option_tile.dart';

class DirectionPage extends StatefulWidget {
  const DirectionPage({super.key});

  @override
  State<DirectionPage> createState() => _DirectionPageState();
}

class _DirectionPageState extends State<DirectionPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  void _onDirectionSelected(DiscoveryDirection direction) {
    HapticFeedback.selectionClick();
    context.read<DiscoverCubit>().selectDirection(direction);
  }

  void _onContinue() {
    context.read<DiscoverCubit>().startRound();
    context.go(AppRoutes.session);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.select<DiscoverCubit, DiscoveryPreferences>(
      (cubit) => cubit.state.preferences,
    );
    return BrandPageBody(
      children: [
        Row(
          children: [
            const PageBackButton(),
            const Spacer(),
            EyebrowText(LocaleKeys.direction_step.tr()),
          ],
        ),
        Sp.large.heightBox,
        DisplayHeadline(
          first: LocaleKeys.direction_title_first.tr(),
          second: LocaleKeys.direction_title_second.tr(),
        ),
        Sp.medium.heightBox,
        Text(
          LocaleKeys.direction_subtitle.tr(),
          style: m14w500(context).copyWith(color: context.colors.textSecondary),
        ),
        Sp.xxlarge.heightBox,
        Row(
          children: [
            Expanded(
              child: EyebrowText(LocaleKeys.direction_selected_frequency.tr()),
            ),
            PillLabel(text: preferences.mood.labelKey.tr(), dense: true),
          ],
        ),
        Sp.small.heightBox,
        DirectionCard(
          mood: preferences.mood,
          direction: preferences.direction,
          onSelected: _onDirectionSelected,
        ),
        Sp.xxlarge.heightBox,
        Row(
          children: [
            Expanded(
              child: Text(
                LocaleKeys.distance_title.tr(),
                style: m14w700(context),
              ),
            ),
            PillLabel(text: preferences.distance.labelKey.tr(), dense: true),
          ],
        ),
        Sp.small.heightBox,
        DistanceSlider(
          value: preferences.distance,
          mood: preferences.mood,
          onChanged: context.read<DiscoverCubit>().selectDistance,
        ),
        const DistanceSliderLabels(),
        Sp.xlarge.heightBox,
        Center(
          child: CtaBar(
            text: LocaleKeys.direction_continue.tr(),
            compact: true,
            onTap: _onContinue,
          ),
        ),
      ],
    );
  }
}
