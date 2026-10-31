import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
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
          spacing: Sp.small.w,
          children: [
            Icon(
              Icons.tune_rounded,
              size: Sp.large.r,
              color: context.colors.textSecondary,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : 240.ms,
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
