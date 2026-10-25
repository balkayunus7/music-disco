import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';

class BrandPageBody extends StatelessWidget {
  const BrandPageBody({super.key, required this.children, this.footer});

  final List<Widget> children;

  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    final scroll = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(Sp.screen.w, Sp.small.h, Sp.screen.w, Sp.xxlarge.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
    return ColoredBox(
      color: context.colors.background,
      child: SafeArea(
        bottom: false,
        child: footer == null
            ? scroll
            : Column(
                children: [
                  Expanded(child: scroll),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.background,
                          blurRadius: Sp.xlarge.r,
                          spreadRadius: Sp.small.r,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(Sp.screen.w, Sp.xsmall.h, Sp.screen.w, Sp.medium.h),
                      child: footer,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
