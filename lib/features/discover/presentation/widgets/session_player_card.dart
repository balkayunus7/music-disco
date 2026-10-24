part of '../pages/session_page.dart';

class SessionPlayerCard extends StatelessWidget {
  const SessionPlayerCard({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
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
                  horizontal: Sp.small.w,
                  vertical: Sp.small.h,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: 240.ms,
                        child: Align(
                          key: ValueKey(track.id),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${track.artist} — ${track.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: m12w500(context),
                          ),
                        ),
                      ),
                    ),
                    Sp.small.widthBox,
                    Text(
                      'YouTube',
                      style: m12w600(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              context.read<YoutubePlayerCubit>().buildView(
                backgroundColor: context.colors.background,
              ),
              BlocBuilder<YoutubePlayerCubit, YoutubePlayerState>(
                builder: (context, player) => _buildControls(context, player),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, YoutubePlayerState player) {
    if (player.hasError) {
      return Padding(
        padding: Sp.small.padAllR,
        child: Text(
          LocaleKeys.session_video_error.tr(),
          style: m12w500(context).copyWith(color: context.colors.textSecondary),
        ),
      );
    }

    final cubit = context.read<YoutubePlayerCubit>();
    return _PlayerControls(
      isPlaying: player.isPlaying,
      progress: player.progress,
      elapsed: player.elapsedLabel,
      total: player.durationLabel,
      onPlayPause: () {
        HapticFeedback.selectionClick();
        cubit.togglePlay();
      },
      onSeek: cubit.seekToFraction,
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
    required this.onSeek,
  });

  final bool isPlaying;
  final double progress;
  final String elapsed;
  final String total;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final timeStyle = m11w600(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Sp.small.w,
        vertical: Sp.xsmall.h,
      ),
      child: Row(
        spacing: Sp.xsmall.w,
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
                size: Sp.large.r,
              ),
            ),
          ),
          SizedBox(
            width: Sp.xxlarge.w,
            child: Text(elapsed, style: timeStyle),
          ),
          Expanded(
            child: _ProgressTrack(progress: progress, onSeek: onSeek),
          ),
          Text(total, style: timeStyle),
          ExcludeSemantics(
            child: Icon(
              Icons.volume_up_outlined,
              color: context.colors.textPrimary,
              size: Sp.medium.r,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress, required this.onSeek});

  final double progress;

  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final knob = Sp.small.r - 2;
    return Semantics(
      value: '${(progress * 100).round()}%',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final travel = constraints.maxWidth - knob;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              if (travel <= 0) return;
              final fraction = (details.localPosition.dx - knob / 2) / travel;
              onSeek(fraction.clamp(0.0, 1.0));
            },
            child: SizedBox(
              height: Sp.large.h,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 2,
                    margin: EdgeInsets.symmetric(horizontal: knob / 2),
                    color: context.colors.border,
                  ),
                  Container(
                    height: 2,
                    width: travel * progress,
                    margin: EdgeInsets.only(left: knob / 2),
                    color: context.colors.textSecondary,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
