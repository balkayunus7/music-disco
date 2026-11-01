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
          duration: context.motion(MotionDuration.base),
          height: Sp.s48.h - Sp.s4.h,
          padding: Sp.s20.padHR,
          decoration: BoxDecoration(
            color: isSaved
                ? context.colors.buttonSecondary
                : context.colors.buttonSecondary.withValues(alpha: 0),
            borderRadius: Sp.s64.radiusR,
            border: Border.all(color: context.colors.border),
          ),
          child: AnimatedSwitcher(
            duration: context.motion(MotionDuration.base),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: MotionScale.enter,
                  end: 1,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Row(
              key: ValueKey(isSaved),
              mainAxisSize: MainAxisSize.min,
              spacing: Sp.s8.w,
              children: [
                Icon(
                  isSaved ? Icons.check_rounded : Icons.add_rounded,
                  color: context.colors.textPrimary,
                  size: Sp.s20.r,
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
          duration: context.motion(MotionDuration.base),
          height: Sp.s36.h,
          padding: Sp.s12.padHR,
          decoration: BoxDecoration(
            borderRadius: Sp.s64.radiusR,
            border: Border.all(
              color: isActive
                  ? context.colors.border
                  : context.colors.border.withValues(alpha: 0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Sp.s4.w + 2,
            children: [
              Icon(icon, color: color, size: Sp.s12.r + 2),
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
    return AdaptiveAnimatedSize(
      alignment: Alignment.topCenter,
      child: !isOpen
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: Sp.s12.padTopR,
              child: Column(
                children: [
                  Text(
                    LocaleKeys.session_what_to_change.tr(),
                    style: secondaryTextStyle(
                      context,
                    ).copyWith(color: context.colors.textSecondary),
                  ),
                  Sp.s8.heightBox,
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: Sp.s8.w,
                    runSpacing: Sp.s8.h,
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
      duration: context.motion(
        MotionDuration.base + MotionDuration.tick * delayIndex,
      ),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * Sp.s12.h),
          child: child,
        ),
      ),
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: Container(
          height: Sp.s36.h,
          alignment: Alignment.center,
          padding: Sp.s16.padHR,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: Sp.s64.radiusR,
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
      duration: context.motion(MotionDuration.base),
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
