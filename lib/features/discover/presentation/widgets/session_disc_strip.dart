part of '../pages/session_page.dart';

class SessionDiscStrip extends StatefulWidget {
  const SessionDiscStrip({
    super.key,
    required this.tracks,
    required this.currentIndex,
    required this.onSelected,
    required this.onPrevious,
  });
  final List<Track> tracks;
  final int currentIndex;
  final ValueChanged<int>? onSelected;
  final VoidCallback? onPrevious;

  @override
  State<SessionDiscStrip> createState() => _SessionDiscStripState();
}

class _SessionDiscStripState extends State<SessionDiscStrip> {
  final List<GlobalKey> _discKeys = [];

  @override
  void didUpdateWidget(SessionDiscStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.currentIndex >= _discKeys.length) return;
      final discContext = _discKeys[widget.currentIndex].currentContext;
      if (discContext == null) return;
      Scrollable.ensureVisible(
        discContext,
        alignment: 0.5,
        duration: context.motion(MotionDuration.base),
        curve: MotionCurve.enter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSelected = widget.onSelected;
    final tracks = widget.tracks;
    while (_discKeys.length < tracks.length) {
      _discKeys.add(GlobalKey());
    }
    return Row(
      children: [
        Pressable(
          onTap: widget.onPrevious,
          semanticLabel: LocaleKeys.session_previous_track.tr(),
          child: Padding(
            padding: Sp.s8.padAllR,
            child: AnimatedOpacity(
              opacity: widget.onPrevious == null
                  ? Opacities.soft
                  : Opacities.full,
              duration: context.motion(MotionDuration.base),
              child: Icon(
                Icons.chevron_left_rounded,
                color: context.colors.textSecondary,
                size: Sp.s20.r,
              ),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: Sp.s4.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: Sp.s20.w,
                  children: [
                    for (final (index, track) in tracks.indexed)
                      _StripDisc(
                        key: _discKeys[index],
                        mood: track.mood,
                        isCurrent: index == widget.currentIndex,
                        semanticLabel: LocaleKeys.session_track_position.tr(
                          args: ['${index + 1}', '${tracks.length}'],
                        ),
                        onTap: onSelected == null
                            ? null
                            : () => onSelected(index),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: Sp.s20.r + Sp.s8.r * 2),
      ],
    );
  }
}

class _StripDisc extends StatelessWidget {
  const _StripDisc({
    super.key,
    required this.mood,
    required this.isCurrent,
    required this.semanticLabel,
    required this.onTap,
  });
  final Mood mood;
  final bool isCurrent;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      selected: isCurrent,
      semanticLabel: semanticLabel,
      child: AnimatedScale(
        scale: isCurrent ? 1.08 : 0.92,
        duration: context.motion(MotionDuration.base),
        curve: MotionCurve.overshoot,
        child: AnimatedContainer(
          duration: context.motion(MotionDuration.base),
          padding: 3.padAllR,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? context.colors.textPrimary.withValues(
                      alpha: Opacities.strong,
                    )
                  : context.colors.textPrimary.withValues(alpha: 0),
              width: Stroke.regular,
            ),
          ),
          child: MoodDisc(
            mood: mood,
            size: Sp.s32.r + Sp.s8.r,
            isDimmed: !isCurrent,
            hasShadow: isCurrent,
          ),
        ),
      ),
    );
  }
}
