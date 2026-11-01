part of '../pages/direction_page.dart';

class DirectionOptionTile extends StatelessWidget {
  const DirectionOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.caption,
    required this.energy,
    required this.accent,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String caption;
  final double energy;
  final Color accent;
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
      semanticLabel: '$label, $caption',
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: context.motion(MotionDuration.base),
          curve: MotionCurve.enter,
          padding: EdgeInsets.all(Sp.s16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isSelected
                    ? accent.withValues(alpha: Opacities.subtle)
                    : context.colors.surface,
                isSelected
                    ? context.colors.surfaceSecondary
                    : context.colors.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected
                  ? context.colors.textSecondary
                  : context.colors.borderSecondary,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: foreground, size: Sp.s24.r),
                  _Waveform(energy: energy, isActive: isSelected),
                ],
              ),
              Sp.s12.heightBox,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: listTitleStyle(context).copyWith(color: foreground),
              ),
              Sp.s4.heightBox,
              Text(
                caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: secondaryTextStyle(
                  context,
                ).copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
