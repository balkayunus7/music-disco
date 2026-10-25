import 'package:flutter/material.dart';
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
import 'package:music_disco/features/discover/domain/models/discovery_source.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';
import 'package:music_disco/features/discover/presentation/widgets/distance_slider.dart';
import 'package:music_disco/features/discover/presentation/widgets/mood_disc.dart';

Future<DiscoveryPreferences?> showFrequencySheet(BuildContext context, {required DiscoveryPreferences initial}) {
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
            padding: EdgeInsets.fromLTRB(Sp.screen.w, Sp.large.h, Sp.screen.w, Sp.medium.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: EyebrowText(LocaleKeys.frequency_sheet_eyebrow.tr())),
                    _CloseButton(onTap: () => Navigator.of(context).pop()),
                  ],
                ),
                Sp.xsmall.heightBox,
                Text(LocaleKeys.frequency_sheet_title.tr(), style: a24(context)),
                Sp.xsmall.heightBox,
                Text(
                  LocaleKeys.frequency_sheet_subtitle.tr(),
                  style: m13w500(context).copyWith(color: context.colors.textSecondary),
                ),
                Sp.large.heightBox,
                _MoodTileGrid(
                  selected: _draft.activeReference == null ? _draft.mood : null,
                  onSelected: (mood) => _update(_draft.copyWith(mood: mood, source: DiscoverySource.mood)),
                ),
                Sp.medium.heightBox,
                Row(
                  spacing: Sp.xsmall.w,
                  children: [
                    for (final direction in DiscoveryDirection.values)
                      Expanded(
                        child: _DirectionPill(
                          icon: direction == DiscoveryDirection.stay ? Icons.repeat_rounded : Icons.graphic_eq_rounded,
                          label: direction.shortLabelKey.tr(),
                          isSelected: _draft.direction == direction,
                          onTap: () => _update(_draft.copyWith(direction: direction)),
                        ),
                      ),
                  ],
                ),
                Sp.large.heightBox,
                Text(LocaleKeys.distance_title.tr(), style: m14w700(context)),
                Sp.xsmall.heightBox,
                DistanceSlider(
                  value: _draft.distance,
                  mood: _draft.anchorMood,
                  onChanged: (distance) => _update(_draft.copyWith(distance: distance)),
                ),
                const DistanceSliderLabels(),
                Sp.large.heightBox,
                Center(
                  child: CtaBar(
                    text: LocaleKeys.frequency_sheet_confirm.tr(),
                    icon: Icons.check_rounded,
                    compact: true,
                    onTap: () => Navigator.of(context).pop(_draft),
                  ),
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
        width: Sp.xxlarge.r + Sp.tiny.r,
        height: Sp.xxlarge.r + Sp.tiny.r,
        decoration: BoxDecoration(color: context.colors.surfaceSecondary, shape: BoxShape.circle),
        child: Icon(Icons.close_rounded, color: context.colors.textPrimary, size: Sp.medium.r + 2),
      ),
    );
  }
}

class _MoodTileGrid extends StatelessWidget {
  const _MoodTileGrid({required this.selected, required this.onSelected});

  final Mood? selected;
  final ValueChanged<Mood> onSelected;

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final rows = [for (var i = 0; i < Mood.values.length; i += _columns) Mood.values.sublist(i, i + _columns)];
    return Column(
      spacing: Sp.xsmall.h,
      children: [
        for (final row in rows)
          Row(
            spacing: Sp.xsmall.w,
            children: [
              for (final mood in row)
                Expanded(
                  child: _MoodTile(mood: mood, isSelected: mood == selected, onTap: () => onSelected(mood)),
                ),
            ],
          ),
      ],
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({required this.mood, required this.isSelected, required this.onTap});

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
          padding: EdgeInsets.symmetric(vertical: Sp.small.h, horizontal: Sp.tiny.w),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.surfaceSecondary : context.colors.surfaceSecondary.withValues(alpha: 0),
            borderRadius: Sp.medium.radiusR,
            border: Border.all(color: isSelected ? context.colors.border : context.colors.border.withValues(alpha: 0)),
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isSelected ? 1.06 : 1,
                duration: 220.ms,
                child: MoodDisc(mood: mood, size: Sp.xxxlarge.r - Sp.tiny.r),
              ),
              Sp.xsmall.heightBox,
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  mood.labelKey.tr(),
                  maxLines: 1,
                  style: m12w600(
                    context,
                  ).copyWith(color: isSelected ? context.colors.textPrimary : context.colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionPill extends StatelessWidget {
  const _DirectionPill({required this.icon, required this.label, required this.isSelected, required this.onTap});

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? context.colors.textPrimary : context.colors.textSecondary;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: 220.ms,
          height: Sp.xxxlarge.h - Sp.tiny.h,
          padding: Sp.small.padHR,
          decoration: BoxDecoration(
            color: isSelected ? context.colors.surfaceSecondary : context.colors.surfaceSecondary.withValues(alpha: 0),
            borderRadius: Sp.huge.radiusR,
            border: Border.all(color: isSelected ? context.colors.border : context.colors.borderSecondary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: Sp.xsmall.w,
            children: [
              Icon(icon, color: foreground, size: Sp.medium.r),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: m13w600(context).copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
