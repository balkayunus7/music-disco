part of '../pages/session_page.dart';

class SessionSaveButton extends StatelessWidget {
  const SessionSaveButton({
    super.key,
    required this.isSaved,
    required this.onTap,
  });

  final bool isSaved;

  /// Null disables the button.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = isSaved
        ? LocaleKeys.session_saved.tr()
        : LocaleKeys.session_save.tr();
    return Pressable(
      onTap: onTap,
      selected: isSaved,
      semanticLabel: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: 260.ms,
          curve: Curves.easeOutCubic,
          height: Sp.huge.h + Sp.xsmall.h,
          decoration: BoxDecoration(
            color: isSaved
                ? context.colors.surfaceSecondary
                : context.colors.surface,
            borderRadius: Sp.huge.radiusR,
            border: Border.all(
              color: isSaved
                  ? context.colors.border
                  : context.colors.textDisabled.withValues(alpha: 0.5),
            ),
          ),
          child: AnimatedSwitcher(
            duration: 220.ms,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
                child: child,
              ),
            ),
            child: Row(
              key: ValueKey(isSaved),
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Sp.small.w,
              children: [
                Icon(
                  isSaved ? Icons.check_rounded : Icons.add_rounded,
                  color: context.colors.textPrimary,
                  size: Sp.xlarge.r,
                ),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: m18w700(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SessionNextButton extends StatelessWidget {
  const SessionNextButton({
    super.key,
    required this.isLast,
    required this.onTap,
  });

  /// On the last track the button finishes the round.
  final bool isLast;

  /// Null disables the button.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = isLast
        ? LocaleKeys.session_finish.tr()
        : LocaleKeys.session_next.tr();
    final foreground = context.colors.textOnPrimary;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: 200.ms,
          height: Sp.huge.h + Sp.xsmall.h,
          decoration: BoxDecoration(
            color: onTap == null
                ? context.colors.buttonDisabled
                : context.colors.buttonPrimary,
            borderRadius: Sp.huge.radiusR,
          ),
          child: AnimatedSwitcher(
            duration: 240.ms,
            child: Row(
              key: ValueKey(isLast),
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Sp.small.w,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: m18w700(context).copyWith(color: foreground),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: foreground,
                  size: Sp.xlarge.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Low-emphasis action under the main buttons; outlined while [isActive].
class SessionGhostAction extends StatelessWidget {
  const SessionGhostAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;

  /// Null disables the action.
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      selected: isActive,
      semanticLabel: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: 240.ms,
          height: Sp.huge.h,
          decoration: BoxDecoration(
            borderRadius: Sp.huge.radiusR,
            border: Border.all(
              color: isActive
                  ? context.colors.textPrimary
                  : context.colors.textPrimary.withValues(alpha: 0),
              width: 1.6,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: Sp.small.w,
            children: [
              Icon(
                icon,
                color: context.colors.textSecondary,
                size: Sp.xlarge.r,
              ),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: m16w600(
                    context,
                  ).copyWith(color: context.colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Neyi değiştirelim?" chips revealed by "bana uymadı".
class SessionFeedbackPanel extends StatelessWidget {
  const SessionFeedbackPanel({
    super.key,
    required this.isOpen,
    required this.onSelected,
  });

  final bool isOpen;
  final ValueChanged<TrackFeedback> onSelected;

  static const List<TrackFeedback> _options = [
    TrackFeedback.tooCalm,
    TrackFeedback.tooLively,
    TrackFeedback.notMyStyle,
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: 300.ms,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !isOpen
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: Sp.medium.padTopR,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.session_what_to_change.tr(),
                    style: m16w600(context).copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Sp.small.heightBox,
                  Row(
                    spacing: Sp.xsmall.w,
                    children: [
                      for (final (index, feedback) in _options.indexed)
                        Expanded(
                          child: _FeedbackChip(
                            label: feedback.labelKey.tr(),
                            delayIndex: index,
                            onTap: () => onSelected(feedback),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  const _FeedbackChip({
    required this.label,
    required this.delayIndex,
    required this.onTap,
  });

  final String label;

  /// Position in the row; later chips arrive slightly later.
  final int delayIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: (240 + delayIndex * 70).ms,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * Sp.small.h),
          child: child,
        ),
      ),
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: Container(
          height: Sp.huge.h,
          alignment: Alignment.center,
          padding: Sp.xsmall.padHR,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: Sp.huge.radiusR,
          ),
          child: ExcludeSemantics(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: m15w500(context),
            ),
          ),
        ),
      ),
    );
  }
}

class SessionNoticeText extends StatelessWidget {
  const SessionNoticeText({super.key, required this.notice});

  final DiscoverNotice notice;

  @override
  Widget build(BuildContext context) {
    final text = switch (notice) {
      DiscoverNotice.none => null,
      DiscoverNotice.feedbackTaken => LocaleKeys.session_feedback_taken.tr(),
      DiscoverNotice.knownSkipped => LocaleKeys.session_known_skipped.tr(),
    };
    return AnimatedSwitcher(
      duration: 260.ms,
      child: text == null
          ? const SizedBox.shrink()
          : Semantics(
              key: ValueKey(notice),
              liveRegion: true,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: m14w500(
                  context,
                ).copyWith(color: context.colors.textDisabled),
              ),
            ),
    );
  }
}
