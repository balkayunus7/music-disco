part of '../pages/splash_page.dart';

class SplashView extends StatelessWidget {
  const SplashView({required this.hasFailed, required this.onRetry, super.key});
  final bool hasFailed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final title = (hasFailed ? LocaleKeys.error_title : LocaleKeys.app_name)
        .tr();
    final message = (hasFailed ? LocaleKeys.error_message : LocaleKeys.starting)
        .tr();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Sp.s24.padAllR,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.graphic_eq_rounded,
                  size: Sp.s64.r,
                  color: context.colors.primary,
                ),
                Sp.s24.heightBox,
                Text(
                  title,
                  style: hasFailed
                      ? sheetTitleStyle(context)
                      : logoTextStyle(context),
                  textAlign: TextAlign.center,
                ),
                Sp.s12.heightBox,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: bodyTextStyle(
                    context,
                  ).copyWith(color: context.colors.textSecondary),
                ),
                Sp.s24.heightBox,
                if (hasFailed) ...[
                  AppCtaButton(text: LocaleKeys.retry.tr(), onTap: onRetry),
                ] else ...[
                  Semantics(
                    label: message,
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
