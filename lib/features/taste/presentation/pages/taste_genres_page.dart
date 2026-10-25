import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/core/widgets/choice_tile.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/holo_disc.dart';
import 'package:music_disco/core/widgets/page_back_button.dart';
import 'package:music_disco/core/widgets/step_progress.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/genre.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';

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
      buildWhen: (previous, current) => previous.draft != current.draft || previous.notice != current.notice,
      builder: (context, state) {
        final draft = state.draft;
        final isLimited = state.notice == TasteNotice.genreLimit;
        return BrandPageBody(
          footer: CtaBar(text: LocaleKeys.taste_back_to_preferences.tr(), onTap: () => context.pop()),
          children: [
            Row(children: [const PageBackButton(), const Spacer(), EyebrowText(LocaleKeys.taste_genres_step.tr())]),
            Sp.medium.heightBox,
            const StepProgress(current: 1, total: 2),
            Sp.xlarge.heightBox,
            DisplayHeadline(
              first: LocaleKeys.taste_genres_title_first.tr(),
              second: LocaleKeys.taste_genres_title_second.tr(),
            ),
            Sp.medium.heightBox,
            Text(
              LocaleKeys.taste_genres_subtitle.tr(),
              style: m14w500(context).copyWith(color: context.colors.textSecondary),
            ),
            Sp.xlarge.heightBox,
            TasteSoundCard(profile: draft),
            Sp.medium.heightBox,
            TasteGenreGrid(selected: draft.isMixed ? const [] : draft.genres, onToggle: taste.toggleGenre),
            Sp.medium.heightBox,
            AnimatedSwitcher(
              duration: 220.ms,
              layoutBuilder: (current, previous) =>
                  Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
              child: Text(
                isLimited ? LocaleKeys.taste_genres_limit.tr() : draft.genreStatus,
                key: ValueKey(isLimited ? 'limit' : draft.genreStatus),
                style: m12w500(
                  context,
                ).copyWith(color: isLimited ? context.colors.textPrimary : context.colors.textSecondary),
              ),
            ),
            Sp.medium.heightBox,
            ChoiceTile(
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
