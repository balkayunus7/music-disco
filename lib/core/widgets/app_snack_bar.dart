import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/pressable.dart';

/// Shows a floating confirmation with an optional underlined action.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colors.surfaceSecondary,
        elevation: 0,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.fromLTRB(Sp.xlarge.w, 0, Sp.xlarge.w, Sp.small.h),
        padding: EdgeInsets.symmetric(
          horizontal: Sp.large.w,
          vertical: Sp.medium.h,
        ),
        shape: RoundedRectangleBorder(borderRadius: Sp.medium.radiusR),
        content: Row(
          children: [
            Expanded(child: Text(message, style: m15w500(context))),
            if (actionLabel != null && onAction != null)
              Pressable(
                semanticLabel: actionLabel,
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel,
                  style: m15w500(context).copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: context.colors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
}
