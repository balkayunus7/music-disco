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
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/page_back_button.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/search_field.dart';
import 'package:music_disco/core/widgets/step_progress.dart';
import 'package:music_disco/features/discover/bloc/reference_search_cubit.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_row.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';

part '../widgets/reference_kind_tabs.dart';
part '../widgets/selected_reference_chips.dart';

class TasteReferencesPage extends StatelessWidget {
  const TasteReferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ReferenceSearchCubit>()..load(kind: ReferenceKind.artist),
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
        return BrandPageBody(
          footer: CtaBar(
            text: LocaleKeys.taste_back_to_preferences.tr(),
            onTap: () => context.pop(),
          ),
          children: [
            Row(
              children: [
                const PageBackButton(),
                const Spacer(),
                EyebrowText(LocaleKeys.taste_references_step.tr()),
              ],
            ),
            Sp.medium.heightBox,
            const StepProgress(current: 2, total: 2),
            Sp.xlarge.heightBox,
            DisplayHeadline(
              first: LocaleKeys.taste_references_title_first.tr(),
              second: LocaleKeys.taste_references_title_second.tr(),
            ),
            Sp.medium.heightBox,
            Text(
              LocaleKeys.taste_references_subtitle.tr(),
              style: m14w500(
                context,
              ).copyWith(color: context.colors.textSecondary),
            ),
            Sp.xlarge.heightBox,
            SearchField(
              controller: _query,
              hint: LocaleKeys.search_hint.tr(),
              clearLabel: LocaleKeys.search_clear.tr(),
              onChanged: search.updateQuery,
            ),
            Sp.medium.heightBox,
            BlocSelector<
              ReferenceSearchCubit,
              ReferenceSearchState,
              ReferenceKind?
            >(
              selector: (search) => search.kind,
              builder: (context, kind) => ReferenceKindTabs(
                selected: kind ?? ReferenceKind.artist,
                onSelected: search.selectKind,
              ),
            ),
            Sp.medium.heightBox,
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
            Sp.medium.heightBox,
            AnimatedSwitcher(
              duration: 220.ms,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: Text(
                isLimited
                    ? LocaleKeys.taste_references_limit.tr()
                    : draft.referenceStatus,
                key: ValueKey(isLimited ? 'limit' : draft.referenceStatus),
                style: m13w500(context).copyWith(
                  color: isLimited
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
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
    return AnimatedSize(
      duration: 240.ms,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              padding: Sp.medium.padVR,
              child: Text(
                message,
                style: m13w500(
                  context,
                ).copyWith(color: context.colors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
