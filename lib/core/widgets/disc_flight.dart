import 'dart:async';

import 'package:flutter/material.dart';

/// Flies [child] along an arc from [from] to [to] (global rects) in the root
/// overlay. Completes when the flight lands and the overlay entry is removed.
Future<void> flyDisc(
  BuildContext context, {
  required Rect from,
  required Rect to,
  required Widget child,
  Duration duration = const Duration(milliseconds: 620),
  double arcHeight = 80,
  double turns = 0.5,
  bool fadeOnLanding = false,
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
  if (overlay == null || overlayBox == null || !overlayBox.hasSize) return;

  final origin = overlayBox.localToGlobal(Offset.zero);
  final landed = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _DiscFlight(
      from: from.shift(-origin),
      to: to.shift(-origin),
      duration: duration,
      arcHeight: arcHeight,
      turns: turns,
      fadeOnLanding: fadeOnLanding,
      onLanded: () {
        entry.remove();
        entry.dispose();
        landed.complete();
      },
      child: child,
    ),
  );
  overlay.insert(entry);
  return landed.future;
}

class _DiscFlight extends StatefulWidget {
  const _DiscFlight({
    required this.from,
    required this.to,
    required this.duration,
    required this.arcHeight,
    required this.turns,
    required this.fadeOnLanding,
    required this.onLanded,
    required this.child,
  });

  final Rect from;
  final Rect to;
  final Duration duration;
  final double arcHeight;
  final double turns;
  final bool fadeOnLanding;
  final VoidCallback onLanded;
  final Widget child;

  @override
  State<_DiscFlight> createState() => _DiscFlightState();
}

class _DiscFlightState extends State<_DiscFlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(widget.onLanded);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) {
          final t = _progress.value;
          final rect = Rect.lerp(widget.from, widget.to, t)!;
          // Quadratic arc: highest point halfway through the flight.
          final lift = 4 * t * (1 - t) * widget.arcHeight;
          final opacity = widget.fadeOnLanding && t > 0.75
              ? (1 - (t - 0.75) / 0.25).clamp(0.0, 1.0)
              : 1.0;
          return Stack(
            children: [
              Positioned.fromRect(
                rect: rect.shift(Offset(0, -lift)),
                child: Opacity(
                  opacity: opacity,
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(t * widget.turns),
                    child: FittedBox(child: child),
                  ),
                ),
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}
