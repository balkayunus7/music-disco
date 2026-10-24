part of '../pages/direction_page.dart';

class DirectionOptionTile extends StatelessWidget {
  const DirectionOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? context.colors.textPrimary
        : context.colors.textSecondary;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: 240.ms,
          curve: Curves.easeOutCubic,
          height: Sp.xxxlarge.h - Sp.tiny.h,
          padding: Sp.small.padHR,
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.surfaceSecondary
                : context.colors.surface.withValues(alpha: 0),
            borderRadius: Sp.huge.radiusR,
            border: Border.all(
              color: isSelected
                  ? context.colors.border
                  : context.colors.borderSecondary,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: Sp.xsmall.w,
            children: [
              Icon(icon, color: foreground, size: Sp.medium.r),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: m13w600(context).copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
