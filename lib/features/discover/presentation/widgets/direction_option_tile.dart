part of '../pages/direction_page.dart';

class DirectionOptionTile extends StatelessWidget {
  const DirectionOptionTile({
    super.key,
    required this.icon,
    required this.firstLine,
    required this.secondLine,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String firstLine;
  final String secondLine;
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
      semanticLabel: '$firstLine $secondLine',
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: 240.ms,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: Sp.medium.w,
            vertical: Sp.large.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.surfaceSecondary
                : context.colors.borderSecondary,
            borderRadius: Sp.large.radiusR,
            border: Border.all(
              color: isSelected
                  ? context.colors.border
                  : context.colors.borderSecondary,
            ),
          ),
          child: Row(
            spacing: Sp.small.w,
            children: [
              Icon(icon, color: foreground, size: Sp.xlarge.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: m15w500(context).copyWith(color: foreground),
                    ),
                    Text(
                      secondLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: m18w700(context).copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
