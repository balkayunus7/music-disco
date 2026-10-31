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
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/app_page_bar.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/search_field.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/bloc/reference_search_cubit.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/reference_aspect.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_avatar.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_row.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';

part '../widgets/reference_aspect_grid.dart';
part '../widgets/reference_quick_picks.dart';
part '../widgets/reference_search_panel.dart';
part '../widgets/reference_spotlight.dart';

class ReferencePage extends StatelessWidget {
  const ReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReferenceSearchCubit>()
        ..load(
          references: [
            ...context.read<TasteCubit>().state.saved.references,
            ?context.read<DiscoverCubit>().state.preferences.reference,
          ],
        ),
      child: const _ReferenceView(),
    );
  }
}

class _ReferenceView extends StatefulWidget {
  const _ReferenceView();

  @override
  State<_ReferenceView> createState() => _ReferenceViewState();
}

class _ReferenceViewState extends State<_ReferenceView>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  final TextEditingController _query = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late MusicReference? _reference = _initialReference();
  late ReferenceAspect _aspect = context
      .read<DiscoverCubit>()
      .state
      .preferences
      .aspect;
  late bool _isSearching = _reference == null;
  bool _focusSearch = false;

  MusicReference? _initialReference() =>
      context.read<DiscoverCubit>().state.preferences.reference;

  @override
  void dispose() {
    _query.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onPicked(MusicReference reference) {
    _searchFocus.unfocus();
    _query.clear();
    context.read<ReferenceSearchCubit>().updateQuery('');
    setState(() {
      _reference = reference;
      _isSearching = false;
    });
  }

  void _onChangeReference() {
    setState(() {
      _isSearching = true;
      _focusSearch = true;
    });
  }

  void _onCancelSearch() {
    _searchFocus.unfocus();
    _query.clear();
    context.read<ReferenceSearchCubit>().updateQuery('');
    setState(() => _isSearching = false);
  }

  void _onContinue() {
    final reference = _reference;
    if (reference == null) return;
    final current = context.read<ReferenceSearchCubit>().state.resolve(
      reference,
    );
    context.read<DiscoverCubit>().selectReference(current, _aspect);
    context.go(AppRoutes.referenceDirection);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ReferenceSearchCubit>().state;
    final reference = _reference == null ? null : catalog.resolve(_reference!);
    final canContinue = reference != null && !_isSearching;
    final savedReferences = context.select<TasteCubit, List<MusicReference>>(
      (cubit) => cubit.state.saved.references,
    );
    final quickPicks = [
      for (final saved in savedReferences)
        if (saved.id != reference?.id) catalog.resolve(saved),
    ];
    return BrandPageBody(
      appBar: AppPageBar(
        title: LocaleKeys.reference_step.tr(),
        showBackButton: true,
      ),
      footer: CtaBar(
        text: canContinue
            ? LocaleKeys.discovery_continue.tr()
            : LocaleKeys.reference_pick_first.tr(),
        onTap: canContinue ? _onContinue : null,
      ),
      children: [
        DisplayHeadline(
          first: LocaleKeys.reference_title_first.tr(),
          second: LocaleKeys.reference_title_second.tr(),
        ),
        Sp.medium.heightBox,
        Text(
          LocaleKeys.reference_subtitle.tr(),
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        Sp.large.heightBox,
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : 320.ms,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: _isSearching || reference == null
              ? ReferenceSearchPanel(
                  key: const ValueKey('search'),
                  controller: _query,
                  focusNode: _searchFocus,
                  selected: reference,
                  autofocus: _focusSearch,
                  onPicked: _onPicked,
                  onCancel: reference == null ? null : _onCancelSearch,
                )
              : Column(
                  key: const ValueKey('spotlight'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReferenceSpotlight(
                      reference: reference,
                      onChange: _onChangeReference,
                    ),
                    if (quickPicks.isNotEmpty) ...[
                      Sp.large.heightBox,
                      ReferenceQuickPicks(
                        references: quickPicks,
                        onPicked: _onPicked,
                      ),
                    ],
                    Sp.large.heightBox,
                    Text(
                      LocaleKeys.reference_aspect_title.tr(),
                      style: sectionTitleStyle(context),
                    ),
                    Sp.small.heightBox,
                    ReferenceAspectGrid(
                      selected: _aspect,
                      onSelected: (aspect) => setState(() => _aspect = aspect),
                    ),
                    Sp.large.heightBox,
                    ReferenceSummary(reference: reference, aspect: _aspect),
                  ],
                ),
        ),
      ],
    );
  }
}
