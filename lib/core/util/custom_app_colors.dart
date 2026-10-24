import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/app_colors.dart';

class CustomAppColorsLight extends AppColorsLight {
  const CustomAppColorsLight()
    : super(
        background: const Color(0xFFF7F7FC),
        surface: const Color(0xFFFFFFFF),
        surfaceSecondary: const Color(0xFFEEEEF8),
        primary: const Color(0xFF6554D9),
        secondary: const Color(0xFF00A995),
        accent: const Color(0xFFEAE5FF),
        border: const Color(0xFFDBDAE8),
        borderSecondary: const Color(0xFFEEEEF8),
        textPrimary: const Color(0xFF201C34),
        textSecondary: const Color(0xFF676378),
        textDisabled: const Color(0xFF918CA2),
        textOnPrimary: const Color(0xFFFFFFFF),
        textOnSecondary: const Color(0xFFFFFFFF),
        buttonPrimary: const Color(0xFF6554D9),
        buttonSecondary: const Color(0xFFEAE5FF),
        buttonGhost: const Color(0x00000000),
        buttonDisabled: const Color(0xFFDBDAE8),
        inputBorderDefault: const Color(0xFFDBDAE8),
        inputBorderFocus: const Color(0xFF6554D9),
        inputDisabled: const Color(0xFFEEEEF8),
        navBackground: const Color(0xFFFFFFFF),
        navIconActive: const Color(0xFF6554D9),
        navIconInactive: const Color(0xFF676378),
        navIndicator: const Color(0xFFEAE5FF),
        overlay: const Color(0x14201C34),
        error: const Color(0xFFB3261E),
        errorSurface: const Color(0xFFFFDAD6),
        success: const Color(0xFF217457),
        successSurface: const Color(0xFFD9F5E7),
        warning: const Color(0xFF855400),
        warningSurface: const Color(0xFFFFEAC7),
        gradientStart: const Color(0xFF6554D9),
        gradientEnd: const Color(0xFF00A995),
        buttonOnGradient: const Color(0xFFFFFFFF),
        buttonOnGradientText: const Color(0xFF201C34),
      );

  @override
  Color get textTertiary => textSecondary;
}

class CustomAppColorsDark extends AppColorsDark {
  const CustomAppColorsDark()
    : super(
        background: const Color(0xFF111118),
        surface: const Color(0xFF1D1D28),
        surfaceSecondary: const Color(0xFF272736),
        primary: const Color(0xFFB7AAFF),
        secondary: const Color(0xFF71DCCA),
        accent: const Color(0xFF38304F),
        border: const Color(0xFF3A394B),
        borderSecondary: const Color(0xFF272736),
        textPrimary: const Color(0xFFF4F1FF),
        textSecondary: const Color(0xFFB7B1C9),
        textDisabled: const Color(0xFF746F86),
        textOnPrimary: const Color(0xFF211B36),
        textOnSecondary: const Color(0xFF122B27),
        buttonPrimary: const Color(0xFFB7AAFF),
        buttonSecondary: const Color(0xFF38304F),
        buttonGhost: const Color(0x00000000),
        buttonDisabled: const Color(0xFF3A394B),
        inputBorderDefault: const Color(0xFF3A394B),
        inputBorderFocus: const Color(0xFFB7AAFF),
        inputDisabled: const Color(0xFF272736),
        navBackground: const Color(0xFF1D1D28),
        navIconActive: const Color(0xFFB7AAFF),
        navIconInactive: const Color(0xFFB7B1C9),
        navIndicator: const Color(0xFF38304F),
        overlay: const Color(0x33000000),
        error: const Color(0xFFFFB4AB),
        errorSurface: const Color(0xFF4D2020),
        success: const Color(0xFF8DDBBA),
        successSurface: const Color(0xFF193B2F),
        warning: const Color(0xFFFFCF7C),
        warningSurface: const Color(0xFF49351C),
        gradientStart: const Color(0xFF38304F),
        gradientEnd: const Color(0xFF193B2F),
        buttonOnGradient: const Color(0xFFF4F1FF),
        buttonOnGradientText: const Color(0xFF211B36),
      );

  @override
  Color get textTertiary => textSecondary;
}
