import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';

/// Transparent CD jewel case frame with a ribbed spine on the left.
class JewelCase extends StatelessWidget {
  const JewelCase({
    super.key,
    required this.child,
    this.footer,
    this.hasSpine = true,
    this.contentPadding,
  });

  final Widget child;

  /// Optional printed line along the bottom edge of the insert.
  final Widget? footer;
  final bool hasSpine;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final highlight = context.colors.textPrimary;
    return Container(
      padding: (Sp.tiny + 1).padAllR,
      decoration: BoxDecoration(
        borderRadius: Sp.small.radiusR,
        border: Border.all(
          color: highlight.withValues(alpha: 0.38),
          width: 1.4,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.surfaceSecondary,
            context.colors.surface,
            context.colors.surfaceSecondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.overlay,
            blurRadius: Sp.xlarge.r,
            offset: Offset(0, Sp.small.h),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Sp.xsmall.radiusR,
          color: context.colors.surface,
          border: Border.all(color: highlight.withValues(alpha: 0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasSpine) const _CaseSpine(),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: contentPadding ?? Sp.small.padAllR,
                      child: Center(child: child),
                    ),
                  ),
                  if (footer != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        Sp.small.w,
                        0,
                        Sp.small.w,
                        Sp.tiny.h + 2,
                      ),
                      child: footer,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseSpine extends StatelessWidget {
  const _CaseSpine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Sp.small.w,
      child: CustomPaint(
        painter: _SpinePainter(
          color: context.colors.textPrimary.withValues(alpha: 0.16),
        ),
      ),
    );
  }
}

class _SpinePainter extends CustomPainter {
  _SpinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var y = 2.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(2, y), Offset(size.width - 2, y), paint);
    }
    canvas.drawLine(
      Offset(size.width - 0.5, 0),
      Offset(size.width - 0.5, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinePainter oldDelegate) => oldDelegate.color != color;
}
