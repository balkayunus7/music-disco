part of '../pages/settings_page.dart';

class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    super.key,
    required this.name,
    required this.summary,
    required this.onEdit,
    required this.onCollection,
  });
  final String name;
  final String summary;
  final VoidCallback onEdit;
  final VoidCallback onCollection;

  static const _silver = DiscPalette(
    deep: Color(0xFF454545),
    base: Color(0xFF9C9C9C),
    light: Color(0xFFF0F0F0),
    holoStrength: 0,
  );

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [context.colors.surfaceSecondary, context.colors.surface],
      ),
      borderRadius: Sp.s18.radiusR,
      border: Border.all(color: context.colors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: Sp.s16.padAllR,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ExcludeSemantics(
                child: DiscCover(
                  palette: _silver,
                  size: Sp.s64.r + Sp.s16.r,
                  title: 'NO RULES',
                  caption: 'ARA SOUND COLLECTION · 06',
                  turns: -0.05,
                ),
              ),
              Sp.s16.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: profileNameStyle(context),
                    ),
                    Pressable(
                      onTap: onEdit,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              LocaleKeys.settings_edit_profile.tr(),
                              style: labelTextStyle(
                                context,
                              ).copyWith(color: context.colors.textSecondary),
                            ),
                          ),
                          Sp.s8.widthBox,
                          Icon(
                            Icons.edit_outlined,
                            size: Sp.s20.r,
                            color: context.colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: Stroke.thin, color: context.colors.borderSecondary),
        Pressable(
          onTap: onCollection,
          child: Padding(
            padding: Sp.s16.padHVR(Sp.s12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    summary,
                    style: secondaryTextStyle(
                      context,
                    ).copyWith(color: context.colors.textSecondary),
                  ),
                ),
                Icon(
                  Icons.north_east_rounded,
                  size: Sp.s20.r,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
