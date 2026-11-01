import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/opacities.dart';

const double _spineWidth = Sp.s12;

class DiscCase extends StatelessWidget {
  const DiscCase({
    super.key,
    required this.child,
    this.footer,
    this.hasSpine = true,
  });
  final Widget child;
  final Widget? footer;
  final bool hasSpine;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final highlight = colors.textPrimary;
    return Container(
      padding: Sp.s4.padAllR,
      decoration: BoxDecoration(
        borderRadius: Sp.s12.radiusR,
        border: Border.all(
          color: highlight.withValues(alpha: Opacities.muted),
          width: Stroke.regular,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceSecondary,
            colors.surface,
            colors.surfaceSecondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.overlay,
            blurRadius: Sp.s24.r,
            offset: Offset(0, Sp.s12.h),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Sp.s8.radiusR,
          color: colors.surface,
          border: Border.all(
            color: highlight.withValues(alpha: Opacities.faint),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _DiscCaseBody(hasSpine: hasSpine, footer: footer, child: child),
      ),
    );
  }
}

class _DiscCaseBody extends StatelessWidget {
  const _DiscCaseBody({
    required this.hasSpine,
    required this.footer,
    required this.child,
  });
  final bool hasSpine;
  final Widget? footer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final body = Column(
          mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasBoundedHeight)
              Expanded(child: Center(child: child))
            else
              child,
            if (footer != null)
              Padding(padding: Sp.s12.padHVR(Sp.s4), child: footer),
          ],
        );
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: hasSpine ? _spineWidth.w : 0),
              child: hasBoundedHeight ? SizedBox.expand(child: body) : body,
            ),
            if (hasSpine)
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _DiscCaseSpine(),
              ),
          ],
        );
      },
    );
  }
}

class _DiscCaseSpine extends StatelessWidget {
  const _DiscCaseSpine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _spineWidth.w,
      child: CustomPaint(
        painter: _DiscCaseSpinePainter(
          color: context.colors.textPrimary.withValues(alpha: Opacities.subtle),
        ),
      ),
    );
  }
}

class _DiscCaseSpinePainter extends CustomPainter {
  _DiscCaseSpinePainter({required this.color});
  final Color color;

  static const double _ridgeSpacing = 3;
  static const double _ridgeInset = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = Stroke.thin;
    for (var y = _ridgeInset; y < size.height; y += _ridgeSpacing) {
      canvas.drawLine(
        Offset(_ridgeInset, y),
        Offset(size.width - _ridgeInset, y),
        paint,
      );
    }
    canvas.drawLine(
      Offset(size.width - 0.5, 0),
      Offset(size.width - 0.5, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DiscCaseSpinePainter oldDelegate) =>
      oldDelegate.color != color;
}
