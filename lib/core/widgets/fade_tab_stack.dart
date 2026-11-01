import 'package:flutter/material.dart';
import 'package:music_disco/core/design_system/motion.dart';

class FadeTabStack extends StatefulWidget {
  const FadeTabStack({super.key, required this.index, required this.children})
    : assert(index >= 0 && index < children.length);

  final int index;
  final List<Widget> children;

  @override
  State<FadeTabStack> createState() => _FadeTabStackState();
}

class _FadeTabStackState extends State<FadeTabStack> {
  late Set<int> _shown = {widget.index};

  @override
  void didUpdateWidget(FadeTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    _shown = context.reducedMotion ? {widget.index} : {..._shown, widget.index};
  }

  void _onFadedIn(int index) {
    final isSettled = index == widget.index && _shown.length > 1;
    if (!mounted || !isSettled) return;
    setState(() => _shown = {index});
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.index;
    final paintOrder = [
      for (var i = 0; i < widget.children.length; i++)
        if (i != active) i,
      active,
    ];
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final index in paintOrder)
          _FadeLayer(
            key: ValueKey(index),
            isActive: index == active,
            isShown: _shown.contains(index),
            onFadedIn: () => _onFadedIn(index),
            child: widget.children[index],
          ),
      ],
    );
  }
}

class _FadeLayer extends StatefulWidget {
  const _FadeLayer({
    super.key,
    required this.isActive,
    required this.isShown,
    required this.onFadedIn,
    required this.child,
  });
  final bool isActive;
  final bool isShown;
  final VoidCallback onFadedIn;
  final Widget child;

  @override
  State<_FadeLayer> createState() => _FadeLayerState();
}

class _FadeLayerState extends State<_FadeLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionDuration.base,
    value: widget.isActive ? 1 : 0,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: MotionCurve.enter,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: MotionOffset.settleUp,
    end: Offset.zero,
  ).animate(_fade);

  @override
  void didUpdateWidget(_FadeLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive || !widget.isActive) return;
    if (context.reducedMotion) {
      _controller.value = 1;
      return;
    }
    _controller
        .forward(from: oldWidget.isShown ? _controller.value : 0)
        .whenComplete(widget.onFadedIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !widget.isShown,
      child: TickerMode(
        enabled: widget.isActive,
        child: IgnorePointer(
          ignoring: !widget.isActive,
          child: ExcludeSemantics(
            excluding: !widget.isActive,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(position: _slide, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
