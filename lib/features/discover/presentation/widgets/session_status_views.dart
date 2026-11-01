part of '../pages/session_page.dart';

class SessionFailureView extends StatelessWidget {
  const SessionFailureView({
    super.key,
    required this.failure,
    required this.onRetry,
    required this.onChangePreferences,
  });
  final DiscoverFailure failure;
  final VoidCallback onRetry;
  final VoidCallback onChangePreferences;

  @override
  Widget build(BuildContext context) {
    final isUnavailable = failure == DiscoverFailure.unavailable;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: BrokenDisc(size: 176.r)),
        Sp.s24.heightBox,
        Text(
          (isUnavailable
                  ? LocaleKeys.session_error_unavailable_title
                  : LocaleKeys.session_error_empty_title)
              .tr(),
          textAlign: TextAlign.center,
          style: sheetTitleStyle(
            context,
          ).copyWith(color: context.colors.textPrimary),
        ),
        Sp.s12.heightBox,
        Text(
          (isUnavailable
                  ? LocaleKeys.session_error_unavailable
                  : LocaleKeys.session_error)
              .tr(),
          textAlign: TextAlign.center,
          style: labelTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        Sp.s24.heightBox,
        AppCtaButton(
          text: LocaleKeys.retry.tr(),
          icon: Icons.refresh_rounded,
          onTap: onRetry,
        ),
        if (!isUnavailable)
          TextLink(
            text: LocaleKeys.taste_edit.tr(),
            onTap: onChangePreferences,
          ),
      ],
    );
  }
}
