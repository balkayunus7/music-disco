part of '../pages/splash_page.dart';

class SplashView extends StatelessWidget {
  const SplashView({required this.hasFailed, required this.onRetry, super.key});
  final bool hasFailed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final title = hasFailed ? LocaleKeys.error_title : LocaleKeys.app_name;
    final message = hasFailed ? LocaleKeys.error_message : LocaleKeys.starting;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Sp.xlarge.padAllR,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.graphic_eq_rounded,
                  size: Sp.huge.r,
                  color: context.colors.primary,
                ),
                Sp.xlarge.heightBox,
                Text(
                  title.tr(),
                  style: hasFailed
                      ? sheetTitleStyle(context)
                      : logoTextStyle(context),
                  textAlign: TextAlign.center,
                ),
                Sp.small.heightBox,
                Text(
                  message.tr(),
                  textAlign: TextAlign.center,
                  style: bodyTextStyle(
                    context,
                  ).copyWith(color: context.colors.textSecondary),
                ),
                Sp.xlarge.heightBox,
                if (hasFailed) ...[
                  FancyButton(text: LocaleKeys.retry.tr(), onTap: onRetry),
                ] else ...[
                  Semantics(
                    label: message.tr(),
                    liveRegion: true,
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
