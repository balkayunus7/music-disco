part of '../pages/settings_page.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: listTitleStyle(context).copyWith(color: colors.textTertiary),
          ),
        ),
        Sp.s12.heightBox,
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.borderSecondary),
            borderRadius: Sp.s24.radiusR,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0) const _SettingsDivider(),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  const SettingsRow.external({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : subtitle = null,
       trailing = const _ExternalLinkIcon();
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = this.subtitle;
    final content = Padding(
      padding: Sp.s16.padHVR(Sp.s12),
      child: Row(
        children: [
          Icon(icon, color: colors.textSecondary, size: Sp.s20.r),
          Sp.s12.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: settingsRowTitleStyle(context)),
                if (subtitle != null) ...[
                  Sp.s4.heightBox,
                  Text(
                    subtitle,
                    style: secondaryTextStyle(context).copyWith(
                      color: colors.textSecondary,
                      height: LineHeight.comfortable,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Sp.s12.widthBox,
          trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textTertiary,
                size: Sp.s20.r,
              ),
        ],
      ),
    );
    if (onTap == null) return MergeSemantics(child: content);
    return Pressable(onTap: onTap, child: content);
  }
}

class _ExternalLinkIcon extends StatelessWidget {
  const _ExternalLinkIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.north_east_rounded,
      size: Sp.s16.r,
      color: context.colors.textTertiary,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: Sp.s12.padHR,
    child: Divider(height: Stroke.thin, color: context.colors.borderSecondary),
  );
}
