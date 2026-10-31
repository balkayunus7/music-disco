part of '../pages/session_page.dart';

class SessionSaveButton extends StatelessWidget {
  const SessionSaveButton({
    super.key,
    required this.isSaved,
    required this.onTap,
  });

  final bool isSaved;

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
      haptic: TapHaptic.medium,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : 260.ms,
          curve: Curves.easeOutCubic,
          height: Sp.xxxlarge.h - Sp.tiny.h,
          padding: Sp.large.padHR,
          decoration: BoxDecoration(
            color: isSaved
                ? context.colors.buttonSecondary
                : context.colors.buttonSecondary.withValues(alpha: 0),
            borderRadius: Sp.huge.radiusR,
            border: Border.all(color: context.colors.border),
          ),
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : 220.ms,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
                child: child,
              ),
            ),
            child: Row(
              key: ValueKey(isSaved),
              mainAxisSize: MainAxisSize.min,
              spacing: Sp.xsmall.w,
              children: [
                Icon(
                  isSaved ? Icons.check_rounded : Icons.add_rounded,
                  color: context.colors.textPrimary,
                  size: Sp.large.r,
                ),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: smallButtonTextStyle(context),
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

  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? context.colors.textPrimary
        : context.colors.textSecondary;
    return Pressable(
      onTap: onTap,
      selected: isActive,
      semanticLabel: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : 240.ms,
          height: Sp.xxlarge.h + Sp.tiny.h,
          padding: Sp.small.padHR,
          decoration: BoxDecoration(
            borderRadius: Sp.huge.radiusR,
            border: Border.all(
              color: isActive
                  ? context.colors.border
                  : context.colors.border.withValues(alpha: 0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Sp.tiny.w + 2,
            children: [
              Icon(icon, color: color, size: Sp.small.r + 2),
              Text(
                label,
                maxLines: 1,
                style: labelTextStyle(context).copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return MotionSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : 300.ms,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !isOpen
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: Sp.small.padTopR,
              child: Column(
                children: [
                  Text(
                    LocaleKeys.session_what_to_change.tr(),
                    style: secondaryTextStyle(
                      context,
                    ).copyWith(color: context.colors.textSecondary),
                  ),
                  Sp.xsmall.heightBox,
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: Sp.xsmall.w,
                    runSpacing: Sp.xsmall.h,
                    children: [
                      for (final (index, feedback) in _options.indexed)
                        _FeedbackChip(
                          label: feedback.labelKey.tr(),
                          delayIndex: index,
                          onTap: () => onSelected(feedback),
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

  final int delayIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : (240 + delayIndex * 70).ms,
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
          height: Sp.xxlarge.h + Sp.tiny.h,
          alignment: Alignment.center,
          padding: Sp.medium.padHR,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: Sp.huge.radiusR,
          ),
          child: ExcludeSemantics(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelTextStyle(context),
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
      DiscoverNotice.noAlternative => LocaleKeys.session_no_alternative.tr(),
      DiscoverNotice.requestFailed => LocaleKeys.session_request_failed.tr(),
    };
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : 260.ms,
      child: text == null
          ? const SizedBox.shrink()
          : Semantics(
              key: ValueKey(notice),
              liveRegion: true,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: secondaryTextStyle(
                  context,
                ).copyWith(color: context.colors.textDisabled),
              ),
            ),
    );
  }
}
