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
    this.fillRemaining,
    this.loading = false,
    this.contentTopSpacing = Sp.medium,
  });

  final AppPageBar appBar;
  final bool loading;
  final double contentTopSpacing;

  final List<Widget> children;

  final Widget? footer;
  final Widget? fillRemaining;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    final narrow = MediaQuery.sizeOf(context).width <= 370;
    final horizontal = loading
        ? (narrow ? Sp.narrowLoadingScreen : Sp.loadingScreen)
        : (narrow ? Sp.narrowScreen : Sp.screen);
    final fill = fillRemaining;
    final bottomSpacing = footer == null
        ? Sp.xxlarge
        : Sp.xxlarge + Sp.xlarge + Sp.small;
    final scroll = fill == null
        ? SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              contentTopSpacing.h,
              horizontal,
              bottomSpacing.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  contentTopSpacing.h,
                  horizontal,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    Sp.xlarge.h,
                    horizontal,
                    Sp.xxlarge.h,
                  ),
                  child: fill,
                ),
              ),
            ],
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
