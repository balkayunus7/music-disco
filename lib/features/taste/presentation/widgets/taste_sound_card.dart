part of '../pages/taste_genres_page.dart';

class TasteSoundCard extends StatelessWidget {
  const TasteSoundCard({super.key, required this.profile});

  final TasteProfile profile;

  static const double _turnPerGenre = 0.25;

  @override
  Widget build(BuildContext context) {
    final discSize = Sp.xhuge.r + Sp.small.r;
    final turns = profile.isMixed ? 1.0 : profile.genres.length * _turnPerGenre;
    return Semantics(
      liveRegion: true,
      label: profile.selectionLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: Sp.small.padAllR,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: Sp.large.radiusR,
            border: Border.all(color: context.colors.borderSecondary),
          ),
          child: Row(
            spacing: Sp.large.w,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: turns),
                duration: 640.ms,
                curve: Curves.easeOutBack,
                builder: (context, value, _) => HoloDisc(
                  palette: Mood.noRules.palette,
                  size: discSize,
                  title: LocaleKeys.taste_disc_title.tr(),
                  turns: value,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Sp.tiny.h,
                  children: [
                    AnimatedSwitcher(
                      duration: 220.ms,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.4),
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
                        profile.selectionLabel,
                        key: ValueKey(profile.selectionLabel),
                        style: m13w600(context).copyWith(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    EyebrowText(LocaleKeys.taste_disc_caption.tr()),
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
