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

class _BranchFadeContainerState extends State<BranchFadeContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: 1,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  int? _previousIndex;

  @override
  void didUpdateWidget(BranchFadeContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _previousIndex = null;
        _controller.value = 1;
        return;
      }
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _previousIndex = null);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final (index, child) in widget.children.indexed)
          _buildBranch(index, child),
      ],
    );
  }

  Widget _buildBranch(int index, Widget child) {
    final isCurrent = index == widget.currentIndex;
    final isLeaving = index == _previousIndex;
    return Offstage(
      offstage: !isCurrent && !isLeaving,
      child: TickerMode(
        enabled: isCurrent,
        child: IgnorePointer(
          ignoring: !isCurrent,
          child: ExcludeSemantics(
            excluding: !isCurrent,
            child: FadeTransition(
              opacity: isCurrent ? _fade : ReverseAnimation(_fade),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: isCurrent ? const Offset(0, 0.02) : Offset.zero,
                  end: Offset.zero,
                ).animate(_fade),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
