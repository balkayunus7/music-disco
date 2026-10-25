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
      pressedScale: 0.98,
      haptic: TapHaptic.medium,
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Sp.medium.w,
            vertical: Sp.small.h + 2,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? context.colors.surfaceSecondary
                : context.colors.surface,
            borderRadius: Sp.large.radiusR,
            border: Border.all(
              color: isPrimary
                  ? context.colors.border
                  : context.colors.borderSecondary,
            ),
          ),
          child: Row(
            spacing: Sp.small.w,
            children: [
              Container(
                width: Sp.xxlarge.r + Sp.tiny.r,
                height: Sp.xxlarge.r + Sp.tiny.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.border),
                ),
                child: Icon(
                  icon,
                  color: context.colors.textPrimary,
                  size: Sp.medium.r,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2.h,
                  children: [
                    Text(title, style: m14w700(context)),
                    Text(
                      subtitle,
                      style: m12w500(
                        context,
                      ).copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.north_east_rounded,
                color: context.colors.textSecondary,
                size: Sp.medium.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
