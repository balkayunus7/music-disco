import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';

class DistanceSlider extends StatefulWidget {
  const DistanceSlider({super.key, required this.value, required this.mood, required this.onChanged});

  final DiscoveryDistance value;
  final Mood mood;
  final ValueChanged<DiscoveryDistance> onChanged;

  @override
  State<DistanceSlider> createState() => _DistanceSliderState();
}

class _DistanceSliderState extends State<DistanceSlider> with SingleTickerProviderStateMixin {
  late final AnimationController _position = AnimationController(
    vsync: this,
    value: widget.value.fraction,
    duration: 380.ms,
  );
  bool _isDragging = false;
  DiscoveryDistance? _dragStop;

  static const double _inset = 8;

  @override
  void didUpdateWidget(DistanceSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.value != widget.value) {
      _settleOn(widget.value);
    }
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _settleOn(DiscoveryDistance distance) {
    _position.animateTo(distance.fraction, curve: Curves.easeOutCubic);
  }

  void _select(DiscoveryDistance distance) {
    HapticFeedback.lightImpact();
    _settleOn(distance);
    if (distance != widget.value) widget.onChanged(distance);
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStop = widget.value;
  }

  void _onDragUpdate(DragUpdateDetails details, double travel) {
    if (travel <= 0) return;
    _position.value += details.delta.dx / travel;
    final stop = DiscoveryDistance.nearest(_position.value);
    if (stop != _dragStop) {
      _dragStop = stop;
      HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd() {
    _isDragging = false;
    _select(DiscoveryDistance.nearest(_position.value));
  }

  void _onTapTrack(TapUpDetails details, double travel) {
    if (travel <= 0) return;
    final fraction = (details.localPosition.dx - _inset) / travel;
    _select(DiscoveryDistance.nearest(fraction));
  }

  void _step(int delta) {
    final values = DiscoveryDistance.values;
    final index = (widget.value.index + delta).clamp(0, values.length - 1);
    _select(values[index]);
  }

  @override
  Widget build(BuildContext context) {
    final values = DiscoveryDistance.values;
    final index = widget.value.index;
    return Semantics(
      slider: true,
      label: LocaleKeys.distance_title.tr(),
      value: widget.value.labelKey.tr(),
      increasedValue: index < values.length - 1 ? values[index + 1].labelKey.tr() : null,
      decreasedValue: index > 0 ? values[index - 1].labelKey.tr() : null,
      onIncrease: index < values.length - 1 ? () => _step(1) : null,
      onDecrease: index > 0 ? () => _step(-1) : null,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final travel = constraints.maxWidth - _inset * 2;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: (details) => _onDragUpdate(details, travel),
              onHorizontalDragEnd: (_) => _onDragEnd(),
              onHorizontalDragCancel: _onDragEnd,
              onTapUp: (details) => _onTapTrack(details, travel),
              child: SizedBox(
                height: Sp.huge.h,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _position,
                  builder: (context, _) => CustomPaint(
                    painter: _TunerPainter(
                      progress: _position.value,
                      inset: _inset,
                      stops: [for (final d in values) d.fraction],
                      needleColor: widget.mood.palette.light,
                      tickColor: context.colors.border,
                      stopColor: context.colors.textSecondary,
                      labelStyle: m10w700(context).copyWith(color: context.colors.textDisabled),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TunerPainter extends CustomPainter {
  _TunerPainter({
    required this.progress,
    required this.inset,
    required this.stops,
    required this.needleColor,
    required this.tickColor,
    required this.stopColor,
    required this.labelStyle,
  });

  final double progress;
  final double inset;
  final List<double> stops;
  final Color needleColor;
  final Color tickColor;
  final Color stopColor;
  final TextStyle labelStyle;

  static const List<int> _frequencies = [88, 92, 96, 100, 104, 108];
  static const double _tickGap = 8;
  static const double _tickHeight = 10;
  static const double _tickLift = 12;
  static const double _liftRadius = 36;
  static const double _stopHeight = 22;
  static const double _labelHeight = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width - inset * 2;
    final baseline = size.height - _labelHeight;
    final needleX = inset + width * progress;

    final tick = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var x = inset; x <= inset + width + 0.5; x += _tickGap) {
      final closeness = (1 - (x - needleX).abs() / _liftRadius).clamp(0.0, 1.0);
      final height = _tickHeight + _tickLift * closeness;
      tick.color = Color.lerp(tickColor, needleColor, closeness * 0.7)!;
      canvas.drawLine(Offset(x, baseline - height), Offset(x, baseline), tick);
    }

    final stop = Paint()
      ..color = stopColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final fraction in stops) {
      final x = inset + width * fraction;
      canvas.drawLine(Offset(x, baseline - _stopHeight), Offset(x, baseline), stop);
    }

    for (final (index, frequency) in _frequencies.indexed) {
      final x = inset + width * index / (_frequencies.length - 1);
      final label = TextPainter(
        text: TextSpan(text: '$frequency', style: labelStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(x - label.width / 2, baseline + 4));
    }

    final top = Offset(needleX, 4);
    final bottom = Offset(needleX, baseline + 2);
    canvas.drawLine(
      top,
      bottom,
      Paint()
        ..color = needleColor.withValues(alpha: 0.55)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5),
    );
    canvas.drawLine(
      top,
      bottom,
      Paint()
        ..color = needleColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(top, 4, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(_TunerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.needleColor != needleColor ||
        oldDelegate.tickColor != tickColor ||
        oldDelegate.stopColor != stopColor ||
        oldDelegate.labelStyle != labelStyle;
  }
}

class DistanceSliderLabels extends StatelessWidget {
  const DistanceSliderLabels({super.key});

  @override
  Widget build(BuildContext context) {
    final style = m13w500(context).copyWith(color: context.colors.textSecondary);
    return Row(
      children: [
        Expanded(child: Text(LocaleKeys.distance_close.tr(), style: style)),
        Sp.small.widthBox,
        Text(LocaleKeys.distance_never_heard.tr(), style: style),
      ],
    );
  }
}
