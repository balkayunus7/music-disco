import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/motion.dart';

class TasteLimitText extends StatelessWidget {
  const TasteLimitText({
    super.key,
    required this.status,
    required this.limitMessage,
    required this.isLimited,
    required this.style,
  });
  final String status;
  final String limitMessage;
  final bool isLimited;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = isLimited ? limitMessage : status;
    return AnimatedSwitcher(
      duration: context.motion(MotionDuration.base),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previous, ?current],
      ),
      child: Text(
        text,
        key: ValueKey(isLimited ? 'limit' : status),
        style: style.copyWith(
          color: isLimited ? colors.textPrimary : colors.textSecondary,
        ),
      ),
    );
  }
}
