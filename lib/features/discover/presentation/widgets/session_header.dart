part of '../pages/session_page.dart';

class SessionHeader extends StatelessWidget {
  const SessionHeader({super.key, required this.rangeLabel});

  final String? rangeLabel;

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
              child: EyebrowText(
                key: ValueKey(rangeLabel),
                LocaleKeys.session_step.tr(args: [rangeLabel ?? '—']),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Sp.small.w,
            vertical: Sp.tiny.h + 2,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary,
            borderRadius: Sp.huge.radiusR,
          ),
          child: Text(
            LocaleKeys.session_draft.tr(),
            style: m10w700(
              context,
            ).copyWith(letterSpacing: 1.4, color: context.colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class PreferenceSummaryBar extends StatelessWidget {
  const PreferenceSummaryBar({
    super.key,
    required this.preferences,
    required this.onTap,
  });

  final DiscoveryPreferences preferences;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final summary = preferences.summary;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      semanticLabel: '${LocaleKeys.frequency_sheet_eyebrow.tr()}: $summary',
      child: ExcludeSemantics(
        child: Container(
          height: Sp.xxxlarge.h - Sp.tiny.h,
          padding: Sp.medium.padHR,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: Sp.huge.radiusR,
          ),
          child: Row(
            spacing: Sp.xsmall.w,
            children: [
              Icon(
                Icons.tune_rounded,
                color: context.colors.textSecondary,
                size: Sp.medium.r,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: 240.ms,
                  child: Align(
                    key: ValueKey(summary),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: m12w500(context),
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.colors.textSecondary,
                size: Sp.large.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
