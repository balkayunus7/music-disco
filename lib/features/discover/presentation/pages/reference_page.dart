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
import 'package:music_disco/core/widgets/choice_tile.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/page_back_button.dart';
import 'package:music_disco/core/widgets/search_field.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/bloc/reference_search_cubit.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/reference_aspect.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';
import 'package:music_disco/features/discover/presentation/widgets/reference_row.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';

part '../widgets/reference_aspect_grid.dart';
part '../widgets/reference_search_panel.dart';
part '../widgets/reference_spotlight.dart';

class ReferencePage extends StatelessWidget {
  const ReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<ReferenceSearchCubit>()..load(), child: const _ReferenceView());
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
  late ReferenceAspect _aspect = context.read<DiscoverCubit>().state.preferences.aspect;
  late bool _isSearching = _reference == null;

  MusicReference? _initialReference() {
    final saved = context.read<DiscoverCubit>().state.preferences.reference;
    if (saved != null) return saved;
    final references = context.read<TasteCubit>().state.saved.references;
    return references.isEmpty ? null : references.first;
  }

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
    setState(() => _isSearching = true);
  }

  void _onContinue() {
    final reference = _reference;
    if (reference == null) return;
    context.read<DiscoverCubit>().selectReference(reference, _aspect);
    context.go(AppRoutes.referenceDirection);
  }

  @override
  Widget build(BuildContext context) {
    final reference = _reference;
    final canContinue = reference != null && !_isSearching;
    return BrandPageBody(
      children: [
        Row(children: [const PageBackButton(), const Spacer(), EyebrowText(LocaleKeys.reference_step.tr())]),
        Sp.medium.heightBox,
        DisplayHeadline(first: LocaleKeys.reference_title_first.tr(), second: LocaleKeys.reference_title_second.tr()),
        Sp.medium.heightBox,
        Text(LocaleKeys.reference_subtitle.tr(), style: m14w500(context).copyWith(color: context.colors.textSecondary)),
        Sp.large.heightBox,
        AnimatedSwitcher(
          duration: 320.ms,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, axisAlignment: -1, child: child),
          ),
          child: _isSearching || reference == null
              ? ReferenceSearchPanel(
                  key: const ValueKey('search'),
                  controller: _query,
                  focusNode: _searchFocus,
                  selectedId: reference?.id,
                  onPicked: _onPicked,
                )
              : Column(
                  key: const ValueKey('spotlight'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReferenceSpotlight(reference: reference),
                    Center(
                      child: TextLink(text: LocaleKeys.reference_change.tr(), onTap: _onChangeReference),
                    ),
                    Sp.medium.heightBox,
                    Text(LocaleKeys.reference_aspect_title.tr(), style: m16w700(context)),
                    Sp.small.heightBox,
                    ReferenceAspectGrid(selected: _aspect, onSelected: (aspect) => setState(() => _aspect = aspect)),
                  ],
                ),
        ),
        Sp.large.heightBox,
        CtaBar(
          text: canContinue ? LocaleKeys.reference_continue.tr() : LocaleKeys.reference_pick_first.tr(),
          onTap: canContinue ? _onContinue : null,
        ),
      ],
    );
  }
}
