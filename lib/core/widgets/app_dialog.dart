import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/text_link.dart';

Future<T?> showAppDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierColor: context.colors.overlay,
    animationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : null,
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
      insetPadding: EdgeInsets.symmetric(
        horizontal: Sp.large.w,
        vertical: Sp.large.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: context.colors.borderSecondary),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Sp.large.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: sheetTitleStyle(context)),
            ),
            if (message != null) ...[
              Sp.xsmall.heightBox,
              Text(
                message,
                style: bodyTextStyle(
                  context,
                ).copyWith(color: context.colors.textSecondary),
              ),
            ],
            Sp.large.heightBox,
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
    this.cancelLabel,
    this.onCancel,
  });

  final String confirmLabel;
  final VoidCallback? onConfirm;
  final IconData confirmIcon;
  final String? cancelLabel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: Sp.small.w,
      children: [
        TextLink(
          text: cancelLabel ?? LocaleKeys.cancel.tr(),
          onTap: onCancel ?? () => Navigator.of(context).pop(),
        ),
        CtaBar(
          text: confirmLabel,
          icon: confirmIcon,
          compact: true,
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
