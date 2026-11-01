part of '../pages/discover_home_page.dart';

class StudioResumeCard extends StatelessWidget {
  const StudioResumeCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel:
        '${LocaleKeys.studio_resume.tr()}. ${LocaleKeys.studio_resume_action.tr()}',
    haptic: TapHaptic.selection,
    child: ExcludeSemantics(
      child: Container(
        padding: Sp.s12.padAllR,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: Sp.s20.radiusR,
          border: Border.all(color: context.colors.borderSecondary),
        ),
        child: Row(
          spacing: Sp.s12.w,
          children: [
            Icon(
              Icons.history_rounded,
              color: context.colors.textSecondary,
              size: Sp.s20.r,
            ),
            Expanded(
              child: Text(
                LocaleKeys.studio_resume.tr(),
                style: listTitleStyle(context),
              ),
            ),
            Text(
              LocaleKeys.studio_resume_action.tr(),
              style: labelTextStyle(
                context,
              ).copyWith(color: context.colors.textSecondary),
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
