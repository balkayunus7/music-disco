import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';

class EntranceFade extends StatelessWidget {
  const EntranceFade({super.key, required this.order, required this.child});

  final int order;
  final Widget child;

  static const int _baseMs = 420;
  static const int _stepMs = 70;
  static const int _maxOrder = 8;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = order.clamp(0, _maxOrder) * _stepMs;
    final total = _baseMs + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total.ms,
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * Sp.small.h),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
