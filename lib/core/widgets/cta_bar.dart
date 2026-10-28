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
    this.playerAction = false,
  });

  final String text;

  final VoidCallback? onTap;
  final IconData icon;
  final bool isLoading;
  final bool compact;
  final bool playerAction;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null && !isLoading;
    final foreground = isEnabled
        ? context.colors.textPrimary
        : context.colors.textDisabled;
    return Pressable(
      onTap: isEnabled ? onTap : null,
      semanticLabel: text,
      haptic: TapHaptic.medium,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : 200.ms,
        constraints: BoxConstraints(
          minHeight: compact ? Sp.minTouchTarget : Sp.primaryButtonHeight,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? Sp.large : Sp.xlarge,
          vertical: Sp.small,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? context.colors.buttonSecondary
              : context.colors.buttonDisabled,
          borderRadius: Sp.huge.radiusR,
        ),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: compact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Flexible(
              fit: compact ? FlexFit.loose : FlexFit.tight,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (playerAction
                            ? smallButtonTextStyle(context)
                            : buttonTextStyle(context))
                        .copyWith(color: foreground),
              ),
            ),
            (compact ? Sp.xsmall : Sp.small).widthBox,
            AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : 200.ms,
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
                      size: Sp.large.r,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
