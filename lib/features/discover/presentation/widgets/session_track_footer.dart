part of '../pages/session_page.dart';

class SessionTrackFooter extends StatelessWidget {
  const SessionTrackFooter({
    super.key,
    required this.state,
    required this.track,
    required this.isBusy,
    required this.isFeedbackOpen,
    required this.saveButtonKey,
    required this.onSave,
    required this.onNext,
    required this.onToggleFeedback,
    required this.onReject,
    required this.onCustomize,
  });
  final DiscoverState state;
  final Track track;
  final bool isBusy;
  final bool isFeedbackOpen;
  final GlobalKey saveButtonKey;
  final ValueChanged<bool> onSave;
  final VoidCallback onNext;
  final VoidCallback onToggleFeedback;
  final ValueChanged<TrackFeedback> onReject;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Sp.s8.w,
          children: [
            Expanded(
              child: BlocSelector<CollectionCubit, CollectionState, bool>(
                selector: (collection) => collection.contains(track.id),
                builder: (context, isSaved) => SessionSaveButton(
                  key: saveButtonKey,
                  isSaved: isSaved,
                  onTap: isBusy ? null : () => onSave(isSaved),
                ),
              ),
            ),
            Expanded(
              child: AppCtaButton(
                size: AppCtaButtonSize.player,
                text: state.isLastTrack
                    ? LocaleKeys.session_finish.tr()
                    : LocaleKeys.session_next.tr(),
                icon: Icons.arrow_forward_rounded,
                onTap: isBusy ? null : onNext,
              ),
            ),
          ],
        ),
        Sp.s8.heightBox,
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Sp.s8.w,
          runSpacing: Sp.s4.h,
          children: [
            SessionGhostAction(
              icon: Icons.album_outlined,
              label: LocaleKeys.session_known.tr(),
              onTap: isBusy ? null : () => onReject(TrackFeedback.alreadyKnown),
            ),
            SessionGhostAction(
              icon: Icons.tune_rounded,
              label: LocaleKeys.session_not_for_me.tr(),
              isActive: isFeedbackOpen,
              onTap: isBusy ? null : onToggleFeedback,
            ),
          ],
        ),
        SessionFeedbackPanel(isOpen: isFeedbackOpen, onSelected: onReject),
        if (state.isReplacing)
          Center(
            child: SizedBox.square(
              dimension: Sp.s20.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            ),
          ),
        SessionNoticeText(notice: state.notice),
        if (state.notice == DiscoverNotice.noAlternative)
          TextLink(
            text: LocaleKeys.discovery_customize.tr(),
            onTap: onCustomize,
          ),
      ],
    );
  }
}
