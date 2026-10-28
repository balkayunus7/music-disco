part of '../pages/session_page.dart';

class SessionCompletedView extends StatelessWidget {
  const SessionCompletedView({
    super.key,
    required this.total,
    required this.saved,
    required this.onNewRound,
    required this.onCollection,
  });
  final int total;
  final int saved;
  final VoidCallback onNewRound;
  final VoidCallback onCollection;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Sp.xlarge.heightBox,
      Icon(
        Icons.check_circle_outline_rounded,
        size: Sp.huge.r,
        color: context.colors.success,
      ),
      Sp.large.heightBox,
      DisplayHeadline(
        first: LocaleKeys.session_completed.tr(),
        role: HeadlineRole.loadingResults,
      ),
      Sp.medium.heightBox,
      Text(
        LocaleKeys.session_summary.tr(args: ['$total', '$saved']),
        textAlign: TextAlign.center,
        style: bodyTextStyle(
          context,
        ).copyWith(color: context.colors.textSecondary),
      ),
      Sp.xxlarge.heightBox,
      CtaBar(text: LocaleKeys.session_new_round.tr(), onTap: onNewRound),
      if (saved > 0) ...[
        Sp.medium.heightBox,
        CtaBar(
          text: LocaleKeys.session_listen_saved.tr(),
          icon: Icons.play_arrow_rounded,
          onTap: onCollection,
        ),
      ],
      Sp.medium.heightBox,
      TextLink(
        text: LocaleKeys.collection_back_to_discover.tr(),
        onTap: () => context.go(AppRoutes.discover),
      ),
    ],
  );
}
