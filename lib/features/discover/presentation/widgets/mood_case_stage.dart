part of '../pages/mood_page.dart';

class MoodCaseStage extends StatelessWidget {
  const MoodCaseStage({
    super.key,
    required this.mood,
    required this.discKey,
    required this.discSize,
  });

  final Mood? mood;
  final GlobalKey discKey;
  final double discSize;

  static const double _caseTilt = -0.07;
  static const double _stickerTilt = 0.1;

  @override
  Widget build(BuildContext context) {
    final caseSize = discSize + Sp.xxlarge.r + Sp.small.r;
    return Center(
      child: SizedBox(
        width: caseSize + Sp.xxlarge.r,
        height: caseSize + Sp.medium.r,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _caseTilt,
              child: SizedBox.square(
                dimension: caseSize,
                child: JewelCase(
                  contentPadding: EdgeInsets.zero,
                  footer: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      LocaleKeys.mood_case_caption.tr(),
                      style: m10w700(context).copyWith(
                        color: context.colors.textDisabled,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  child: SizedBox.square(
                    key: discKey,
                    dimension: discSize,
                    child: _CaseDisc(mood: mood, size: discSize),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: Sp.large.r,
              child: Transform.rotate(
                angle: _stickerTilt,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sp.medium.w,
                    vertical: Sp.small.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSecondary,
                    borderRadius: Sp.xsmall.radiusR,
                  ),
                  child: Text(
                    LocaleKeys.mood_side_a.tr(),
                    style: m13w600(
                      context,
                    ).copyWith(letterSpacing: 2.4, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseDisc extends StatelessWidget {
  const _CaseDisc({required this.mood, required this.size});

  final Mood? mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mood = this.mood;
    if (mood == null) return EmptyDiscSlot(size: size);
    return TweenAnimationBuilder<double>(
      key: ValueKey(mood),
      tween: Tween(begin: 0.12, end: 0),
      duration: 700.ms,
      curve: Curves.easeOutCubic,
      builder: (context, turns, _) =>
          MoodDisc(mood: mood, size: size, turns: turns),
    );
  }
}

class MoodCaption extends StatelessWidget {
  const MoodCaption({super.key, required this.mood});

  final Mood mood;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 280.ms,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(mood),
        children: [
          Text(
            mood.labelKey.tr(),
            textAlign: TextAlign.center,
            style: m18w700(context),
          ),
          Sp.xsmall.heightBox,
          Text(
            mood.taglineKey.tr(),
            textAlign: TextAlign.center,
            style: m13w500(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
