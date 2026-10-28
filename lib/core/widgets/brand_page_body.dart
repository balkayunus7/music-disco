import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/widgets/app_page_bar.dart';

class BrandPageBody extends StatelessWidget {
  const BrandPageBody({
    super.key,
    required this.appBar,
    required this.children,
    this.footer,
    this.loading = false,
    this.contentTopSpacing = Sp.medium,
  });

  final AppPageBar appBar;
  final bool loading;
  final double contentTopSpacing;

  final List<Widget> children;

  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    final narrow = MediaQuery.sizeOf(context).width <= 370;
    final horizontal = loading
        ? (narrow ? Sp.narrowLoadingScreen : Sp.loadingScreen)
        : (narrow ? Sp.narrowScreen : Sp.screen);
    final scroll = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        contentTopSpacing.h,
        horizontal,
        Sp.xxlarge.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
    return ColoredBox(
      color: context.colors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: appBar,
            ),
            Expanded(child: scroll),
            if (footer != null)
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
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    Sp.xsmall.h,
                    horizontal,
                    Sp.medium.h,
                  ),
                  child: footer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
