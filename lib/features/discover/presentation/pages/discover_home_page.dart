import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/design_system/typography.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/adaptive_animated_size.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/fade_slide_in.dart';
import 'package:music_disco/core/widgets/pill_label.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/discovery_source.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_avatar.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';

part '../widgets/studio_disc_duo.dart';
part '../widgets/studio_option_card.dart';
part '../widgets/studio_starting_point.dart';
part '../widgets/studio_resume_card.dart';

class DiscoverHomePage extends StatefulWidget {
  const DiscoverHomePage({super.key});

  @override
  State<DiscoverHomePage> createState() => _DiscoverHomePageState();
}

class _DiscoverHomePageState extends State<DiscoverHomePage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  void _openTaste() => context.go(AppRoutes.taste);

  void _resume(DiscoverySource source) {
    context.go(switch (source) {
      DiscoverySource.mood => AppRoutes.moodSession,
      DiscoverySource.reference => AppRoutes.referenceSession,
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.select<TasteCubit, TasteProfile>(
      (cubit) => cubit.state.saved,
    );
    final roundSource = context.select<DiscoverCubit, DiscoverySource?>(
      (cubit) => cubit.state.canResume ? cubit.state.roundSource : null,
    );
    return AppPageScaffold(
      topSpacing: Sp.s4,
      pageBar: AppPageBar(title: LocaleKeys.studio_eyebrow.tr()),
      children: [
        FadeSlideIn(
          order: 1,
          child: AppPageHeadline(
            role: HeadlineRole.home,
            first: LocaleKeys.studio_title_first.tr(),
            second: LocaleKeys.studio_title_second.tr(),
          ),
        ),
        Sp.s8.heightBox,
        FadeSlideIn(
          order: 2,
          child: Text(
            LocaleKeys.studio_subtitle.tr(),
            style: bodyTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
        ),
        Sp.s20.heightBox,
        FadeSlideIn(
          order: 3,
          child: StudioOptionCard(
            icon: Icons.graphic_eq_rounded,
            title: LocaleKeys.studio_by_feeling_title.tr(),
            subtitle: LocaleKeys.studio_by_feeling_subtitle.tr(),
            isPrimary: true,
            onTap: () => context.go(AppRoutes.mood),
          ),
        ),
        Sp.s8.heightBox,
        FadeSlideIn(
          order: 4,
          child: StudioOptionCard(
            icon: Icons.album_outlined,
            title: LocaleKeys.studio_similar_title.tr(),
            subtitle: LocaleKeys.studio_similar_subtitle.tr(),
            onTap: () => context.go(AppRoutes.reference),
          ),
        ),
        Sp.s24.heightBox,
        const FadeSlideIn(order: 5, child: StudioDiscDuo()),
        Sp.s24.heightBox,
        Divider(height: 1, color: context.colors.borderSecondary),
        Sp.s4.heightBox,
        FadeSlideIn(
          order: 6,
          child: StudioStartingPoint(
            genreLabels: profile.startingGenreLabels,
            references: profile.references,
            onEdit: _openTaste,
          ),
        ),
        AdaptiveAnimatedSize(
          alignment: Alignment.topCenter,
          child: roundSource == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: Sp.s16.padTopR,
                  child: StudioResumeCard(onTap: () => _resume(roundSource)),
                ),
        ),
      ],
    );
  }
}
