part of '../pages/session_page.dart';

/// The round's discs; the current one is ringed and the rest are dimmed.
class SessionDiscStrip extends StatelessWidget {
  const SessionDiscStrip({
    super.key,
    required this.tracks,
    required this.currentIndex,
    required this.onSelected,
    required this.onPrevious,
  });

  final List<Track> tracks;
  final int currentIndex;

  /// Null disables selection.
  final ValueChanged<int>? onSelected;

  /// Null when there is no previous track.
  final VoidCallback? onPrevious;

  @override
  Widget build(BuildContext context) {
    final onSelected = this.onSelected;
    return Row(
      children: [
        Pressable(
          onTap: onPrevious,
          semanticLabel: LocaleKeys.session_previous_track.tr(),
          child: Padding(
            padding: Sp.xsmall.padAllR,
            child: AnimatedOpacity(
              opacity: onPrevious == null ? 0.3 : 1,
              duration: 200.ms,
              child: Icon(
                Icons.chevron_left_rounded,
                color: context.colors.textSecondary,
                size: Sp.xxlarge.r,
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (index, track) in tracks.indexed)
                _StripDisc(
                  mood: track.mood,
                  isCurrent: index == currentIndex,
                  semanticLabel: LocaleKeys.session_track_position.tr(
                    args: ['${index + 1}', '${tracks.length}'],
                  ),
                  onTap: onSelected == null ? null : () => onSelected(index),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StripDisc extends StatelessWidget {
  const _StripDisc({
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
        duration: 260.ms,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: 260.ms,
          padding: Sp.tiny.padAllR,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? context.colors.textPrimary.withValues(alpha: 0.8)
                  : context.colors.textPrimary.withValues(alpha: 0),
              width: 1.6,
            ),
          ),
          child: MoodDisc(
            mood: mood,
            size: Sp.xxxlarge.r,
            isDimmed: !isCurrent,
            hasShadow: isCurrent,
          ),
        ),
      ),
    );
  }
}
