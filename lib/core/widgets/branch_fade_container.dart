import 'package:flutter/material.dart';

class BranchFadeContainer extends StatefulWidget {
  const BranchFadeContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<BranchFadeContainer> createState() => _BranchFadeContainerState();
}

class _BranchFadeContainerState extends State<BranchFadeContainer> {
  late Set<int> _visible = {widget.currentIndex};

  @override
  void didUpdateWidget(BranchFadeContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    _visible = MediaQuery.disableAnimationsOf(context)
        ? {widget.currentIndex}
        : {..._visible, widget.currentIndex};
  }

  void _onEntered(int index) {
    if (!mounted || index != widget.currentIndex || _visible.length == 1) {
      return;
    }
    setState(() => _visible = {index});
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.currentIndex;
    final order = [
      for (var i = 0; i < widget.children.length; i++)
        if (i != current) i,
      current,
    ];
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final index in order)
          _BranchLayer(
            key: ValueKey(index),
            isCurrent: index == current,
            isVisible: _visible.contains(index),
            onEntered: () => _onEntered(index),
            child: widget.children[index],
          ),
      ],
    );
  }
}

class _BranchLayer extends StatefulWidget {
  const _BranchLayer({
    super.key,
    required this.isCurrent,
    required this.isVisible,
    required this.onEntered,
    required this.child,
  });

  final bool isCurrent;
  final bool isVisible;
  final VoidCallback onEntered;
  final Widget child;

  @override
  State<_BranchLayer> createState() => _BranchLayerState();
}

class _BranchLayerState extends State<_BranchLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: widget.isCurrent ? 1 : 0,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void didUpdateWidget(_BranchLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCurrent || !widget.isCurrent) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _controller
        .forward(from: oldWidget.isVisible ? _controller.value : 0)
        .whenComplete(widget.onEntered);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !widget.isVisible,
      child: TickerMode(
        enabled: widget.isCurrent,
        child: IgnorePointer(
          ignoring: !widget.isCurrent,
          child: ExcludeSemantics(
            excluding: !widget.isCurrent,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(_fade),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
