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
import 'package:music_disco/core/widgets/holo_disc.dart';
import 'package:music_disco/core/widgets/jewel_case.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

part '../widgets/collection_grid.dart';
part '../widgets/collection_shelf_chips.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  CollectionShelf? _shelf;

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionCubit>().state;
    final tracks = collection.tracksIn(_shelf);
    return BrandPageBody(
      children: [
        EyebrowText(LocaleKeys.collection_eyebrow.tr()),
        Sp.large.heightBox,
        DisplayHeadline(first: LocaleKeys.collection_title_first.tr(), second: LocaleKeys.collection_title_second.tr()),
        Sp.medium.heightBox,
        Text(
          LocaleKeys.collection_subtitle.tr(),
          style: m14w500(context).copyWith(color: context.colors.textSecondary),
        ),
        Sp.xlarge.heightBox,
        CollectionShelfChips(
          collection: collection,
          selected: _shelf,
          onSelected: (shelf) => setState(() => _shelf = shelf),
        ),
        Sp.xlarge.heightBox,
        AnimatedSwitcher(
          duration: 280.ms,
          switchInCurve: Curves.easeOutCubic,
          layoutBuilder: (current, previous) =>
              Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
          child: KeyedSubtree(
            key: ValueKey(_shelf),
            child: switch ((tracks.isEmpty, _shelf)) {
              (true, null) => const CollectionEmptyView(),
              (true, _) => const CollectionShelfEmptyView(),
              _ => CollectionGrid(tracks: tracks),
            },
          ),
        ),
        Sp.xxlarge.heightBox,
        CtaBar(text: LocaleKeys.collection_back_to_discover.tr(), onTap: () => context.go(AppRoutes.discover)),
        Sp.small.heightBox,
        Center(
          child: TextLink(text: LocaleKeys.taste_edit.tr(), onTap: () => context.go(AppRoutes.taste)),
        ),
      ],
    );
  }
}
