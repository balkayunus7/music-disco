import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';

/// Rounded label; animates its text when [text] changes.
class PillLabel extends StatelessWidget {
  const PillLabel({
    super.key,
    required this.text,
    this.isStrong = true,
    this.dense = false,
  });

  final String text;

  /// Strong pills use the primary text color on a raised surface.
  final bool isStrong;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = (dense ? m14w500(context) : m16w600(context)).copyWith(
      color: isStrong
          ? context.colors.textPrimary
          : context.colors.textSecondary,
    );
    return AnimatedSize(
      duration: 220.ms,
      curve: Curves.easeOutCubic,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (dense ? Sp.small : Sp.medium + 2).w,
          vertical: (dense ? Sp.xsmall : Sp.small).h,
        ),
        decoration: BoxDecoration(
          color: isStrong
              ? context.colors.surfaceSecondary
              : context.colors.surface,
          borderRadius: Sp.huge.radiusR,
        ),
        child: AnimatedSwitcher(
          duration: 220.ms,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: Text(text, key: ValueKey(text), maxLines: 1, style: style),
        ),
      ),
    );
  }
}
