import 'package:flutter/painting.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/core/util/disc_palette.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/reference_aspect.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';

extension MoodStyle on Mood {
  String get labelKey => switch (this) {
    Mood.afterHours => LocaleKeys.mood_after_hours,
    Mood.turnItUp => LocaleKeys.mood_turn_it_up,
    Mood.softSide => LocaleKeys.mood_soft_side,
    Mood.slowDown => LocaleKeys.mood_slow_down,
    Mood.oldFeeling => LocaleKeys.mood_old_feeling,
    Mood.noRules => LocaleKeys.mood_no_rules,
  };

  String get taglineKey => switch (this) {
    Mood.afterHours => LocaleKeys.mood_after_hours_tagline,
    Mood.turnItUp => LocaleKeys.mood_turn_it_up_tagline,
    Mood.softSide => LocaleKeys.mood_soft_side_tagline,
    Mood.slowDown => LocaleKeys.mood_slow_down_tagline,
    Mood.oldFeeling => LocaleKeys.mood_old_feeling_tagline,
    Mood.noRules => LocaleKeys.mood_no_rules_tagline,
  };

  String get discCaption => 'ARA SOUND COLLECTION · ${collectionNumber.toString().padLeft(2, '0')}';

  DiscPalette get palette => switch (this) {
    Mood.afterHours => const DiscPalette(
      deep: Color(0xFF1E1838),
      base: Color(0xFF5B45B8),
      light: Color(0xFFC8B6FF),
      holoStrength: 0.6,
    ),
    Mood.turnItUp => const DiscPalette(
      deep: Color(0xFFC9401A),
      base: Color(0xFFEE6A24),
      light: Color(0xFFFFB25A),
      holoStrength: 0.1,
    ),
    Mood.softSide => const DiscPalette(
      deep: Color(0xFF6E2C8E),
      base: Color(0xFFB35FD6),
      light: Color(0xFFF2C2FF),
      holoStrength: 0.5,
    ),
    Mood.slowDown => const DiscPalette(
      deep: Color(0xFF4A5340),
      base: Color(0xFF8E9A7A),
      light: Color(0xFFDCE3C8),
      holoStrength: 0.5,
    ),
    Mood.oldFeeling => const DiscPalette(
      deep: Color(0xFF2D4A57),
      base: Color(0xFF6F97A6),
      light: Color(0xFFD1E7EF),
      holoStrength: 0.5,
    ),
    Mood.noRules => const DiscPalette(
      deep: Color(0xFF4E4E4E),
      base: Color(0xFF9C9C9C),
      light: Color(0xFFEFEFEF),
      holoStrength: 0.55,
    ),
  };
}

extension DiscoveryDirectionStyle on DiscoveryDirection {
  String get shortLabelKey => switch (this) {
    DiscoveryDirection.stay => LocaleKeys.direction_stay_short,
    DiscoveryDirection.lift => LocaleKeys.direction_lift_short,
  };

  String get captionKey => switch (this) {
    DiscoveryDirection.stay => LocaleKeys.direction_stay_caption,
    DiscoveryDirection.lift => LocaleKeys.direction_lift_caption,
  };

  double get energy => switch (this) {
    DiscoveryDirection.stay => 0.45,
    DiscoveryDirection.lift => 1,
  };
}

extension DiscoveryDistanceStyle on DiscoveryDistance {
  String get labelKey => switch (this) {
    DiscoveryDistance.close => LocaleKeys.distance_close,
    DiscoveryDistance.bitDifferent => LocaleKeys.distance_bit_different,
    DiscoveryDistance.faraway => LocaleKeys.distance_faraway,
  };
}

extension TrackFeedbackStyle on TrackFeedback {
  String get labelKey => switch (this) {
    TrackFeedback.tooCalm => LocaleKeys.session_too_calm,
    TrackFeedback.tooLively => LocaleKeys.session_too_lively,
    TrackFeedback.notMyStyle => LocaleKeys.session_not_my_style,
    TrackFeedback.alreadyKnown => LocaleKeys.session_known,
  };
}

extension ReferenceAspectStyle on ReferenceAspect {
  String get labelKey => switch (this) {
    ReferenceAspect.atmosphere => LocaleKeys.aspect_atmosphere,
    ReferenceAspect.vocals => LocaleKeys.aspect_vocals,
    ReferenceAspect.rhythm => LocaleKeys.aspect_rhythm,
    ReferenceAspect.overallStyle => LocaleKeys.aspect_overall_style,
  };

  String get captionKey => switch (this) {
    ReferenceAspect.atmosphere => LocaleKeys.aspect_atmosphere_caption,
    ReferenceAspect.vocals => LocaleKeys.aspect_vocals_caption,
    ReferenceAspect.rhythm => LocaleKeys.aspect_rhythm_caption,
    ReferenceAspect.overallStyle => LocaleKeys.aspect_overall_style_caption,
  };
}

extension MusicReferenceStyle on MusicReference {
  String get subtitle => artist ?? LocaleKeys.reference_kind_artist.tr();

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.length > 1 ? '${words[0][0]}${words[1][0]}' : name.trim().padRight(2).substring(0, 2);
    return letters.trim().toUpperCase();
  }
}

extension DiscoveryPreferencesStyle on DiscoveryPreferences {
  String get summary =>
      [activeReference?.name ?? mood.labelKey.tr(), direction.shortLabelKey.tr(), distance.labelKey.tr()].join(' · ');
}
