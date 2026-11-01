import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/opacities.dart';

CustomTransitionPage<void> sharedAxisPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: MotionDuration.slow,
    reverseTransitionDuration: MotionDuration.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (context.reducedMotion) return child;
      final incoming = CurvedAnimation(
        parent: animation,
        curve: MotionCurve.enter,
        reverseCurve: MotionCurve.exit,
      );
      final outgoing = CurvedAnimation(
        parent: secondaryAnimation,
        curve: MotionCurve.enter,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 1, end: Opacities.soft).animate(outgoing),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: MotionOffset.pageExit,
          ).animate(outgoing),
          child: FadeTransition(
            opacity: incoming,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: MotionOffset.pageEnter,
                end: Offset.zero,
              ).animate(incoming),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

NoTransitionPage<void> tabRootPage({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
  );
}
