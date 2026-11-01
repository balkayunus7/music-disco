import 'package:flutter/material.dart';
import 'package:music_disco/core/design_system/motion.dart';

class AdaptiveAnimatedSize extends StatelessWidget {
  const AdaptiveAnimatedSize({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });
  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => context.reducedMotion
      ? child
      : AnimatedSize(
          duration: MotionDuration.base,
          curve: MotionCurve.enter,
          alignment: alignment,
          child: child,
        );
}
