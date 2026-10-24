import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/config/app_router.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/config/setup_dependencies.dart';

class RestartableApp extends StatefulWidget {
  const RestartableApp({required this.child, super.key});
  final Widget child;

  static Future<void> restartApp(BuildContext context) async {
    await context.findAncestorStateOfType<_RestartableAppState>()?.restartApp();
  }

  @override
  State<RestartableApp> createState() => _RestartableAppState();
}

class _RestartableAppState extends State<RestartableApp> {
  Key key = UniqueKey();

  Future<void> restartApp() async {
    await getIt.reset();
    await setupDependencies();
    await EasyLocalization.ensureInitialized();
    if (!mounted) return;
    appRouter.go(AppRoutes.splash);
    setState(() => key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
