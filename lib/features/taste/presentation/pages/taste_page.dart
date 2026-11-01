import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_choice_chip.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/app_snackbar.dart';
import 'package:music_disco/core/widgets/fade_slide_in.dart';
import 'package:music_disco/core/widgets/pill_label.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_row.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';

part '../widgets/taste_section.dart';

class TastePage extends StatefulWidget {
  const TastePage({super.key, this.routeBase = AppRoutes.taste});
  final String routeBase;

  @override
  State<TastePage> createState() => _TastePageState();
}

class _TastePageState extends State<TastePage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  TasteCubit get _taste => context.read<TasteCubit>();

  @override
  void initState() {
    super.initState();
    _taste.startEditing();
  }

  Future<void> _onSave() async {
    final saved = await _taste.save();
    if (!mounted) return;
    if (!saved) {
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
      return;
    }
    showAppSnackBar(context, message: LocaleKeys.taste_saved_snackbar.tr());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.select<TasteCubit, TasteProfile>(
      (cubit) => cubit.state.draft,
    );
    final isSaving = context.select<TasteCubit, bool>(
      (cubit) => cubit.state.isSaving,
    );
    return AppPageScaffold(
      pageBar: AppPageBar(
        title: LocaleKeys.taste_eyebrow.tr(),
        showBackButton: true,
      ),
      footer: AppCtaButton(
        text: LocaleKeys.taste_save.tr(),
        icon: Icons.check_rounded,
        onTap: isSaving ? null : _onSave,
      ),
      children: [
        AppPageHeadline(
          first: LocaleKeys.taste_title_first.tr(),
          second: LocaleKeys.taste_title_second.tr(),
        ),
        Sp.s16.heightBox,
        Text(
          LocaleKeys.taste_subtitle.tr(),
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        Sp.s24.heightBox,
        FadeSlideIn(
          order: 0,
          child: TasteSection(
            title: LocaleKeys.taste_genres_title.tr(),
            onEdit: () => context.go('${widget.routeBase}/genres'),
            child: Wrap(
              spacing: Sp.s8.w,
              runSpacing: Sp.s8.h,
              children: [
                for (final label in draft.genreLabels) PillLabel(text: label),
              ],
            ),
          ),
        ),
        const TasteDivider(),
        FadeSlideIn(
          order: 1,
          child: TasteSection(
            title: LocaleKeys.taste_references_title.tr(),
            onEdit: () => context.go('${widget.routeBase}/references'),
            child: draft.references.isEmpty
                ? Text(
                    LocaleKeys.taste_references_empty.tr(),
                    style: bodyTextStyle(
                      context,
                    ).copyWith(color: context.colors.textSecondary),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final reference in draft.references)
                        ReferenceRow(
                          key: ValueKey(reference.id),
                          reference: reference,
                        ),
                    ],
                  ),
          ),
        ),
        const TasteDivider(),
        FadeSlideIn(
          order: 2,
          child: TasteSection(
            title: LocaleKeys.taste_language_title.tr(),
            child: Wrap(
              spacing: Sp.s8.w,
              runSpacing: Sp.s8.h,
              children: [
                for (final language in MusicLanguage.values)
                  AppChoiceChip(
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
