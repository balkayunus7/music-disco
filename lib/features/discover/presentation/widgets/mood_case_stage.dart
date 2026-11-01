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

  @override
  Widget build(BuildContext context) => Center(
    child: Transform.rotate(
      angle: -0.07,
      child: SizedBox.square(
        dimension: discSize + Sp.s20.r,
        child: DiscCase(
          hasSpine: false,
          child: SizedBox.square(
            key: discKey,
            dimension: discSize,
            child: _CaseDisc(mood: mood, size: discSize),
          ),
        ),
      ),
    ),
  );
}

class _CaseDisc extends StatelessWidget {
  const _CaseDisc({required this.mood, required this.size});
  final Mood? mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mood = this.mood;
    if (mood == null) return DiscPlaceholder(size: size);
    return TweenAnimationBuilder<double>(
      key: ValueKey(mood),
      tween: Tween(begin: Opacities.faint, end: 0),
      duration: context.motion(MotionDuration.emphasized),
      curve: MotionCurve.enter,
      builder: (context, turns, _) =>
          MoodDisc(mood: mood, size: size, turns: turns),
    );
  }
}

class MoodCaption extends StatelessWidget {
  const MoodCaption({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: context.motion(MotionDuration.base),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: MotionOffset.riseMedium,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Semantics(
        key: ValueKey(text),
        liveRegion: true,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
      ),
    );
  }
}
