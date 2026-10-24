import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/pressable.dart';

/// Full-width rounded call to action with a trailing icon.
class CtaBar extends StatelessWidget {
  const CtaBar({
    super.key,
    required this.text,
    required this.onTap,
    this.icon = Icons.north_east_rounded,
    this.isLoading = false,
  });

  final String text;

  /// Null disables the bar.
  final VoidCallback? onTap;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null && !isLoading;
    final foreground = isEnabled
        ? context.colors.textPrimary
        : context.colors.textDisabled;
    return Pressable(
      onTap: isEnabled ? onTap : null,
      semanticLabel: text,
      child: AnimatedContainer(
        duration: 200.ms,
        height: Sp.huge.h + Sp.xsmall.h,
        padding: Sp.xlarge.padHR + Sp.xsmall.padHR,
        decoration: BoxDecoration(
          color: context.colors.buttonSecondary,
          borderRadius: Sp.huge.radiusR,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: m18w700(context).copyWith(color: foreground),
              ),
            ),
            Sp.small.widthBox,
            AnimatedSwitcher(
              duration: 200.ms,
              child: isLoading
                  ? SizedBox.square(
                      key: const ValueKey('loading'),
                      dimension: Sp.large.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  : Icon(
                      icon,
                      key: const ValueKey('icon'),
                      color: foreground,
                      size: Sp.xlarge.r,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
