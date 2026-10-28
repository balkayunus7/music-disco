import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';

class FancyButton extends StatelessWidget {
  const FancyButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onTap,
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.buttonPrimary,
        foregroundColor: context.colors.textOnPrimary,
        disabledBackgroundColor: context.colors.buttonDisabled,
        minimumSize: const Size(Sp.minTouchTarget, Sp.primaryButtonHeight),
        padding: Sp.medium.padAllR,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sp.medium),
        ),
      ),
      child: isLoading
          ? Semantics(
              label: text,
              liveRegion: true,
              child: SizedBox.square(
                dimension: Sp.xlarge.r,
                child: CircularProgressIndicator(
                  color: context.colors.textOnPrimary,
                ),
              ),
            )
          : Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: buttonTextStyle(
                context,
              ).copyWith(color: context.colors.textOnPrimary),
            ),
    );
  }
}
