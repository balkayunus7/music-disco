import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';

/// Logical units from docs/TYPOGRAPHY.md. Text widgets apply the OS text scaler.
TextStyle _manrope(
  BuildContext context,
  double size,
  FontWeight weight, {
  double height = 1.5,
  double letterSpacing = 0,
}) => TextStyle(
  fontFamily: 'Manrope',
  fontSize: size,
  fontWeight: weight,
  fontVariations: [FontVariation('wght', weight.value.toDouble())],
  height: height,
  letterSpacing: letterSpacing,
  color: context.colors.textPrimary,
);

TextStyle archivoTextStyle(
  BuildContext context,
  double size, {
  double height = 1.2,
  double letterSpacing = -1,
}) => TextStyle(
  fontFamily: 'ArchivoBlack',
  fontSize: size,
  fontWeight: FontWeight.w400,
  height: height,
  letterSpacing: letterSpacing,
  color: context.colors.textPrimary,
);

enum HeadlineRole {
  general(36, 0.117, 1.02, -1.8),
  home(38, 0.12, 1.02, -1.8),
  settings(32, 0.107, 1.02, -1.8),
  player(30, 0.096, 1.05, -1.8),
  loading(34, 0.106, 1.05, -1.5),
  loadingResults(30, 0.091, 1.15, -1.2);

  const HeadlineRole(this.maximum, this.widthFactor, this.height, this.spacing);
  final double maximum;
  final double widthFactor;
  final double height;
  final double spacing;
}

bool isNarrowTypography(BuildContext context) =>
    MediaQuery.sizeOf(context).width <= 370;

TextStyle headlineTextStyle(
  BuildContext context,
  double contentWidth, {
  HeadlineRole role = HeadlineRole.general,
}) {
  final narrow = isNarrowTypography(context);
  final spacing = narrow && role == HeadlineRole.loading
      ? -1.3
      : narrow && (role == HeadlineRole.general || role == HeadlineRole.home)
      ? -1.5
      : role.spacing;
  return archivoTextStyle(
    context,
    math.min(role.maximum, contentWidth * role.widthFactor),
    height: role.height,
    letterSpacing: spacing,
  );
}

TextStyle displayTextStyle(BuildContext context) =>
    archivoTextStyle(context, 32);
TextStyle referenceTitleStyle(BuildContext context) =>
    archivoTextStyle(context, 25, height: 1.5);
TextStyle trackTitleStyle(BuildContext context) =>
    archivoTextStyle(context, isNarrowTypography(context) ? 23 : 26);
TextStyle profileNameStyle(BuildContext context) => archivoTextStyle(
  context,
  isNarrowTypography(context) ? 20 : 23,
  letterSpacing: -0.8,
);
TextStyle sheetTitleStyle(BuildContext context) =>
    archivoTextStyle(context, 29, height: 1.15);
TextStyle logoTextStyle(BuildContext context, {bool loading = false}) =>
    archivoTextStyle(
      context,
      loading ? 30 : 31,
      height: 0.9,
      letterSpacing: -2,
    );
TextStyle discoveryCardTitleStyle(BuildContext context) => _manrope(
  context,
  isNarrowTypography(context) ? 15 : 17,
  FontWeight.w800,
  height: 1.3,
  letterSpacing: -0.7,
);
TextStyle sectionTitleStyle(BuildContext context) =>
    _manrope(context, 16, FontWeight.w800, letterSpacing: -0.5);
TextStyle bodyTextStyle(BuildContext context) =>
    _manrope(context, 13, FontWeight.w400, height: 1.65);
TextStyle loadingBodyStyle(BuildContext context) =>
    _manrope(context, 13, FontWeight.w400, height: 1.7);
TextStyle buttonTextStyle(BuildContext context) =>
    _manrope(context, 14, FontWeight.w800);
TextStyle smallButtonTextStyle(BuildContext context) =>
    _manrope(context, 12, FontWeight.w800);
TextStyle loadingButtonTextStyle(BuildContext context) =>
    _manrope(context, 13, FontWeight.w800);
TextStyle inputTextStyle(BuildContext context) =>
    _manrope(context, 16, FontWeight.w400);
TextStyle listTitleStyle(BuildContext context) =>
    _manrope(context, 13, FontWeight.w700, height: 1.3);
TextStyle settingsRowTitleStyle(BuildContext context) =>
    _manrope(context, 13, FontWeight.w700);
TextStyle secondaryTextStyle(BuildContext context) =>
    _manrope(context, 11, FontWeight.w400);
TextStyle labelTextStyle(BuildContext context) =>
    _manrope(context, 12, FontWeight.w600);
TextStyle navigationTextStyle(BuildContext context) =>
    _manrope(context, 11, FontWeight.w700);
TextStyle loadingStatusStyle(BuildContext context) =>
    _manrope(context, 12, FontWeight.w400);
TextStyle loadingFootnoteStyle(BuildContext context) =>
    _manrope(context, 11, FontWeight.w400, height: 1.7);
// Functional upper labels stay at least 11 logical units for readability.
TextStyle eyebrowTextStyle(BuildContext context, {bool loading = false}) =>
    _manrope(context, 11, FontWeight.w700, letterSpacing: loading ? 1.5 : 1.2);
TextStyle traceNumberStyle(BuildContext context) =>
    _manrope(context, 9, FontWeight.w500, letterSpacing: 1.3);
