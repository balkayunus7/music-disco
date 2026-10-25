import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:music_disco/core/widgets/disc_flight.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/holo_disc.dart';
import 'package:music_disco/core/widgets/jewel_case.dart';
import 'package:music_disco/core/widgets/page_back_button.dart';
import 'package:music_disco/core/widgets/pill_label.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

part '../widgets/mood_case_stage.dart';
part '../widgets/mood_disc_grid.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  final GlobalKey _caseDiscKey = GlobalKey();
  final Map<Mood, GlobalKey> _slotKeys = {for (final mood in Mood.values) mood: GlobalKey()};

  final Set<Mood> _airborne = {};
  late Mood? _caseMood = context.read<DiscoverCubit>().state.preferences.mood;

  static const double _caseDiscSize = 176;

  Future<void> _onMoodSelected(Mood next) async {
    final cubit = context.read<DiscoverCubit>();
    final previous = cubit.state.preferences.mood;
    if (next == previous || _airborne.isNotEmpty) return;

    cubit.selectMood(next);

    final caseRect = _globalRect(_caseDiscKey);
    final nextSlot = _globalRect(_slotKeys[next]!);
    final previousSlot = _globalRect(_slotKeys[previous]!);
    if (!mounted) return;
    if (caseRect == null || nextSlot == null || previousSlot == null) {
      setState(() => _caseMood = next);
      return;
    }

    setState(() {
      _airborne.addAll({next, previous});
      _caseMood = null;
    });
    await Future.wait([
      flyDisc(
        context,
        from: nextSlot,
        to: caseRect,
        arcHeight: 60,
        turns: 0.75,
        child: MoodDisc(mood: next, size: _caseDiscSize.r),
      ),
      flyDisc(
        context,
        from: caseRect,
        to: previousSlot,
        arcHeight: -40,
        turns: -0.5,
        child: MoodDisc(mood: previous, size: _caseDiscSize.r),
      ),
    ]);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _airborne.clear();
      _caseMood = context.read<DiscoverCubit>().state.preferences.mood;
    });
  }

  void _onContinue() {
    context.read<DiscoverCubit>().useMoodSource();
    context.go(AppRoutes.moodDirection);
  }

  Rect? _globalRect(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.select<DiscoverCubit, Mood>((cubit) => cubit.state.preferences.mood);
    return BrandPageBody(
      children: [
        Row(children: [const PageBackButton(), const Spacer(), EyebrowText(LocaleKeys.mood_step.tr())]),
        Sp.medium.heightBox,
        DisplayHeadline(first: LocaleKeys.mood_title_first.tr(), second: LocaleKeys.mood_title_second.tr()),
        Sp.medium.heightBox,
        Text(
          LocaleKeys.mood_subtitle.tr(),
          style: m14w600(context).copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Sp.large.heightBox,
        MoodCaseStage(mood: _caseMood, discKey: _caseDiscKey, discSize: _caseDiscSize.r),
        Sp.medium.heightBox,
        MoodCaption(mood: mood),
        Sp.medium.heightBox,
        Center(
          child: CtaBar(text: LocaleKeys.mood_continue.tr(), compact: true, onTap: _onContinue),
        ),
        Sp.xlarge.heightBox,
        MoodDiscGrid(selected: mood, airborne: _airborne, slotKeys: _slotKeys, onSelected: _onMoodSelected),
      ],
    );
  }
}
