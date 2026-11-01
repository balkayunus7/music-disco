import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/colors.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/opacities.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/features/discover/presentation/sound_trace_motion.dart';

part 'sound_trace_rows.dart';

class DiscoveryLoadingView extends StatefulWidget {
  const DiscoveryLoadingView({super.key, required this.isSearching});
  final bool isSearching;

  @override
  State<DiscoveryLoadingView> createState() => _DiscoveryLoadingViewState();
}

class _DiscoveryLoadingViewState extends State<DiscoveryLoadingView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _trace = AnimationController(
    vsync: this,
    duration: SoundTraceMotion.cycle,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: MotionDuration.pulse,
    value: 1,
  );
  static const _statusKeys = [
    LocaleKeys.discovery_loading_status_listen,
    LocaleKeys.discovery_loading_status_search,
    LocaleKeys.discovery_loading_status,
  ];
  static const _statusInterval = Duration(milliseconds: 1500);

  Timer? _statusTimer;
  int _status = 0;
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
    _reducedMotion = context.reducedMotion;
    if (_reducedMotion) _status = _statusKeys.length - 1;
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
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
      if (_statusTimer == null && _status < _statusKeys.length - 1) {
        _statusTimer = Timer.periodic(_statusInterval, _onStatusTick);
      }
    } else {
      _statusTimer?.cancel();
      _statusTimer = null;
      _trace.stop();
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  void _onStatusTick(Timer timer) {
    if (!mounted) return;
    setState(() => _status++);
    if (_status >= _statusKeys.length - 1) {
      timer.cancel();
      _statusTimer = null;
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _trace.dispose();
    _pulse.dispose();
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
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
        AppPageHeadline(
          first: LocaleKeys.discovery_loading_title_first.tr(),
          second: LocaleKeys.discovery_loading_title_second.tr(),
          role: HeadlineRole.loading,
        ),
        Sp.s20.heightBox,
        Text(LocaleKeys.discovery_loading_subtitle.tr(), style: bodyStyle),
        Sp.s24.heightBox,
        ExcludeSemantics(
          child: RepaintBoundary(
            child: _SoundTraceRows(
              animation: _trace,
              reducedMotion: _reducedMotion,
            ),
          ),
        ),
        Sp.s24.heightBox,
        Semantics(
          liveRegion: true,
          child: Row(
            spacing: Sp.s8.w,
            children: [
              ExcludeSemantics(
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: Opacities.subtle,
                    end: Opacities.full,
                  ).animate(_pulse),
                  child: Container(
                    width: 5.r,
                    height: 5.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: context.motion(MotionDuration.base),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: MotionOffset.riseLarge,
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, ?current],
                  ),
                  child: Text(
                    _statusKeys[_status].tr(),
                    key: ValueKey(_status),
                    style: secondaryTextStyle(
                      context,
                    ).copyWith(color: context.loadingStatusText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
