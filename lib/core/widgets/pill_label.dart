import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/widgets/adaptive_animated_size.dart';

class PillLabel extends StatelessWidget {
  const PillLabel({super.key, required this.text, this.isStrong = true});
  final String text;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = listTitleStyle(
      context,
    ).copyWith(color: isStrong ? colors.textPrimary : colors.textSecondary);

    return AdaptiveAnimatedSize(
      child: Container(
        padding: Sp.s12.padHVR(Sp.s8),
        decoration: BoxDecoration(
          color: isStrong ? colors.surfaceSecondary : colors.surface,
          borderRadius: Sp.s64.radiusR,
        ),
        child: AnimatedSwitcher(
          duration: context.motion(MotionDuration.base),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: Text(
            text,
            key: ValueKey(text),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      ),
    );
  }
}
