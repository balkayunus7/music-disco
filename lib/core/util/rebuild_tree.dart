import 'package:flutter/widgets.dart';

void rebuildTree() {
  void rebuild(Element element) {
    element.markNeedsBuild();
    element.visitChildren(rebuild);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
}
