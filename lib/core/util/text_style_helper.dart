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

TextStyle m12w500(BuildContext context) =>
    _montserrat(context, 12, FontWeight.w500);
TextStyle m14w500(BuildContext context) =>
    _montserrat(context, 14, FontWeight.w500);
TextStyle m16w700(BuildContext context) =>
    _montserrat(context, 16, FontWeight.w700);
TextStyle m22w800(BuildContext context) =>
    _montserrat(context, 22, FontWeight.w800);
