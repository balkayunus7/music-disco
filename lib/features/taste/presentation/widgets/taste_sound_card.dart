part of '../pages/taste_genres_page.dart';

class TasteSoundCard extends StatelessWidget {
  const TasteSoundCard({super.key, required this.profile});
  final TasteProfile profile;

  static const double _turnPerGenre = 0.25;

  @override
  Widget build(BuildContext context) {
    final discSize = Sp.s96.r + Sp.s12.r;
    final turns = profile.isMixed ? 1.0 : profile.genres.length * _turnPerGenre;
    return Semantics(
      liveRegion: true,
      label: profile.selectionLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: Sp.s12.padAllR,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: Sp.s20.radiusR,
            border: Border.all(color: context.colors.borderSecondary),
          ),
          child: Row(
            spacing: Sp.s20.w,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: turns),
                duration: context.motion(MotionDuration.emphasized),
                curve: MotionCurve.overshoot,
                builder: (context, value, _) => DiscCover(
                  palette: Mood.noRules.palette,
                  size: discSize,
                  title: LocaleKeys.taste_disc_title.tr(),
                  turns: value,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Sp.s4.h,
                  children: [
                    _SelectionLabel(label: profile.selectionLabel),
                    CaptionLabel(LocaleKeys.taste_disc_caption.tr()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionLabel extends StatelessWidget {
  const _SelectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
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
        label,
        key: ValueKey(label),
        style: captionLabelStyle(context),
      ),
    );
  }
}
