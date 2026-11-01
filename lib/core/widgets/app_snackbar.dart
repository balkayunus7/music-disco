import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/widgets/pressable.dart';

class AppSnackBarAction {
  const AppSnackBarAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
}

void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colors.surfaceSecondary,
        elevation: 0,
        duration: MotionDuration.snackBar,
        margin: Sp.screen.padHR.copyWith(bottom: Sp.s12.h),
        padding: Sp.s20.padHVR(Sp.s16),
        shape: RoundedRectangleBorder(borderRadius: Sp.s16.radiusR),
        content: Row(
          children: [
            Expanded(child: Text(message, style: bodyTextStyle(context))),
            if (action != null) ...[
              Pressable(
                semanticLabel: action.label,
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  action.onTap();
                },
                child: Center(
                  child: Padding(
                    padding: Sp.s12.padLeftR,
                    child: Text(
                      action.label,
                      style: bodyTextStyle(context).copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
}
