import 'package:flutter/material.dart';

/// Zero-duration AnimatedSize can invalidate layout while it is in progress.
/// Render directly when reduced motion is requested.
class MotionSize extends StatelessWidget {
  const MotionSize({
    super.key,
    required this.duration,
    required this.child,
    this.curve = Curves.linear,
    this.alignment = Alignment.center,
  });
  final Duration duration;
  final Widget child;
  final Curve curve;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => MediaQuery.disableAnimationsOf(context)
      ? child
      : AnimatedSize(
          duration: duration,
          curve: curve,
          alignment: alignment,
          child: child,
        );
}
