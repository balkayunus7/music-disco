import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<void> sharedAxisPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final incoming = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final outgoing = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.35).animate(outgoing),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.06, 0),
          ).animate(outgoing),
          child: FadeTransition(
            opacity: incoming,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.12, 0),
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
