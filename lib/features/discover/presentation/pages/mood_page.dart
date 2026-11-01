import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/opacities.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/disc_case.dart';
import 'package:music_disco/core/widgets/disc_placeholder.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/widgets/toss_disc.dart';
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

class _MoodPageState extends State<MoodPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  final GlobalKey _caseDiscKey = GlobalKey();
  final Map<Mood, GlobalKey> _slotKeys = {
    for (final mood in Mood.values) mood: GlobalKey(),
  };

  final Set<Mood> _airborne = {};
  late Mood? _caseMood = context.read<DiscoverCubit>().state.preferences.mood;

  static const double _caseDiscSize = Sp.s80;

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
      tossDisc(
        context,
        from: nextSlot,
        to: caseRect,
        arcHeight: 60,
        turns: 0.75,
        child: MoodDisc(mood: next, size: _caseDiscSize.r),
      ),
      tossDisc(
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
    final mood = context.select<DiscoverCubit, Mood>(
      (cubit) => cubit.state.preferences.mood,
    );
    return AppPageScaffold(
      pageBar: AppPageBar(
        title: LocaleKeys.mood_step.tr(),
        showBackButton: true,
      ),
      footer: AppCtaButton(
        text: LocaleKeys.discovery_customize.tr(),
        icon: Icons.arrow_forward_rounded,
        onTap: _airborne.isEmpty ? _onContinue : null,
      ),
      children: [
        AppPageHeadline(
          first: LocaleKeys.mood_title_first.tr(),
          second: LocaleKeys.mood_title_second.tr(),
        ),
        Sp.s16.heightBox,
        Text(
          LocaleKeys.mood_subtitle.tr(),
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        Sp.s4.heightBox,
        Text(
          LocaleKeys.mood_flow_hint.tr(),
          style: secondaryTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        Sp.s20.heightBox,
        MoodCaseStage(
          mood: _caseMood,
          discKey: _caseDiscKey,
          discSize: _caseDiscSize.r,
        ),
        Sp.s16.heightBox,
        MoodCaption(text: mood.taglineKey.tr()),
        Sp.s20.heightBox,
        MoodDiscGrid(
          selected: mood,
          airborne: _airborne,
          slotKeys: _slotKeys,
          onSelected: _onMoodSelected,
        ),
      ],
    );
  }
}
