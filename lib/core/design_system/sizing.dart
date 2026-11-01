import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class Sp {
  static const double none = 0;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s36 = 36;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;
  static const double s68 = 68;
  static const double s80 = 80;
  static const double s96 = 96;
  static const double s128 = 128;

  // Semantic aliases
  static const double screen = 20;
  static const double minTouchTarget = 44;
  static const double primaryButtonHeight = 56;
  static const double inputRadius = 12;
  static const double control = 56;
}

abstract final class Stroke {
  static const double thin = 1;
  static const double regular = 1.5;
}

extension SizingX on num {
  SizedBox get heightBox => SizedBox(height: toDouble().h);
  SizedBox get widthBox => SizedBox(width: toDouble().w);
}

extension PaddingX on num {
  EdgeInsets get padAllR => EdgeInsets.all(toDouble().r);
  EdgeInsets get padHR => EdgeInsets.symmetric(horizontal: toDouble().w);
  EdgeInsets get padVR => EdgeInsets.symmetric(vertical: toDouble().h);
  EdgeInsets get padXR => padHR;
  EdgeInsets get padYR => padVR;
  EdgeInsets get padTopR => EdgeInsets.only(top: toDouble().h);
  EdgeInsets get padBottomR => EdgeInsets.only(bottom: toDouble().h);
  EdgeInsets get padLeftR => EdgeInsets.only(left: toDouble().w);
  EdgeInsets get padRightR => EdgeInsets.only(right: toDouble().w);

  EdgeInsets padOnlyR({
    bool t = false,
    bool b = false,
    bool l = false,
    bool r = false,
  }) => EdgeInsets.only(
    top: t ? toDouble().h : 0,
    bottom: b ? toDouble().h : 0,
    left: l ? toDouble().w : 0,
    right: r ? toDouble().w : 0,
  );
}

extension AsymmetricPaddingX on num {
  EdgeInsets padHVR(double v) =>
      EdgeInsets.symmetric(horizontal: toDouble().w, vertical: v.h);
  EdgeInsets padVHR(double h) =>
      EdgeInsets.symmetric(vertical: toDouble().h, horizontal: h.w);

  EdgeInsets padSymR({double? h, double? v}) => EdgeInsets.symmetric(
    horizontal: (h ?? toDouble()).w,
    vertical: (v ?? 0).h,
  );
}

extension RadiusX on num {
  BorderRadius get radiusR => BorderRadius.circular(toDouble().r);
  Radius get rRadius => Radius.circular(toDouble().r);

  BorderRadius radiusOnlyR({
    bool tl = false,
    bool tr = false,
    bool bl = false,
    bool br = false,
  }) {
    final r = Radius.circular(toDouble().r);
    return BorderRadius.only(
      topLeft: tl ? r : Radius.zero,
      topRight: tr ? r : Radius.zero,
      bottomLeft: bl ? r : Radius.zero,
      bottomRight: br ? r : Radius.zero,
    );
  }
}

extension FontSizeX on num {
  double get textSp => toDouble().sp;
}

extension DurationX on num {
  Duration get ms => Duration(milliseconds: round());
  Duration get seconds => Duration(seconds: round());
}

extension ContextSizingX on BuildContext {
  double get suWidth => ScreenUtil().screenWidth;
  double get suHeight => ScreenUtil().screenHeight;
}
