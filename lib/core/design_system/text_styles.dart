import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/typography.dart';

TextStyle _manrope(
  BuildContext context,
  double size,
  FontWeight weight, {
  double height = LineHeight.base,
  double letterSpacing = LetterSpacing.none,
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
  double height = LineHeight.snug,
  double letterSpacing = LetterSpacing.snug,
}) => TextStyle(
  fontFamily: 'ArchivoBlack',
  fontSize: size,
  fontWeight: FontWeight.w400,
  height: height,
  letterSpacing: letterSpacing,
  color: context.colors.textPrimary,
);

enum HeadlineRole {
  general(FontSize.banner, 0.117, LineHeight.tight, LetterSpacing.tightest),
  home(FontSize.banner, 0.12, LineHeight.tight, LetterSpacing.tightest),
  settings(FontSize.hero, 0.107, LineHeight.tight, LetterSpacing.tightest),
  loading(FontSize.banner, 0.106, LineHeight.tight, LetterSpacing.tight),
  loadingResults(FontSize.hero, 0.091, LineHeight.snug, LetterSpacing.snug);

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
  final isLargeHeadline =
      role == HeadlineRole.general || role == HeadlineRole.home;
  return archivoTextStyle(
    context,
    math.min(role.maximum, contentWidth * role.widthFactor),
    height: role.height,
    letterSpacing: narrow && isLargeHeadline
        ? LetterSpacing.tight
        : role.spacing,
  );
}

TextStyle displayTextStyle(BuildContext context) =>
    archivoTextStyle(context, FontSize.hero);
TextStyle referenceTitleStyle(BuildContext context) =>
    archivoTextStyle(context, FontSize.heading, height: LineHeight.base);
TextStyle trackTitleStyle(BuildContext context) => archivoTextStyle(
  context,
  isNarrowTypography(context) ? FontSize.heading : FontSize.display,
);
TextStyle profileNameStyle(BuildContext context) => archivoTextStyle(
  context,
  isNarrowTypography(context) ? FontSize.large : FontSize.heading,
);
TextStyle sheetTitleStyle(BuildContext context) =>
    archivoTextStyle(context, FontSize.display);
TextStyle logoTextStyle(BuildContext context) => archivoTextStyle(
  context,
  FontSize.hero,
  height: LineHeight.tight,
  letterSpacing: LetterSpacing.tightest,
);
TextStyle discoveryCardTitleStyle(BuildContext context) => _manrope(
  context,
  isNarrowTypography(context) ? FontSize.title : FontSize.subtitle,
  FontWeight.w800,
  height: LineHeight.comfortable,
  letterSpacing: LetterSpacing.soft,
);
TextStyle sectionTitleStyle(BuildContext context) => _manrope(
  context,
  FontSize.title,
  FontWeight.w800,
  letterSpacing: LetterSpacing.soft,
);
TextStyle bodyTextStyle(BuildContext context) => _manrope(
  context,
  FontSize.body,
  FontWeight.w400,
  height: LineHeight.relaxed,
);
TextStyle loadingBodyStyle(BuildContext context) =>
    _manrope(context, FontSize.body, FontWeight.w400, height: LineHeight.loose);
TextStyle buttonTextStyle(BuildContext context) =>
    _manrope(context, FontSize.body, FontWeight.w800);
TextStyle smallButtonTextStyle(BuildContext context) =>
    _manrope(context, FontSize.caption, FontWeight.w800);
TextStyle inputTextStyle(BuildContext context) =>
    _manrope(context, FontSize.title, FontWeight.w400);
TextStyle listTitleStyle(BuildContext context) => _manrope(
  context,
  FontSize.body,
  FontWeight.w700,
  height: LineHeight.comfortable,
);
TextStyle settingsRowTitleStyle(BuildContext context) =>
    _manrope(context, FontSize.body, FontWeight.w700);
TextStyle secondaryTextStyle(BuildContext context) =>
    _manrope(context, FontSize.caption, FontWeight.w400);
TextStyle labelTextStyle(BuildContext context) =>
    _manrope(context, FontSize.caption, FontWeight.w600);
TextStyle navigationTextStyle(BuildContext context) =>
    _manrope(context, FontSize.caption, FontWeight.w700);
TextStyle loadingFootnoteStyle(BuildContext context) => _manrope(
  context,
  FontSize.caption,
  FontWeight.w400,
  height: LineHeight.loose,
);
TextStyle captionLabelStyle(BuildContext context) => _manrope(
  context,
  FontSize.caption,
  FontWeight.w700,
  letterSpacing: LetterSpacing.wide,
);
TextStyle traceNumberStyle(BuildContext context) => _manrope(
  context,
  FontSize.micro,
  FontWeight.w500,
  letterSpacing: LetterSpacing.wide,
);
