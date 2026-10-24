import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_disco/core/widgets/disc_flight.dart';
import 'package:music_disco/features/core/home/home_page.dart';

mixin HomePageMixin on State<HomePage> {
  /// Marks the koleksiyon tab icon so saved discs can fly into it.
  final GlobalKey collectionTargetKey = GlobalKey();

  /// Increments whenever a disc lands on the koleksiyon tab.
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
    // Tapping the active tab returns it to its first page.
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  /// Flies [disc] from [from] (a global rect) into the koleksiyon tab.
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
