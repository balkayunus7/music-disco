import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/routing/route_aware_analytics_mixin.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/widgets/app_page_bar.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/presentation/widgets/discovery_loading_view.dart';
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
    final status = _discover.state.status;
    if (status == DiscoverRoundStatus.ready ||
        status == DiscoverRoundStatus.failure) {
      context.go(widget.sessionRoute);
    }
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
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _discover.cancelLoadingRound();
      },
      child: BlocConsumer<DiscoverCubit, DiscoverState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) => _openResults(),
        builder: (context, state) => BrandPageBody(
          loading: true,
          appBar: AppPageBar(
            title: LocaleKeys.discovery_loading_step.tr(),
            showBackButton: true,
          ),
          children: [
            DiscoveryLoadingView(
              isSearching:
                  !_minimumElapsed ||
                  state.status == DiscoverRoundStatus.loading,
            ),
          ],
        ),
      ),
    );
  }
}
