import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_choice_chip.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/caption_label.dart';
import 'package:music_disco/core/widgets/disc_cover.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';
import 'package:music_disco/features/taste/presentation/widgets/taste_limit_text.dart';

part '../widgets/taste_genre_grid.dart';
part '../widgets/taste_sound_card.dart';

class TasteGenresPage extends StatefulWidget {
  const TasteGenresPage({super.key});

  @override
  State<TasteGenresPage> createState() => _TasteGenresPageState();
}

class _TasteGenresPageState extends State<TasteGenresPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  @override
  void initState() {
    super.initState();
    context.read<TasteCubit>().dismissNotice();
  }

  @override
  Widget build(BuildContext context) {
    final taste = context.read<TasteCubit>();
    return BlocBuilder<TasteCubit, TasteState>(
      buildWhen: (previous, current) =>
          previous.draft != current.draft || previous.notice != current.notice,
      builder: (context, state) {
        final draft = state.draft;
        final isLimited = state.notice == TasteNotice.genreLimit;
        return AppPageScaffold(
          pageBar: AppPageBar(
            title: LocaleKeys.taste_genres_step.tr(),
            showBackButton: true,
          ),
          footer: AppCtaButton(
            text: LocaleKeys.taste_back_to_preferences.tr(),
            onTap: () => context.pop(),
          ),
          children: [
            AppPageHeadline(
              first: LocaleKeys.taste_genres_title_first.tr(),
              second: LocaleKeys.taste_genres_title_second.tr(),
            ),
            Sp.s16.heightBox,
            Text(
              LocaleKeys.taste_genres_subtitle.tr(),
              style: bodyTextStyle(
                context,
              ).copyWith(color: context.colors.textSecondary),
            ),
            Sp.s24.heightBox,
            TasteSoundCard(profile: draft),
            Sp.s16.heightBox,
            TasteGenreGrid(
              selected: draft.isMixed ? const [] : draft.genres,
              onToggle: taste.toggleGenre,
            ),
            Sp.s16.heightBox,
            TasteLimitText(
              status: draft.genreStatus,
              limitMessage: LocaleKeys.taste_genres_limit.tr(),
              isLimited: isLimited,
              style: secondaryTextStyle(context),
            ),
            Sp.s16.heightBox,
            AppChoiceChip(
              label: LocaleKeys.taste_mixed.tr(),
              icon: Icons.shuffle_rounded,
              isSelected: draft.isMixed,
              onTap: taste.toggleMixed,
            ),
          ],
        );
      },
    );
  }
}
