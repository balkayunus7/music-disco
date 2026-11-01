part of '../home_page.dart';

class HomeNavBarReveal extends StatelessWidget {
  const HomeNavBarReveal({
    super.key,
    required this.isHidden,
    required this.child,
  });
  final bool isHidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isHidden,
      child: ExcludeSemantics(
        excluding: isHidden,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: isHidden ? 0 : 1),
          duration: context.motion(MotionDuration.base),
          curve: MotionCurve.enter,
          builder: (context, factor, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: factor,
                  child: Opacity(opacity: factor, child: child),
                ),
              ),
              SizedBox(
                height: (1 - factor) * MediaQuery.paddingOf(context).bottom,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
