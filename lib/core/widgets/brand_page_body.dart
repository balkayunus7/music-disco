import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/widgets/brand_header.dart';

/// Scrollable page body with the brand header on top. Pages inside the tab
/// shell use this instead of their own Scaffold.
class BrandPageBody extends StatelessWidget {
  const BrandPageBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Sp.xlarge.w,
            Sp.large.h,
            Sp.xlarge.w,
            Sp.xxlarge.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const BrandHeader(), ...children],
          ),
        ),
      ),
    );
  }
}
