import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/presentation/widgets/discovery_loading_view.dart';
import 'package:music_disco/features/discover/presentation/widgets/preferences_summary.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';

class DiscoveryLoadingPage extends StatefulWidget {
  const DiscoveryLoadingPage({super.key, required this.sessionRoute});
  final String sessionRoute;

  @override
  State<DiscoveryLoadingPage> createState() => _DiscoveryLoadingPageState();
}

class _DiscoveryLoadingPageState extends State<DiscoveryLoadingPage>
    with RouteAwareAnalyticsMixin, RouteAwareAnalyticsPageParamsMixin {
  late final DiscoverCubit _discover;
  Timer? _minimumDisplay;
  bool _minimumElapsed = false;

  @override
  void initState() {
    super.initState();
    _discover = context.read<DiscoverCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _minimumDisplay = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() => _minimumElapsed = true);
        _openResults();
      });
      _discover.startRound(taste: context.read<TasteCubit>().state.saved);
    });
  }

  void _openResults() {
    if (!mounted || !_minimumElapsed) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    final state = _discover.state;
    if (state.isReady || state.isFailed) context.go(widget.sessionRoute);
  }

  @override
  void dispose() {
    _minimumDisplay?.cancel();
    _discover.cancelLoadingRound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocConsumer<DiscoverCubit, DiscoverState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) => _openResults(),
        builder: (context, state) => AppPageScaffold(
          footer: PreferencesSummary(preferences: state.preferences),
          pageBar: AppPageBar(title: LocaleKeys.discovery_loading_step.tr()),
          children: [
            DiscoveryLoadingView(
              isSearching: !_minimumElapsed || state.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
