part of '../pages/session_page.dart';

/// Player framed as a jewel case. Audio is not connected yet; play advances a
/// local progress animation so the controls can be reviewed.
class SessionPlayerCard extends StatefulWidget {
  const SessionPlayerCard({super.key, required this.track});

  final Track track;

  @override
  State<SessionPlayerCard> createState() => _SessionPlayerCardState();
}

class _SessionPlayerCardState extends State<SessionPlayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _playback = AnimationController(
    vsync: this,
    duration: widget.track.duration,
  );

  @override
  void dispose() {
    _playback.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_playback.isAnimating) {
        _playback.stop();
      } else {
        if (_playback.isCompleted) _playback.reset();
        _playback.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.track;
    final captionStyle = m10w700(
      context,
    ).copyWith(color: context.colors.textDisabled, letterSpacing: 1.4);
    return JewelCase(
      contentPadding: Sp.xsmall.padAllR,
      footer: Row(
        children: [
          Expanded(
            child: Text(
              LocaleKeys.session_collection_caption.tr(),
              style: captionStyle,
            ),
          ),
          Text(LocaleKeys.session_side_caption.tr(), style: captionStyle),
        ],
      ),
      child: ClipRRect(
        borderRadius: Sp.tiny.radiusR,
        child: ColoredBox(
          color: context.colors.background,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Sp.medium.w,
                  vertical: Sp.medium.h,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${track.artist} — ${track.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: m15w500(context),
                      ),
                    ),
                    Sp.small.widthBox,
                    Text(
                      'YouTube',
                      style: m15w500(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              _PlayerPreview(mood: track.mood),
              AnimatedBuilder(
                animation: _playback,
                builder: (context, _) => _PlayerControls(
                  isPlaying: _playback.isAnimating,
                  progress: _playback.value,
                  elapsed: formatPlaybackTime(track.duration * _playback.value),
                  total: formatPlaybackTime(track.duration),
                  onPlayPause: _togglePlayback,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerPreview extends StatelessWidget {
  const _PlayerPreview({required this.mood});

  final Mood mood;

  @override
  Widget build(BuildContext context) {
    final palette = mood.palette;
    final shade = Color.lerp(palette.deep, context.colors.background, 0.55)!;
    final light = Color.lerp(palette.light, shade, 0.55)!;
    return AspectRatio(
      aspectRatio: 16 / 7.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [shade, shade, light, shade, light, shade, shade],
            stops: const [0, 0.3, 0.42, 0.52, 0.6, 0.7, 1],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album_outlined,
              color: context.colors.textPrimary.withValues(alpha: 0.8),
              size: Sp.xxlarge.r,
            ),
            Sp.medium.heightBox,
            Text(
              LocaleKeys.session_ready_to_listen.tr(),
              style: m15w500(context).copyWith(
                color: context.colors.textPrimary.withValues(alpha: 0.85),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.isPlaying,
    required this.progress,
    required this.elapsed,
    required this.total,
    required this.onPlayPause,
  });

  final bool isPlaying;
  final double progress;
  final String elapsed;
  final String total;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final timeStyle = m14w500(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Sp.medium.w,
        vertical: Sp.medium.h,
      ),
      child: Row(
        spacing: Sp.small.w,
        children: [
          Pressable(
            onTap: onPlayPause,
            semanticLabel: isPlaying
                ? LocaleKeys.session_pause.tr()
                : LocaleKeys.session_play.tr(),
            child: AnimatedSwitcher(
              duration: 160.ms,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_outlined,
                key: ValueKey(isPlaying),
                color: context.colors.textPrimary,
                size: Sp.xxlarge.r,
              ),
            ),
          ),
          SizedBox(
            width: Sp.xxlarge.w + Sp.small.w,
            child: Text(elapsed, style: timeStyle),
          ),
          Expanded(child: _ProgressTrack(progress: progress)),
          Text(total, style: timeStyle),
          ExcludeSemantics(
            child: Icon(
              Icons.volume_up_outlined,
              color: context.colors.textPrimary,
              size: Sp.xlarge.r,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final knob = Sp.large.r;
    return Semantics(
      value: '${(progress * 100).round()}%',
      child: SizedBox(
        height: knob,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final travel = constraints.maxWidth - knob;
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: Sp.small.h,
                  margin: EdgeInsets.symmetric(horizontal: knob / 2),
                  decoration: BoxDecoration(
                    borderRadius: Sp.small.radiusR,
                    border: Border.all(color: context.colors.textDisabled),
                  ),
                ),
                Positioned(
                  left: travel * progress,
                  child: Container(
                    width: knob,
                    height: knob,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
