import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/design_system/typography.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/disc_case.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/player/bloc/youtube_player_cubit.dart';

class TrackPlayerCard extends StatelessWidget {
  const TrackPlayerCard({super.key, required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    final captionStyle = captionLabelStyle(context).copyWith(
      color: context.colors.textDisabled,
      letterSpacing: LetterSpacing.wider,
    );
    return DiscCase(
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
        borderRadius: Sp.s4.radiusR,
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
    final cubit = context.read<YoutubePlayerCubit>();
    if (player.hasError) return _PlayerError(onRetry: cubit.retry);
    return _PlayerControls(
      isPlaying: player.isPlaying,
      isMuted: player.isMuted,
      progress: player.progress,
      elapsed: player.elapsedLabel,
      total: player.durationLabel,
      onPlayPause: cubit.togglePlay,
      onMute: cubit.toggleMute,
      onSeek: cubit.seekToFraction,
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Sp.s12.padAllR,
      child: Column(
        children: [
          Text(
            LocaleKeys.session_video_error.tr(),
            style: secondaryTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(LocaleKeys.retry.tr(), style: listTitleStyle(context)),
          ),
        ],
      ),
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.isPlaying,
    required this.isMuted,
    required this.progress,
    required this.elapsed,
    required this.total,
    required this.onPlayPause,
    required this.onMute,
    required this.onSeek,
  });
  final bool isPlaying;
  final bool isMuted;
  final double progress;
  final String elapsed;
  final String total;
  final VoidCallback onPlayPause;
  final VoidCallback onMute;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final timeStyle = secondaryTextStyle(context);
    return Padding(
      padding: Sp.s12.padHVR(Sp.s8),
      child: Row(
        spacing: Sp.s8.w,
        children: [
          Pressable(
            onTap: onPlayPause,
            semanticLabel: isPlaying
                ? LocaleKeys.session_pause.tr()
                : LocaleKeys.session_play.tr(),
            child: SizedBox.square(
              dimension: Sp.s48.r,
              child: AnimatedSwitcher(
                duration: context.motion(MotionDuration.fast),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_outlined,
                  key: ValueKey(isPlaying),
                  color: context.colors.textPrimary,
                  size: Sp.s20.r,
                ),
              ),
            ),
          ),
          SizedBox(
            width: Sp.s32.w,
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
              size: Sp.s16.r,
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

  static const double _trackHeight = 2;
  static const double _thumbRadius = 5;
  static const double _overlayRadius = 12;

  @override
  Widget build(BuildContext context) => SliderTheme(
    data: SliderTheme.of(context).copyWith(
      trackHeight: _trackHeight,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: _thumbRadius),
      overlayShape: const RoundSliderOverlayShape(
        overlayRadius: _overlayRadius,
      ),
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
