import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/text_link.dart';
import 'package:music_disco/core/design_system/motion.dart';

Future<T?> showAppDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierColor: context.colors.overlay,
    animationStyle: context.reducedMotion ? AnimationStyle.noAnimation : null,
    builder: builder,
  );
}

class AppDialogFrame extends StatelessWidget {
  const AppDialogFrame({
    super.key,
    required this.title,
    required this.child,
    this.message,
  });
  final String title;
  final String? message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return Dialog(
      backgroundColor: context.colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: Sp.s20.padSymR(v: Sp.s20),
      shape: RoundedRectangleBorder(
        borderRadius: Sp.s24.radiusR,
        side: BorderSide(color: context.colors.borderSecondary),
      ),
      child: SingleChildScrollView(
        padding: Sp.s20.padAllR,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: sheetTitleStyle(context)),
            ),
            if (message != null) ...[
              Sp.s8.heightBox,
              Text(
                message,
                style: bodyTextStyle(
                  context,
                ).copyWith(color: context.colors.textSecondary),
              ),
            ],
            Sp.s20.heightBox,
            child,
          ],
        ),
      ),
    );
  }
}

class AppDialogActions extends StatelessWidget {
  const AppDialogActions({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmIcon = Icons.check_rounded,
  });
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final IconData confirmIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: Sp.s12.w,
      children: [
        TextLink(
          text: LocaleKeys.cancel.tr(),
          onTap: () => Navigator.of(context).pop(),
        ),
        AppCtaButton(
          text: confirmLabel,
          icon: confirmIcon,
          size: AppCtaButtonSize.compact,
          onTap: onConfirm,
        ),
      ],
    );
  }
}

Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showAppDialog<bool>(
    context,
    builder: (context) => AppDialogFrame(
      title: title,
      message: message,
      child: AppDialogActions(
        confirmLabel: confirmLabel,
        confirmIcon: Icons.delete_outline_rounded,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    ),
  );
  return confirmed ?? false;
}
