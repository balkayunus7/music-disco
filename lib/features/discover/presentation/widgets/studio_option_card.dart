part of '../pages/discover_home_page.dart';

class StudioOptionCard extends StatelessWidget {
  const StudioOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      pressedScale: MotionScale.pressedSubtle,
      haptic: TapHaptic.medium,
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Sp.s16.w,
            vertical: Sp.s12.h + 2,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? context.colors.surfaceSecondary
                : context.colors.surface,
            borderRadius: Sp.s20.radiusR,
            border: Border.all(
              color: isPrimary
                  ? context.colors.border
                  : context.colors.borderSecondary,
            ),
          ),
          child: Row(
            spacing: Sp.s12.w,
            children: [
              Container(
                width: Sp.s32.r + Sp.s4.r,
                height: Sp.s32.r + Sp.s4.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.border),
                ),
                child: Icon(
                  icon,
                  color: context.colors.textPrimary,
                  size: Sp.s16.r,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2.h,
                  children: [
                    Text(title, style: discoveryCardTitleStyle(context)),
                    Text(
                      subtitle,
                      style: secondaryTextStyle(
                        context,
                      ).copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.textSecondary,
                size: Sp.s16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
