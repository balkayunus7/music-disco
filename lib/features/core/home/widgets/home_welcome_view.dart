part of '../home_page.dart';

class HomeWelcomeView extends StatelessWidget {
  const HomeWelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: Sp.screen.padAllR,
        children: [
          Sp.xxlarge.heightBox,
          Icon(
            Icons.album_rounded,
            size: Sp.xhuge.r,
            color: context.colors.primary,
          ),
          Sp.xlarge.heightBox,
          Text(LocaleKeys.welcome.tr(), style: m22w800(context)),
          Sp.small.heightBox,
          Text(
            LocaleKeys.home_description.tr(),
            style: m14w500(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
          Sp.xxlarge.heightBox,
          const GuestSessionCard(),
        ],
      ),
    );
  }
}
