import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_disco/core/widgets/disc_flight.dart';
import 'package:music_disco/features/core/home/home_page.dart';

mixin HomePageMixin on State<HomePage> {
  final GlobalKey collectionTargetKey = GlobalKey();

  final ValueNotifier<int> landingPulse = ValueNotifier(0);

  @override
  void dispose() {
    landingPulse.dispose();
    super.dispose();
  }

  Future<void> onNavTap(int index) async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    final shell = widget.navigationShell;
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  Future<void> flyToCollection({
    required Rect from,
    required Widget disc,
  }) async {
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
