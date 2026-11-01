import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.order, required this.child});
  final int order;
  final Widget child;
  static const int _maxOrder = 8;

  @override
  Widget build(BuildContext context) {
    if (context.reducedMotion) return child;
    final delay = MotionDuration.tick * order.clamp(0, _maxOrder);
    final total = MotionDuration.slow + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: MotionCurve.enter,
      ),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * Sp.s12.h),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
