import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/custom_app_colors.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/features/discover/presentation/sound_trace_motion.dart';

part 'sound_trace_rows.dart';

class DiscoveryLoadingView extends StatefulWidget {
  const DiscoveryLoadingView({super.key, required this.isSearching});

  final bool isSearching;

  @override
  State<DiscoveryLoadingView> createState() => _DiscoveryLoadingViewState();
}

class _DiscoveryLoadingViewState extends State<DiscoveryLoadingView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _trace = AnimationController(
    vsync: this,
    duration: SoundTraceMotion.cycle,
  );
  bool _reducedMotion = false;
  bool _tickerEnabled = true;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _tickerEnabled = TickerMode.of(context);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(DiscoveryLoadingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.isSearching &&
        !_reducedMotion &&
        _tickerEnabled &&
        _foreground) {
      if (!_trace.isAnimating) _trace.repeat(reverse: true);
    } else {
      _trace.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = loadingBodyStyle(
      context,
    ).copyWith(color: context.colors.textSecondary, height: 1.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Sp.xxlarge.heightBox,
        EyebrowText(
          LocaleKeys.discovery_loading_eyebrow.tr(),
          color: context.colors.textDisabled,
          loading: true,
        ),
        Sp.medium.heightBox,
        DisplayHeadline(
          first: LocaleKeys.discovery_loading_title_first.tr(),
          second: LocaleKeys.discovery_loading_title_second.tr(),
          role: HeadlineRole.loading,
        ),
        Sp.large.heightBox,
        Text(LocaleKeys.discovery_loading_subtitle.tr(), style: bodyStyle),
        Sp.xxlarge.heightBox,
        ExcludeSemantics(
          child: RepaintBoundary(
            child: _SoundTraceRows(
              animation: _trace,
              reducedMotion: _reducedMotion,
            ),
          ),
        ),
        Sp.xxlarge.heightBox,
        Semantics(
          liveRegion: true,
          child: Row(
            spacing: Sp.xsmall.w,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  LocaleKeys.discovery_loading_status.tr(),
                  style: loadingStatusStyle(
                    context,
                  ).copyWith(color: context.loadingStatusText),
                ),
              ),
            ],
          ),
        ),
        Sp.xlarge.heightBox,
        Text(
          LocaleKeys.discovery_loading_footnote.tr(),
          style: loadingFootnoteStyle(
            context,
          ).copyWith(color: context.colors.textDisabled),
        ),
      ],
    );
  }
}
