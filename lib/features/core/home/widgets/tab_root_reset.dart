import 'package:flutter/widgets.dart';
import 'package:music_disco/features/core/home/helpers/home_page_scope.dart';

class TabRootReset extends StatelessWidget {
  const TabRootReset({super.key, required this.branch, required this.child});

  final int branch;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomePageScope.of(context).state.branchEntries[branch],
      builder: (context, entry, child) =>
          KeyedSubtree(key: ValueKey(entry), child: child!),
      child: child,
    );
  }
}
