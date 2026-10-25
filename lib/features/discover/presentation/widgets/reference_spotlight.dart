part of '../pages/reference_page.dart';

class ReferenceSpotlight extends StatelessWidget {
  const ReferenceSpotlight({super.key, required this.reference});

  final MusicReference reference;

  @override
  Widget build(BuildContext context) {
    final role = reference.kind == ReferenceKind.artist
        ? LocaleKeys.reference_role_artist.tr()
        : '${reference.artistName} · ${LocaleKeys.reference_role_song.tr()}';
    return Semantics(
      label: '${reference.name}, $role',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Sp.large.w, vertical: Sp.large.h),
          decoration: BoxDecoration(
            borderRadius: Sp.xlarge.radiusR,
            border: Border.all(color: context.colors.borderSecondary),
            gradient: RadialGradient(
              center: const Alignment(0, -0.4),
              radius: 1.1,
              colors: [context.colors.surfaceSecondary, context.colors.surface],
            ),
          ),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey(reference.id),
                tween: Tween(begin: 0.18, end: 0),
                duration: 760.ms,
                curve: Curves.easeOutCubic,
                builder: (context, turns, _) => Transform.scale(
                  scale: 1 - turns,
                  child: MoodDisc(mood: reference.mood, size: 108.r, turns: turns),
                ),
              ),
              Sp.medium.heightBox,
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(reference.name, maxLines: 1, style: a24(context)),
              ),
              Sp.tiny.heightBox,
              Text(
                role,
                textAlign: TextAlign.center,
                style: m12w500(context).copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
