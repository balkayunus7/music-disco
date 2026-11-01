import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_bottom_sheet.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/caption_label.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/discovery_source.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/distance_slider.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

part 'frequency_sheet_tiles.dart';

Future<DiscoveryPreferences?> showFrequencySheet(
  BuildContext context, {
  required DiscoveryPreferences initial,
}) {
  return showAppBottomSheet<DiscoveryPreferences>(
    context,
    builder: (_) => FrequencySheet(initial: initial),
  );
}

class FrequencySheet extends StatefulWidget {
  const FrequencySheet({super.key, required this.initial});
  final DiscoveryPreferences initial;

  @override
  State<FrequencySheet> createState() => _FrequencySheetState();
}

class _FrequencySheetState extends State<FrequencySheet> {
  late DiscoveryPreferences _draft = widget.initial;

  void _update(DiscoveryPreferences next) {
    if (next == _draft) return;
    setState(() => _draft = next);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.suHeight * 0.92),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Sp.screen.w,
            Sp.s20.h,
            Sp.screen.w,
            Sp.s16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CaptionLabel(
                      LocaleKeys.frequency_sheet_eyebrow.tr(),
                    ),
                  ),
                  _CloseButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
              Sp.s8.heightBox,
              Text(
                LocaleKeys.frequency_sheet_title.tr(),
                style: sheetTitleStyle(context),
              ),
              Sp.s8.heightBox,
              Text(
                LocaleKeys.frequency_sheet_subtitle.tr(),
                style: bodyTextStyle(
                  context,
                ).copyWith(color: context.colors.textSecondary),
              ),
              Sp.s20.heightBox,
              _MoodTileGrid(
                selected: _draft.activeReference == null ? _draft.mood : null,
                onSelected: (mood) => _update(
                  _draft.copyWith(mood: mood, source: DiscoverySource.mood),
                ),
              ),
              Sp.s16.heightBox,
              Row(
                spacing: Sp.s8.w,
                children: [
                  for (final direction in DiscoveryDirection.values)
                    Expanded(
                      child: _DirectionPill(
                        icon: direction == DiscoveryDirection.stay
                            ? Icons.repeat_rounded
                            : Icons.graphic_eq_rounded,
                        label: direction.shortLabelKey.tr(),
                        isSelected: _draft.direction == direction,
                        onTap: () =>
                            _update(_draft.copyWith(direction: direction)),
                      ),
                    ),
                ],
              ),
              Sp.s20.heightBox,
              Text(
                LocaleKeys.distance_title.tr(),
                style: buttonTextStyle(context),
              ),
              Sp.s8.heightBox,
              DistanceSlider(
                value: _draft.distance,
                mood: _draft.anchorMood,
                onChanged: (distance) =>
                    _update(_draft.copyWith(distance: distance)),
              ),
              DistanceSliderLabels(value: _draft.distance),
              Sp.s20.heightBox,
              Center(
                child: AppCtaButton(
                  text: LocaleKeys.frequency_sheet_confirm.tr(),
                  icon: Icons.check_rounded,
                  size: AppCtaButtonSize.compact,
                  onTap: () => Navigator.of(context).pop(_draft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
