import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_disco/features/core/home/home_page.dart';

mixin HomePageMixin on State<HomePage> {
  late final PageController pageController;
  late final ValueNotifier<int> currentIndex;

  @override
  void initState() {
    super.initState();
    final initialTab = widget.arguments.initialTabIndex;
    pageController = PageController(initialPage: initialTab);
    currentIndex = ValueNotifier(initialTab);
  }

  @override
  void dispose() {
    pageController.dispose();
    currentIndex.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newArgs = widget.arguments;
    final oldArgs = oldWidget.arguments;
    final hasNewForceKey =
        newArgs.forceUpdateKey != null &&
        newArgs.forceUpdateKey != oldArgs.forceUpdateKey;
    final hasNewTab = newArgs.initialTabIndex != oldArgs.initialTabIndex;
    if ((hasNewForceKey || hasNewTab) &&
        currentIndex.value != newArgs.initialTabIndex) {
      currentIndex.value = newArgs.initialTabIndex;
      if (pageController.hasClients) {
        pageController.jumpToPage(currentIndex.value);
      }
    }
  }

  Future<void> onNavbarTap(int index) async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }
}
