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
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

class DistanceSlider extends StatefulWidget {
  const DistanceSlider({
    super.key,
    required this.value,
    required this.mood,
    required this.onChanged,
  });

  final DiscoveryDistance value;
  final Mood mood;
  final ValueChanged<DiscoveryDistance> onChanged;

  @override
  State<DistanceSlider> createState() => _DistanceSliderState();
}

class _DistanceSliderState extends State<DistanceSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _position = AnimationController(
    vsync: this,
    value: widget.value.fraction,
    duration: 380.ms,
  );
  bool _isDragging = false;
  DiscoveryDistance? _dragStop;

  static const double _turnsPerTravel = 1.25;

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

  void _onTapTrack(TapUpDetails details, double thumbSize, double travel) {
    if (travel <= 0) return;
    final fraction = (details.localPosition.dx - thumbSize / 2) / travel;
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
      increasedValue: index < values.length - 1
          ? values[index + 1].labelKey.tr()
          : null,
      decreasedValue: index > 0 ? values[index - 1].labelKey.tr() : null,
      onIncrease: index < values.length - 1 ? () => _step(1) : null,
      onDecrease: index > 0 ? () => _step(-1) : null,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final thumbSize = Sp.xxlarge.r + Sp.xsmall.r;
            final travel = constraints.maxWidth - thumbSize;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: (details) =>
                  _onDragUpdate(details, travel),
              onHorizontalDragEnd: (_) => _onDragEnd(),
              onHorizontalDragCancel: _onDragEnd,
              onTapUp: (details) => _onTapTrack(details, thumbSize, travel),
              child: SizedBox(
                height: thumbSize + Sp.small.h,
                child: AnimatedBuilder(
                  animation: _position,
                  builder: (context, _) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TrackPainter(
                            progress: _position.value,
                            inset: thumbSize / 2,
                            stops: [for (final d in values) d.fraction],
                            lineColor: context.colors.border,
                            activeColor: context.colors.textSecondary,
                            tickColor: context.colors.borderSecondary,
                          ),
                        ),
                      ),
                      Positioned(
                        left: travel * _position.value,
                        top: 0,
                        child: _Thumb(
                          mood: widget.mood,
                          size: thumbSize,
                          turns: _position.value * _turnsPerTravel,
                        ),
                      ),
                    ],
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

class _Thumb extends StatelessWidget {
  const _Thumb({required this.mood, required this.size, required this.turns});

  final Mood mood;
  final double size;
  final double turns;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: 2.5.padAllR,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.background,
        border: Border.all(
          color: context.colors.textPrimary.withValues(alpha: 0.85),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(color: context.colors.overlay, blurRadius: Sp.medium.r),
        ],
      ),
      child: MoodDisc(
        mood: mood,
        size: size - 2.5.r * 2 - 3.2,
        turns: turns,
        hasShadow: false,
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.progress,
    required this.inset,
    required this.stops,
    required this.lineColor,
    required this.activeColor,
    required this.tickColor,
  });

  final double progress;
  final double inset;
  final List<double> stops;
  final Color lineColor;
  final Color activeColor;
  final Color tickColor;

  @override
  void paint(Canvas canvas, Size size) {
    final y = inset;
    final start = inset;
    final end = size.width - inset;
    final width = end - start;
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(start, y), Offset(end, y), line);
    canvas.drawLine(
      Offset(start, y),
      Offset(start + width * progress, y),
      line..color = activeColor,
    );

    for (final stop in stops) {
      canvas.drawCircle(
        Offset(start + width * stop, y),
        4,
        Paint()..color = stop <= progress + 0.001 ? activeColor : lineColor,
      );
    }

    final tick = Paint()
      ..color = tickColor
      ..strokeWidth = 1.5;
    final tickTop = y + inset * 0.45;
    for (var x = start; x <= end; x += 9) {
      canvas.drawLine(Offset(x, tickTop), Offset(x, tickTop + 10), tick);
    }
  }

  @override
  bool shouldRepaint(_TrackPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.activeColor != activeColor;
  }
}

class DistanceSliderLabels extends StatelessWidget {
  const DistanceSliderLabels({super.key});

  @override
  Widget build(BuildContext context) {
    final style = m13w500(
      context,
    ).copyWith(color: context.colors.textSecondary);
    return Row(
      children: [
        Expanded(child: Text(LocaleKeys.distance_close.tr(), style: style)),
        Sp.small.widthBox,
        Text(LocaleKeys.distance_never_heard.tr(), style: style),
      ],
    );
  }
}
