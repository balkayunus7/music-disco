part of '../pages/discover_home_page.dart';

class StudioDiscDuo extends StatefulWidget {
  const StudioDiscDuo({super.key});

  @override
  State<StudioDiscDuo> createState() => _StudioDiscDuoState();
}

class _StudioDiscDuoState extends State<StudioDiscDuo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 48),
  );
  static const double _backTilt = -0.08;
  static const double _frontTilt = 0.06;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _spin.stop();
    } else if (!_spin.isAnimating) {
      _spin.repeat();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frontSize = 116.r;
    final backSize = 102.r;
    final volumeStyle = eyebrowTextStyle(
      context,
    ).copyWith(color: context.colors.textDisabled, letterSpacing: 1.5);
    return ExcludeSemantics(
      child: SizedBox(
        height: frontSize + Sp.xsmall.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              top: Sp.xsmall.h,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(LocaleKeys.studio_volume.tr(), style: volumeStyle),
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.5),
              child: SizedBox(
                width: 176.r,
                height: frontSize,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: AnimatedBuilder(
                        animation: _spin,
                        builder: (context, _) => MoodDisc(
                          mood: Mood.afterHours,
                          size: backSize,
                          turns: _backTilt + _spin.value,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: AnimatedBuilder(
                        animation: _spin,
                        builder: (context, _) => MoodDisc(
                          mood: Mood.noRules,
                          size: frontSize,
                          turns: _frontTilt + _spin.value * 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
