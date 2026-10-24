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
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/holo_disc.dart';
import 'package:music_disco/core/widgets/jewel_case.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

part '../widgets/collection_grid.dart';

/// Songs that stayed with the listener.
class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  void _backToDiscover() {
    final resumePoint = context.read<DiscoverCubit>().state.resumePoint;
    switch (resumePoint) {
      case DiscoverResumePoint.session:
        StatefulNavigationShell.of(context).goBranch(0);
      case DiscoverResumePoint.direction:
        context.go(AppRoutes.direction);
      case DiscoverResumePoint.mood:
        context.go(AppRoutes.discover);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = context.select<CollectionCubit, List<Track>>(
      (cubit) => cubit.state.tracks,
    );
    return BrandPageBody(
      children: [
        Sp.xxlarge.heightBox,
        EyebrowText(LocaleKeys.collection_eyebrow.tr()),
        Sp.large.heightBox,
        DisplayHeadline(
          first: LocaleKeys.collection_title_first.tr(),
          second: LocaleKeys.collection_title_second.tr(),
        ),
        Sp.medium.heightBox,
        Text(
          LocaleKeys.collection_subtitle.tr(),
          style: m15w500(context).copyWith(color: context.colors.textSecondary),
        ),
        Sp.xxlarge.heightBox,
        if (tracks.isEmpty)
          const CollectionEmptyView()
        else
          CollectionGrid(tracks: tracks),
        Sp.xxlarge.heightBox,
        CtaBar(
          text: LocaleKeys.collection_back_to_discover.tr(),
          onTap: _backToDiscover,
        ),
      ],
    );
  }
}
