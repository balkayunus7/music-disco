import 'package:flutter/widgets.dart';

extension MotionHelper on BuildContext {
  bool get reducedMotion => MediaQuery.disableAnimationsOf(this);

  Duration motion(Duration duration) =>
      reducedMotion ? Duration.zero : duration;
}

abstract final class MotionDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration emphasized = Duration(milliseconds: 600);
  static const Duration tick = Duration(milliseconds: 50);
  static const Duration pulse = Duration(seconds: 1);
  static const Duration snackBar = Duration(seconds: 3);
}

abstract final class MotionCurve {
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve overshoot = Curves.easeOutBack;
  static const Curve press = Curves.easeOut;
  static const Curve glide = Curves.easeInOutCubic;
}

abstract final class MotionOffset {
  static const double hint = 0.02;
  static const double nudge = 0.05;
  static const double small = 0.1;
  static const double medium = 0.2;
  static const double large = 0.4;

  static const Offset pageEnter = Offset(small, 0);
  static const Offset pageExit = Offset(-nudge, 0);
  static const Offset contentEnter = Offset(nudge, 0);
  static const Offset settleUp = Offset(0, hint);
  static const Offset riseMedium = Offset(0, medium);
  static const Offset riseLarge = Offset(0, large);
}

abstract final class MotionScale {
  static const double enter = 0.85;
  static const double pressed = 0.96;
  static const double pressedSubtle = 0.98;
}
