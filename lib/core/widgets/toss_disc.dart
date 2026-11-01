import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_disco/core/design_system/motion.dart';

const double _defaultArcHeight = 80;
const double _defaultTurns = 0.5;
const double _fadeStart = 0.75;
const double _parabolaPeak = 4;

Future<void> tossDisc(
  BuildContext context, {
  required Rect from,
  required Rect to,
  required Widget child,
  double arcHeight = _defaultArcHeight,
  double turns = _defaultTurns,
  bool fadeOnLanding = false,
}) async {
  if (context.reducedMotion) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
  if (overlay == null || overlayBox == null || !overlayBox.hasSize) return;

  final origin = overlayBox.localToGlobal(Offset.zero);
  final landed = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TossedDisc(
      from: from.shift(-origin),
      to: to.shift(-origin),
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

class _TossedDisc extends StatefulWidget {
  const _TossedDisc({
    required this.from,
    required this.to,
    required this.arcHeight,
    required this.turns,
    required this.fadeOnLanding,
    required this.onLanded,
    required this.child,
  });
  final Rect from;
  final Rect to;
  final double arcHeight;
  final double turns;
  final bool fadeOnLanding;
  final VoidCallback onLanded;
  final Widget child;

  @override
  State<_TossedDisc> createState() => _TossedDiscState();
}

class _TossedDiscState extends State<_TossedDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionDuration.emphasized,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: MotionCurve.glide,
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

  double _landingOpacity(double t) {
    if (t <= _fadeStart) return 1;
    return (1 - (t - _fadeStart) / (1 - _fadeStart)).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) {
          final t = _progress.value;
          final rect = Rect.lerp(widget.from, widget.to, t)!;
          final lift = _parabolaPeak * t * (1 - t) * widget.arcHeight;
          final opacity = widget.fadeOnLanding ? _landingOpacity(t) : 1.0;

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
