import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/widgets/toss_disc.dart';
import 'package:music_disco/features/core/home/home_page.dart';
import 'package:music_disco/features/settings/bloc/settings_cubit.dart';

mixin HomePageMixin on State<HomePage> {
  static const List<String> _branchRoots = [
    AppRoutes.discover,
    AppRoutes.collection,
    AppRoutes.settings,
  ];

  final ValueNotifier<int> activeBranch = ValueNotifier(0);
  final ValueNotifier<int> landingPulse = ValueNotifier(0);
  final GlobalKey collectionTargetKey = GlobalKey();
  final List<ValueNotifier<int>> branchEntries = List.generate(
    _branchRoots.length,
    (_) => ValueNotifier(0),
  );

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    activeBranch.value = widget.navigationShell.currentIndex;
  }

  @override
  void dispose() {
    activeBranch.dispose();
    landingPulse.dispose();
    for (final entries in branchEntries) {
      entries.dispose();
    }
    super.dispose();
  }

  void onNavTap(int index) {
    final shell = widget.navigationShell;
    final isCurrent = index == shell.currentIndex;
    final isAtRoot = GoRouterState.of(context).uri.path == _branchRoots[index];
    shell.goBranch(index, initialLocation: isCurrent);
    if (isCurrent && !isAtRoot) branchEntries[index].value++;
  }

  Future<void> flyToCollection({
    required Rect from,
    required Widget disc,
  }) async {
    if (context.reducedMotion || context.read<SettingsCubit>().state) {
      return;
    }
    final targetBox =
        collectionTargetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null || !targetBox.hasSize) return;

    final target = targetBox.localToGlobal(Offset.zero) & targetBox.size;
    await tossDisc(
      context,
      from: from,
      to: target,
      child: disc,
      arcHeight: 120,
      turns: 1,
      fadeOnLanding: true,
    );
    if (!mounted) return;
    landingPulse.value++;
    await HapticFeedback.lightImpact();
  }
}
