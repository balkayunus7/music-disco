import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_boilerplate/application/color_theme/color_theme_bloc.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/color_theme/color_theme_option.dart';
import 'package:mobile_boilerplate/domain/color_theme/i_color_theme_cache.dart';
import 'package:mobile_boilerplate/presentation/app_colors.dart';
import 'package:music_disco/core/util/custom_app_colors.dart';
import 'package:music_disco/core/widgets/broken_disc.dart';

void main() {
  testWidgets('BrokenDisc paints at its requested size', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppColorsLight>.value(value: CustomAppColorsLight()),
          Provider<AppColorsDark>.value(value: CustomAppColorsDark()),
          BlocProvider<ColorThemeBloc>(
            create: (_) => ColorThemeBloc(_DarkCache()),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Center(child: BrokenDisc(size: 176))),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(BrokenDisc)), const Size.square(176));
  });
}

class _DarkCache implements IColorThemeCache {
  @override
  ColorThemeOption readColorThemeOption() => ColorThemeOption.dark;

  @override
  Future<void> writeColorThemeOption({
    required ColorThemeOption colorThemeOption,
  }) async {}
}
