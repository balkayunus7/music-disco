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
import 'package:music_disco/core/widgets/adaptive_animated_size.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/search_field.dart';
import 'package:music_disco/features/discover/bloc/reference_search_cubit.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_row.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';
import 'package:music_disco/features/taste/presentation/widgets/taste_limit_text.dart';

part '../widgets/selected_reference_chips.dart';

class TasteReferencesPage extends StatelessWidget {
  const TasteReferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReferenceSearchCubit>()..load(),
      child: const _TasteReferencesView(),
    );
  }
}

class _TasteReferencesView extends StatefulWidget {
  const _TasteReferencesView();

  @override
  State<_TasteReferencesView> createState() => _TasteReferencesViewState();
}

class _TasteReferencesViewState extends State<_TasteReferencesView>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TasteCubit>().dismissNotice();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taste = context.read<TasteCubit>();
    final search = context.read<ReferenceSearchCubit>();
    return BlocBuilder<TasteCubit, TasteState>(
      buildWhen: (previous, current) =>
          previous.draft != current.draft || previous.notice != current.notice,
      builder: (context, state) {
        final draft = state.draft;
        final isLimited = state.notice == TasteNotice.referenceLimit;
        return AppPageScaffold(
          pageBar: AppPageBar(
            title: LocaleKeys.taste_references_step.tr(),
            showBackButton: true,
          ),
          footer: AppCtaButton(
            text: LocaleKeys.taste_back_to_preferences.tr(),
            onTap: () => context.pop(),
          ),
          children: [
            AppPageHeadline(
              first: LocaleKeys.taste_references_title_first.tr(),
              second: LocaleKeys.taste_references_title_second.tr(),
            ),
            Sp.s16.heightBox,
            Text(
              LocaleKeys.taste_references_subtitle.tr(),
              style: bodyTextStyle(
                context,
              ).copyWith(color: context.colors.textSecondary),
            ),
            Sp.s24.heightBox,
            SearchField(
              controller: _query,
              hint: LocaleKeys.search_hint.tr(),
              clearLabel: LocaleKeys.search_clear.tr(),
              onChanged: search.updateQuery,
            ),
            Sp.s16.heightBox,
            SelectedReferenceChips(
              references: draft.references,
              onRemove: taste.removeReference,
            ),
            BlocBuilder<ReferenceSearchCubit, ReferenceSearchState>(
              builder: (context, results) => _ResultList(
                search: results,
                draft: draft,
                onToggle: taste.toggleReference,
              ),
            ),
            Sp.s16.heightBox,
            TasteLimitText(
              status: draft.referenceStatus,
              limitMessage: LocaleKeys.taste_references_limit.tr(),
              isLimited: isLimited,
              style: bodyTextStyle(context),
            ),
          ],
        );
      },
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.search,
    required this.draft,
    required this.onToggle,
  });
  final ReferenceSearchState search;
  final TasteProfile draft;
  final ValueChanged<MusicReference> onToggle;

  @override
  Widget build(BuildContext context) {
    final message = switch (search) {
      ReferenceSearchState(status: SearchStatus.failure) =>
        LocaleKeys.search_error.tr(),
      ReferenceSearchState(isEmptyResult: true) =>
        LocaleKeys.search_no_results.tr(),
      _ => null,
    };
    return AdaptiveAnimatedSize(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (search.status == SearchStatus.loading)
            LinearProgressIndicator(
              color: context.colors.primary,
              backgroundColor: context.colors.borderSecondary,
            ),
          if (!search.hasQuery && search.results.isNotEmpty) ...[
            Text(
              LocaleKeys.reference_suggested_title.tr(),
              style: sectionTitleStyle(context),
            ),
            Sp.s12.heightBox,
          ],
          for (final reference in search.results)
            ReferenceRow(
              key: ValueKey(reference.id),
              reference: reference,
              hasDivider: true,
              isSelected: draft.hasReference(reference.id),
              semanticLabel: draft.hasReference(reference.id)
                  ? LocaleKeys.reference_remove.tr(args: [reference.name])
                  : LocaleKeys.reference_add.tr(args: [reference.name]),
              onTap: () => onToggle(reference),
              trailing: ReferenceToggleMark(
                isSelected: draft.hasReference(reference.id),
              ),
            ),
          if (message != null)
            Padding(
              padding: Sp.s16.padVR,
              child: Text(
                message,
                style: bodyTextStyle(
                  context,
                ).copyWith(color: context.colors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
