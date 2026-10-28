import 'package:mobile_boilerplate/domain/color_theme/color_theme_option.dart';
import 'package:mobile_boilerplate/infrastructure/color_theme/shared_pref_color_theme_cache.dart';

/// The app always uses dark mode, including installs with an old theme choice.
class MusicColorThemeCache extends SharedPrefColorThemeCache {
  const MusicColorThemeCache(super.preferences);

  @override
  ColorThemeOption readColorThemeOption() => ColorThemeOption.dark;
}
