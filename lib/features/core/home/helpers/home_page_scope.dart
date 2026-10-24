import 'package:flutter/widgets.dart';
import 'package:music_disco/features/core/home/helpers/home_page_mixin.dart';

class HomePageScope extends InheritedWidget {
  const HomePageScope({required this.state, required super.child, super.key});
  final HomePageMixin state;

  static HomePageScope of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<HomePageScope>();
    assert(result != null, 'No HomePageScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(HomePageScope oldWidget) => false;
}
