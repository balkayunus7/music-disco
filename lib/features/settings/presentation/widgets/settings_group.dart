part of '../pages/settings_page.dart';

class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: listTitleStyle(
        context,
      ).copyWith(color: context.colors.textTertiary),
    ),
  );
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colors.surface,
      border: Border.all(color: context.colors.borderSecondary),
      borderRadius: Sp.xlarge.radiusR,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
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
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: Sp.medium.padHVR(Sp.small),
      child: Row(
        children: [
          Icon(icon, color: context.colors.textSecondary, size: Sp.large.r),
          Sp.small.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: settingsRowTitleStyle(context)),
                if (subtitle != null) ...[
                  Sp.tiny.heightBox,
                  Text(
                    subtitle!,
                    style: secondaryTextStyle(context).copyWith(
                      color: context.colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Sp.small.widthBox,
          if (trailing != null)
            trailing!
          else
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textTertiary,
              size: Sp.large.r,
            ),
        ],
      ),
    );
    if (onTap == null) return MergeSemantics(child: content);
    return Pressable(onTap: onTap, child: content);
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: Sp.small.padHR,
    child: Divider(height: 1, color: context.colors.borderSecondary),
  );
}
