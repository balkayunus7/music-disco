import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/config/app_router.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/features/auth/data/impl_auth_service.dart';

class AuthSessionListener extends StatefulWidget {
  const AuthSessionListener({required this.child, super.key});
  final Widget child;

  @override
  State<AuthSessionListener> createState() => _AuthSessionListenerState();
}

class _AuthSessionListenerState extends State<AuthSessionListener>
    with WidgetsBindingObserver {
  late final ImplAuthService _authService;
  late final StreamSubscription<void> _invalidatedSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authService = getIt<ImplAuthService>();
    _invalidatedSubscription = _authService.sessionInvalidated.listen(
      (_) => _onSessionInvalidated(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authService.startAutoRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _authService.stopAutoRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_invalidatedSubscription.cancel());
    super.dispose();
  }

  void _onSessionInvalidated() {
    if (!mounted) return;
    final authCubit = context.read<AuthCubit>();
    // Sign-out and account deletion clear the session themselves while
    // processing; only an external invalidation needs to reset the state.
    if (authCubit.state.isAuthenticated && !authCubit.state.isProcessing) {
      unawaited(authCubit.signOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.isAuthenticated && !current.isAuthenticated,
      listener: (context, state) => appRouter.go(AppRoutes.splash),
      child: widget.child,
    );
  }
}
