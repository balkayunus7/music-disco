part of '../pages/session_page.dart';

class SessionFailureView extends StatelessWidget {
  const SessionFailureView({
    super.key,
    required this.onRetry,
    required this.onChangePreferences,
  });
  final VoidCallback onChangePreferences;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Sp.xlarge.heightBox,
        Text(
          LocaleKeys.session_error.tr(),
          textAlign: TextAlign.center,
          style: labelTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
        Sp.xlarge.heightBox,
        CtaBar(
          text: LocaleKeys.retry.tr(),
          icon: Icons.refresh_rounded,
          onTap: onRetry,
        ),
        TextLink(text: LocaleKeys.taste_edit.tr(), onTap: onChangePreferences),
      ],
    );
  }
}
