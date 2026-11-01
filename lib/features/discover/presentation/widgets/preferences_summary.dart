import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';

class PreferencesSummary extends StatelessWidget {
  const PreferencesSummary({super.key, required this.preferences});
  final DiscoveryPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final text = preferences.detailedSummary;
    return Semantics(
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Sp.s12.w,
          children: [
            Icon(
              Icons.tune_rounded,
              size: Sp.s20.r,
              color: context.colors.textSecondary,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: context.motion(MotionDuration.base),
                child: Text(
                  text,
                  key: ValueKey(text),
                  style: bodyTextStyle(
                    context,
                  ).copyWith(color: context.colors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
