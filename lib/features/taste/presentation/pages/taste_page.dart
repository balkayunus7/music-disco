import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/app_snack_bar.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/core/widgets/choice_tile.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/entrance_fade.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/page_back_button.dart';
import 'package:music_disco/core/widgets/pill_label.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_row.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';

part '../widgets/taste_section.dart';

class TastePage extends StatefulWidget {
  const TastePage({super.key});

  @override
  State<TastePage> createState() => _TastePageState();
}

class _TastePageState extends State<TastePage> with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  TasteCubit get _taste => context.read<TasteCubit>();

  @override
  void initState() {
    super.initState();
    _taste.startEditing();
  }

  void _onSave() {
    _taste.save();
    showAppSnackBar(context, message: LocaleKeys.taste_saved_snackbar.tr());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.select<TasteCubit, TasteProfile>((cubit) => cubit.state.draft);
    return BrandPageBody(
      footer: CtaBar(text: LocaleKeys.taste_save.tr(), icon: Icons.check_rounded, onTap: _onSave),
      children: [
        Row(children: [const PageBackButton(), const Spacer(), EyebrowText(LocaleKeys.taste_eyebrow.tr())]),
        Sp.medium.heightBox,
        DisplayHeadline(first: LocaleKeys.taste_title_first.tr(), second: LocaleKeys.taste_title_second.tr()),
        Sp.medium.heightBox,
        Text(LocaleKeys.taste_subtitle.tr(), style: m14w500(context).copyWith(color: context.colors.textSecondary)),
        Sp.xlarge.heightBox,
        EntranceFade(
          order: 0,
          child: TasteSection(
            title: LocaleKeys.taste_genres_title.tr(),
            onEdit: () => context.go(AppRoutes.tasteGenres),
            child: Wrap(
              spacing: Sp.xsmall.w,
              runSpacing: Sp.xsmall.h,
              children: [for (final label in draft.genreLabels) PillLabel(text: label, dense: true)],
            ),
          ),
        ),
        const TasteDivider(),
        EntranceFade(
          order: 1,
          child: TasteSection(
            title: LocaleKeys.taste_references_title.tr(),
            onEdit: () => context.go(AppRoutes.tasteReferences),
            child: draft.references.isEmpty
                ? Text(
                    LocaleKeys.taste_references_empty.tr(),
                    style: m13w500(context).copyWith(color: context.colors.textSecondary),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final reference in draft.references)
                        ReferenceRow(key: ValueKey(reference.id), reference: reference),
                    ],
                  ),
          ),
        ),
        const TasteDivider(),
        EntranceFade(
          order: 2,
          child: TasteSection(
            title: LocaleKeys.taste_language_title.tr(),
            child: Wrap(
              spacing: Sp.xsmall.w,
              runSpacing: Sp.xsmall.h,
              children: [
                for (final language in MusicLanguage.values)
                  ChoiceTile(
                    label: language.labelKey.tr(),
                    isExpanded: false,
                    isSelected: draft.language == language,
                    onTap: () => _taste.selectLanguage(language),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
