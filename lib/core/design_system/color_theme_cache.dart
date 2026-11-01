import 'package:mobile_boilerplate/domain/color_theme/color_theme_option.dart';
import 'package:mobile_boilerplate/domain/color_theme/i_color_theme_cache.dart';

class ColorThemeCache implements IColorThemeCache {
  const ColorThemeCache();

  @override
  ColorThemeOption readColorThemeOption() => ColorThemeOption.dark;

  @override
  Future<void> writeColorThemeOption({
    required ColorThemeOption colorThemeOption,
  }) async {}
}
