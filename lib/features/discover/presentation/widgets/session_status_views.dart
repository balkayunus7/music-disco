part of '../pages/session_page.dart';

/// Shown while the round loads: the chosen disc spins in an empty case.
class SessionLoadingView extends StatefulWidget {
  const SessionLoadingView({super.key, required this.mood});

  final Mood mood;

  @override
  State<SessionLoadingView> createState() => _SessionLoadingViewState();
}

class _SessionLoadingViewState extends State<SessionLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: 1600.ms,
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: LocaleKeys.session_loading.tr(),
      child: ExcludeSemantics(
        child: Column(
          children: [
            Sp.xlarge.heightBox,
            AnimatedBuilder(
              animation: _spin,
              builder: (context, _) => MoodDisc(
                mood: widget.mood,
                size: Sp.xxhuge.r + Sp.xxlarge.r,
                turns: _spin.value,
              ),
            ),
            Sp.xlarge.heightBox,
            Text(
              LocaleKeys.session_loading.tr(),
              style: m15w500(
                context,
              ).copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionFailureView extends StatelessWidget {
  const SessionFailureView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Sp.xlarge.heightBox,
        Text(
          LocaleKeys.session_error.tr(),
          textAlign: TextAlign.center,
          style: m16w600(context).copyWith(color: context.colors.textSecondary),
        ),
        Sp.xlarge.heightBox,
        CtaBar(
          text: LocaleKeys.retry.tr(),
          icon: Icons.refresh_rounded,
          onTap: onRetry,
        ),
      ],
    );
  }
}
