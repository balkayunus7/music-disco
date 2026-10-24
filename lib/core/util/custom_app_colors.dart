import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/app_colors.dart';

abstract final class _Graphite {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1C1C1C);
  static const surfaceSecondary = Color(0xFF2C2C2C);
  static const primary = Color(0xFFECECEC);
  static const secondary = Color(0xFF8A8A8A);
  static const accent = Color(0xFF3A3A3A);
  static const border = Color(0xFF3C3C3C);
  static const borderSecondary = Color(0xFF242424);
  static const textPrimary = Color(0xFFF2F2F2);
  static const textSecondary = Color(0xFFA3A3A3);
  static const textDisabled = Color(0xFF6E6E6E);
  static const textOnPrimary = Color(0xFF141414);
  static const textOnSecondary = Color(0xFFF2F2F2);
  static const buttonSecondary = Color(0xFF323232);
  static const buttonGhost = Color(0x00000000);
  static const buttonDisabled = Color(0xFF2A2A2A);
  static const overlay = Color(0x8C000000);
  static const error = Color(0xFFFF8A80);
  static const errorSurface = Color(0xFF3B1F1E);
  static const success = Color(0xFF9BE3B9);
  static const successSurface = Color(0xFF1C3326);
  static const warning = Color(0xFFFFCF7C);
  static const warningSurface = Color(0xFF3D3020);
}

class CustomAppColorsLight extends AppColorsLight {
  const CustomAppColorsLight()
    : super(
        background: _Graphite.background,
        surface: _Graphite.surface,
        surfaceSecondary: _Graphite.surfaceSecondary,
        primary: _Graphite.primary,
        secondary: _Graphite.secondary,
        accent: _Graphite.accent,
        border: _Graphite.border,
        borderSecondary: _Graphite.borderSecondary,
        textPrimary: _Graphite.textPrimary,
        textSecondary: _Graphite.textSecondary,
        textDisabled: _Graphite.textDisabled,
        textOnPrimary: _Graphite.textOnPrimary,
        textOnSecondary: _Graphite.textOnSecondary,
        buttonPrimary: _Graphite.primary,
        buttonSecondary: _Graphite.buttonSecondary,
        buttonGhost: _Graphite.buttonGhost,
        buttonDisabled: _Graphite.buttonDisabled,
        inputBorderDefault: _Graphite.border,
        inputBorderFocus: _Graphite.primary,
        inputDisabled: _Graphite.surfaceSecondary,
        navBackground: _Graphite.background,
        navIconActive: _Graphite.textPrimary,
        navIconInactive: _Graphite.textSecondary,
        navIndicator: _Graphite.surfaceSecondary,
        overlay: _Graphite.overlay,
        error: _Graphite.error,
        errorSurface: _Graphite.errorSurface,
        success: _Graphite.success,
        successSurface: _Graphite.successSurface,
        warning: _Graphite.warning,
        warningSurface: _Graphite.warningSurface,
        gradientStart: _Graphite.surfaceSecondary,
        gradientEnd: _Graphite.background,
        buttonOnGradient: _Graphite.textPrimary,
        buttonOnGradientText: _Graphite.textOnPrimary,
      );

  @override
  Color get textTertiary => textDisabled;
}

class CustomAppColorsDark extends AppColorsDark {
  const CustomAppColorsDark()
    : super(
        background: _Graphite.background,
        surface: _Graphite.surface,
        surfaceSecondary: _Graphite.surfaceSecondary,
        primary: _Graphite.primary,
        secondary: _Graphite.secondary,
        accent: _Graphite.accent,
        border: _Graphite.border,
        borderSecondary: _Graphite.borderSecondary,
        textPrimary: _Graphite.textPrimary,
        textSecondary: _Graphite.textSecondary,
        textDisabled: _Graphite.textDisabled,
        textOnPrimary: _Graphite.textOnPrimary,
        textOnSecondary: _Graphite.textOnSecondary,
        buttonPrimary: _Graphite.primary,
        buttonSecondary: _Graphite.buttonSecondary,
        buttonGhost: _Graphite.buttonGhost,
        buttonDisabled: _Graphite.buttonDisabled,
        inputBorderDefault: _Graphite.border,
        inputBorderFocus: _Graphite.primary,
        inputDisabled: _Graphite.surfaceSecondary,
        navBackground: _Graphite.background,
        navIconActive: _Graphite.textPrimary,
        navIconInactive: _Graphite.textSecondary,
        navIndicator: _Graphite.surfaceSecondary,
        overlay: _Graphite.overlay,
        error: _Graphite.error,
        errorSurface: _Graphite.errorSurface,
        success: _Graphite.success,
        successSurface: _Graphite.successSurface,
        warning: _Graphite.warning,
        warningSurface: _Graphite.warningSurface,
        gradientStart: _Graphite.surfaceSecondary,
        gradientEnd: _Graphite.background,
        buttonOnGradient: _Graphite.textPrimary,
        buttonOnGradientText: _Graphite.textOnPrimary,
      );

  @override
  Color get textTertiary => textDisabled;
}
