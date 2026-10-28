import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/jewel_case.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/player/bloc/youtube_player_cubit.dart';

class TrackPlayerCard extends StatelessWidget {
  const TrackPlayerCard({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final captionStyle = eyebrowTextStyle(
      context,
    ).copyWith(color: context.colors.textDisabled, letterSpacing: 1.4);
    return JewelCase(
      contentPadding: Sp.tiny.padAllR,
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
        child: Column(
          children: [
            Text(
              LocaleKeys.session_video_error.tr(),
              style: secondaryTextStyle(
                context,
              ).copyWith(color: context.colors.textSecondary),
            ),
            TextButton(
              onPressed: context.read<YoutubePlayerCubit>().retry,
              child: Text(
                LocaleKeys.retry.tr(),
                style: listTitleStyle(context),
              ),
            ),
          ],
        ),
      );
    }

    final cubit = context.read<YoutubePlayerCubit>();
    return _PlayerControls(
      isPlaying: player.isPlaying,
      progress: player.progress,
      elapsed: player.elapsedLabel,
      total: player.durationLabel,
      onPlayPause: cubit.togglePlay,
      onSeek: cubit.seekToFraction,
      isMuted: player.isMuted,
      onMute: cubit.toggleMute,
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
    required this.isMuted,
    required this.onMute,
  });

  final bool isPlaying;
  final double progress;
  final String elapsed;
  final String total;
  final bool isMuted;
  final VoidCallback onMute;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final timeStyle = secondaryTextStyle(context);
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
            child: SizedBox.square(
              dimension: Sp.xxxlarge.r,
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : 160.ms,
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
          ),
          SizedBox(
            width: Sp.xxlarge.w,
            child: Text(elapsed, style: timeStyle),
          ),
          Expanded(
            child: _ProgressTrack(progress: progress, onSeek: onSeek),
          ),
          Text(total, style: timeStyle),
          IconButton(
            tooltip: isMuted
                ? LocaleKeys.session_unmute.tr()
                : LocaleKeys.session_mute.tr(),
            onPressed: onMute,
            icon: Icon(
              isMuted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
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
  Widget build(BuildContext context) => SliderTheme(
    data: SliderTheme.of(context).copyWith(
      trackHeight: 2,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
    ),
    child: Slider(
      value: progress,
      onChanged: onSeek,
      label: LocaleKeys.session_seek.tr(),
      activeColor: context.colors.textSecondary,
      inactiveColor: context.colors.border,
    ),
  );
}
