import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';

TextStyle _montserrat(BuildContext context, double size, FontWeight weight) =>
    TextStyle(
      fontFamily: 'Montserrat',
      package: 'mobile_boilerplate',
      fontSize: size.sp,
      fontWeight: weight,
      color: context.colors.textPrimary,
    );

TextStyle _archivo(BuildContext context, double size) => TextStyle(
  fontFamily: 'ArchivoBlack',
  fontSize: size.sp,
  height: 0.95,
  letterSpacing: -size * 0.035,
  color: context.colors.textPrimary,
);

TextStyle m10w700(BuildContext context) =>
    _montserrat(context, 10, FontWeight.w700);
TextStyle m11w600(BuildContext context) =>
    _montserrat(context, 11, FontWeight.w600);
TextStyle m11w700(BuildContext context) =>
    _montserrat(context, 11, FontWeight.w700);
TextStyle m12w500(BuildContext context) =>
    _montserrat(context, 12, FontWeight.w500);
TextStyle m12w600(BuildContext context) =>
    _montserrat(context, 12, FontWeight.w600);
TextStyle m13w500(BuildContext context) =>
    _montserrat(context, 13, FontWeight.w500);
TextStyle m13w600(BuildContext context) =>
    _montserrat(context, 13, FontWeight.w600);
TextStyle m14w500(BuildContext context) =>
    _montserrat(context, 14, FontWeight.w500);
TextStyle m14w600(BuildContext context) =>
    _montserrat(context, 14, FontWeight.w600);
TextStyle m14w700(BuildContext context) =>
    _montserrat(context, 14, FontWeight.w700);
TextStyle m15w500(BuildContext context) =>
    _montserrat(context, 15, FontWeight.w500);
TextStyle m16w600(BuildContext context) =>
    _montserrat(context, 16, FontWeight.w600);
TextStyle m16w700(BuildContext context) =>
    _montserrat(context, 16, FontWeight.w700);
TextStyle m18w700(BuildContext context) =>
    _montserrat(context, 18, FontWeight.w700);
TextStyle m22w800(BuildContext context) =>
    _montserrat(context, 22, FontWeight.w800);

TextStyle a24(BuildContext context) => _archivo(context, 24);
TextStyle a28(BuildContext context) => _archivo(context, 28);
TextStyle a32(BuildContext context) => _archivo(context, 32);
