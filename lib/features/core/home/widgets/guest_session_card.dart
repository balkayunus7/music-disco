part of '../home_page.dart';

class GuestSessionCard extends StatelessWidget {
  const GuestSessionCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: Sp.large.padAllR,
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: Sp.xlarge.radiusR,
      boxShadow: [
        BoxShadow(color: context.colors.overlay, blurRadius: Sp.small.r),
      ],
    ),
    child: Row(
      children: [
        Icon(
          Icons.person_outline_rounded,
          color: context.colors.primary,
          size: Sp.xlarge.r,
        ),
        Sp.small.widthBox,
        Expanded(
          child: Text(LocaleKeys.guest_session.tr(), style: m14w500(context)),
        ),
        Icon(
          Icons.check_circle_outline_rounded,
          color: context.colors.success,
          size: Sp.xlarge.r,
        ),
      ],
    ),
  );
}
