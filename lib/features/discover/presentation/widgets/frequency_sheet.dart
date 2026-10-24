import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/cta_bar.dart';
import 'package:music_disco/core/widgets/eyebrow_text.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/distance_slider.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

Future<DiscoveryPreferences?> showFrequencySheet(
  BuildContext context, {
  required DiscoveryPreferences initial,
}) {
  return showModalBottomSheet<DiscoveryPreferences>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.overlay,
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
    HapticFeedback.selectionClick();
    setState(() => _draft = next);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.suHeight * 0.92),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: Sp.xxxlarge.radiusOnlyR(tl: true, tr: true),
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Sp.xlarge.w,
              Sp.xlarge.h,
              Sp.xlarge.w,
              Sp.large.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: EyebrowText(
                        LocaleKeys.frequency_sheet_eyebrow.tr(),
                      ),
                    ),
                    _CloseButton(onTap: () => Navigator.of(context).pop()),
                  ],
                ),
                Sp.small.heightBox,
                Text(
                  LocaleKeys.frequency_sheet_title.tr(),
                  style: a28(context),
                ),
                Sp.small.heightBox,
                Text(
                  LocaleKeys.frequency_sheet_subtitle.tr(),
                  style: m14w500(
                    context,
                  ).copyWith(color: context.colors.textSecondary),
                ),
                Sp.xlarge.heightBox,
                _MoodTileGrid(
                  selected: _draft.mood,
                  onSelected: (mood) => _update(_draft.copyWith(mood: mood)),
                ),
                Sp.large.heightBox,
                Row(
                  spacing: Sp.small.w,
                  children: [
                    for (final direction in DiscoveryDirection.values)
                      Expanded(
                        child: _DirectionPill(
                          label: direction.shortLabelKey.tr(),
                          isSelected: _draft.direction == direction,
                          onTap: () =>
                              _update(_draft.copyWith(direction: direction)),
                        ),
                      ),
                  ],
                ),
                Sp.xlarge.heightBox,
                Text(LocaleKeys.distance_title.tr(), style: m16w700(context)),
                Sp.small.heightBox,
                DistanceSlider(
                  value: _draft.distance,
                  mood: _draft.mood,
                  onChanged: (distance) =>
                      _update(_draft.copyWith(distance: distance)),
                ),
                const DistanceSliderLabels(),
                Sp.xlarge.heightBox,
                CtaBar(
                  text: LocaleKeys.frequency_sheet_confirm.tr(),
                  icon: Icons.check_rounded,
                  onTap: () => Navigator.of(context).pop(_draft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: LocaleKeys.close.tr(),
      child: Container(
        width: Sp.cont.r,
        height: Sp.cont.r,
        decoration: BoxDecoration(
          color: context.colors.surfaceSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          color: context.colors.textPrimary,
          size: Sp.xlarge.r,
        ),
      ),
    );
  }
}

class _MoodTileGrid extends StatelessWidget {
  const _MoodTileGrid({required this.selected, required this.onSelected});

  final Mood selected;
  final ValueChanged<Mood> onSelected;

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < Mood.values.length; i += _columns)
        Mood.values.sublist(i, i + _columns),
    ];
    return Column(
      spacing: Sp.small.h,
      children: [
        for (final row in rows)
          Row(
            spacing: Sp.small.w,
            children: [
              for (final mood in row)
                Expanded(
                  child: _MoodTile(
                    mood: mood,
                    isSelected: mood == selected,
                    onTap: () => onSelected(mood),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: mood.labelKey.tr(),
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: 220.ms,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: Sp.medium.h),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.surfaceSecondary
                : context.colors.borderSecondary,
            borderRadius: Sp.large.radiusR,
            border: Border.all(
              color: isSelected
                  ? context.colors.textSecondary
                  : context.colors.borderSecondary,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isSelected ? 1.06 : 1,
                duration: 220.ms,
                child: MoodDisc(mood: mood, size: Sp.huge.r - Sp.xsmall.r),
              ),
              Sp.small.heightBox,
              Text(
                mood.labelKey.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: m14w500(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionPill extends StatelessWidget {
  const _DirectionPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: 220.ms,
        height: Sp.cont.h + Sp.tiny.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.surfaceSecondary
              : context.colors.borderSecondary,
          borderRadius: Sp.xxlarge.radiusR,
          border: Border.all(
            color: isSelected
                ? context.colors.textSecondary
                : context.colors.borderSecondary,
            width: 1.4,
          ),
        ),
        child: ExcludeSemantics(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: m14w500(context),
          ),
        ),
      ),
    );
  }
}
