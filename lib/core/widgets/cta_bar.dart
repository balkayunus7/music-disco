import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/pressable.dart';

class CtaBar extends StatelessWidget {
  const CtaBar({
    super.key,
    required this.text,
    required this.onTap,
    this.icon = Icons.north_east_rounded,
    this.isLoading = false,
    this.compact = false,
  });

  final String text;

  final VoidCallback? onTap;
  final IconData icon;
  final bool isLoading;
  final bool compact;

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
        height: compact ? Sp.xxxlarge.h - Sp.tiny.h : Sp.cont.h + Sp.tiny.h,
        padding: (compact ? Sp.large : Sp.xlarge).padHR,
        decoration: BoxDecoration(
          color: context.colors.buttonSecondary,
          borderRadius: Sp.huge.radiusR,
        ),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Flexible(
              fit: compact ? FlexFit.loose : FlexFit.tight,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact ? m13w600(context) : m14w700(context)).copyWith(
                  color: foreground,
                ),
              ),
            ),
            (compact ? Sp.xsmall : Sp.small).widthBox,
            AnimatedSwitcher(
              duration: 200.ms,
              child: isLoading
                  ? SizedBox.square(
                      key: const ValueKey('loading'),
                      dimension: (compact ? Sp.medium : Sp.large).r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  : Icon(
                      icon,
                      key: const ValueKey('icon'),
                      color: foreground,
                      size: (compact ? Sp.medium : Sp.large).r,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
