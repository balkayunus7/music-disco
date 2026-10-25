import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';

class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        spacing: Sp.xsmall.w,
        children: [
          for (var step = 1; step <= total; step++)
            Expanded(
              child: ClipRRect(
                borderRadius: Sp.tiny.radiusR,
                child: SizedBox(
                  height: 3.h,
                  child: ColoredBox(
                    color: context.colors.surfaceSecondary,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: step <= current ? 1 : 0),
                      duration: (420 + step * 120).ms,
                      curve: Curves.easeOutCubic,
                      builder: (context, fill, _) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: fill,
                        child: ColoredBox(color: context.colors.textPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
