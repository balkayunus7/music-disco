part of '../pages/session_page.dart';

class SessionHeader extends StatelessWidget {
  const SessionHeader({super.key, required this.rangeLabel, required this.preferences, required this.onTune});

  final String? rangeLabel;
  final DiscoveryPreferences preferences;
  final VoidCallback onTune;

  @override
  Widget build(BuildContext context) {
    final rangeLabel = this.rangeLabel;
    return Row(
      children: [
        const PageBackButton(),
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: 220.ms,
              child: EyebrowText(key: ValueKey(rangeLabel), LocaleKeys.session_step.tr(args: [rangeLabel ?? '—'])),
            ),
          ),
        ),
        Pressable(
          onTap: onTune,
          semanticLabel: '${LocaleKeys.frequency_sheet_eyebrow.tr()}: ${preferences.summary}',
          child: Container(
            width: Sp.xxlarge.r + Sp.tiny.r,
            height: Sp.xxlarge.r + Sp.tiny.r,
            decoration: BoxDecoration(color: context.colors.surfaceSecondary, shape: BoxShape.circle),
            child: Icon(Icons.tune_rounded, color: context.colors.textPrimary, size: Sp.medium.r + 2),
          ),
        ),
      ],
    );
  }
}
