import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';

enum TapHaptic {
  none,
  selection,
  light,
  medium,
  heavy;

  void play() {
    switch (this) {
      case TapHaptic.none:
        return;
      case TapHaptic.selection:
        HapticFeedback.selectionClick();
      case TapHaptic.light:
        HapticFeedback.lightImpact();
      case TapHaptic.medium:
        HapticFeedback.mediumImpact();
      case TapHaptic.heavy:
        HapticFeedback.heavyImpact();
    }
  }
}

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.selected,
    this.pressedScale = 0.96,
    this.haptic = TapHaptic.light,
  });

  final Widget child;

  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool? selected;
  final double pressedScale;
  final TapHaptic haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _isPressed == value) return;
    if (value) widget.haptic.play();
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _isPressed && !MediaQuery.disableAnimationsOf(context)
              ? widget.pressedScale
              : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : 120.ms,
          curve: Curves.easeOut,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: Sp.minTouchTarget,
              minHeight: Sp.minTouchTarget,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
