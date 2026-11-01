import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';

const double _bottomSpacing = Sp.s32;
const double _footerClearance = Sp.s68;
const double _stateViewTopSpacing = Sp.s24;

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.pageBar,
    required this.children,
    this.footer,
    this.stateView,
    this.topSpacing = Sp.s16,
  });
  final AppPageBar pageBar;
  final List<Widget> children;
  final Widget? footer;
  final Widget? stateView;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    final stateView = this.stateView;
    final hasFooter = footer != null;
    return ColoredBox(
      color: context.colors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(padding: Sp.screen.padHR, child: pageBar),
            Expanded(
              child: stateView == null
                  ? _ScrollContent(
                      topSpacing: topSpacing,
                      bottomSpacing: hasFooter
                          ? _footerClearance
                          : _bottomSpacing,
                      children: children,
                    )
                  : _FillContent(
                      topSpacing: topSpacing,
                      stateView: stateView,
                      children: children,
                    ),
            ),
            if (footer != null) _Footer(child: footer),
          ],
        ),
      ),
    );
  }
}

class _ScrollContent extends StatelessWidget {
  const _ScrollContent({
    required this.topSpacing,
    required this.bottomSpacing,
    required this.children,
  });
  final double topSpacing;
  final double bottomSpacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Sp.screen.padHR.copyWith(
        top: topSpacing.h,
        bottom: bottomSpacing.h,
      ),
      child: _ContentColumn(children: children),
    );
  }
}

class _FillContent extends StatelessWidget {
  const _FillContent({
    required this.topSpacing,
    required this.stateView,
    required this.children,
  });
  final double topSpacing;
  final Widget stateView;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: Sp.screen.padHR.copyWith(top: topSpacing.h),
          sliver: SliverToBoxAdapter(child: _ContentColumn(children: children)),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: Sp.screen.padHR.copyWith(
              top: _stateViewTopSpacing.h,
              bottom: _bottomSpacing.h,
            ),
            child: stateView,
          ),
        ),
      ],
    );
  }
}

class _ContentColumn extends StatelessWidget {
  const _ContentColumn({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.background,
        boxShadow: [
          BoxShadow(
            color: context.colors.background,
            blurRadius: Sp.s24.r,
            spreadRadius: Sp.s12.r,
          ),
        ],
      ),
      child: Padding(
        padding: Sp.screen.padHR.copyWith(top: Sp.s8.h, bottom: Sp.s16.h),
        child: child,
      ),
    );
  }
}
