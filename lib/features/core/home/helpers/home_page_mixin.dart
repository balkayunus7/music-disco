import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/core/widgets/disc_flight.dart';
import 'package:music_disco/features/core/home/home_page.dart';
import 'package:music_disco/features/settings/bloc/settings_cubit.dart';

mixin HomePageMixin on State<HomePage> {
  final ValueNotifier<int> activeBranch = ValueNotifier(0);

  final GlobalKey collectionTargetKey = GlobalKey();

  final ValueNotifier<int> landingPulse = ValueNotifier(0);

  final List<ValueNotifier<int>> branchEntries = [
    ValueNotifier(0),
    ValueNotifier(0),
    ValueNotifier(0),
  ];

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.navigationShell.currentIndex;
    activeBranch.value = index;
    if (index != oldWidget.navigationShell.currentIndex) {
      branchEntries[index].value++;
    }
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
    widget.navigationShell.goBranch(index, initialLocation: true);
  }

  Future<void> flyToCollection({
    required Rect from,
    required Widget disc,
  }) async {
    if (MediaQuery.disableAnimationsOf(context) ||
        context.read<SettingsCubit>().state) {
      return;
    }
    final targetBox =
        collectionTargetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null || !targetBox.hasSize) return;

    final target = targetBox.localToGlobal(Offset.zero) & targetBox.size;
    await flyDisc(
      context,
      from: from,
      to: Rect.fromCenter(
        center: target.center,
        width: target.width,
        height: target.height,
      ),
      child: disc,
      arcHeight: 120,
      turns: 1,
      fadeOnLanding: true,
      duration: const Duration(milliseconds: 720),
    );
    if (!mounted) return;
    landingPulse.value++;
    await HapticFeedback.lightImpact();
  }
}
