part of '../pages/session_page.dart';

class SessionTrackContent extends StatelessWidget {
  const SessionTrackContent({
    super.key,
    required this.state,
    required this.track,
    required this.isBusy,
    required this.onSelected,
    required this.onPrevious,
  });
  final DiscoverState state;
  final Track track;
  final bool isBusy;
  final ValueChanged<int> onSelected;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.isShortRound) ...[
          Text(
            LocaleKeys.session_short_round.tr(args: ['${state.tracks.length}']),
            style: secondaryTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
          Sp.s12.heightBox,
        ],
        SessionPlayerCard(track: track),
        Sp.s20.heightBox,
        AnimatedOpacity(
          opacity: isBusy ? Opacities.half : Opacities.full,
          duration: context.motion(MotionDuration.base),
          child: AnimatedSwitcher(
            duration: context.motion(MotionDuration.slow),
            switchInCurve: MotionCurve.enter,
            switchOutCurve: MotionCurve.exit,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: MotionOffset.contentEnter,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(track.id),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [SessionTrackInfo(track: track)],
            ),
          ),
        ),
        Sp.s16.heightBox,
        SessionDiscStrip(
          tracks: state.tracks,
          currentIndex: state.currentIndex,
          onSelected: isBusy ? null : onSelected,
          onPrevious: state.hasPrevious && !isBusy ? onPrevious : null,
        ),
      ],
    );
  }
}
