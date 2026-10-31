part of '../pages/reference_page.dart';

class ReferenceQuickPicks extends StatelessWidget {
  const ReferenceQuickPicks({
    super.key,
    required this.references,
    required this.onPicked,
  });

  final List<MusicReference> references;
  final ValueChanged<MusicReference> onPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Sp.xsmall.h,
      children: [
        Text(
          LocaleKeys.reference_saved_title.tr(),
          style: sectionTitleStyle(context),
        ),
        SizedBox(
          height: Sp.minTouchTarget.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: references.length,
            separatorBuilder: (context, index) => Sp.xsmall.widthBox,
            itemBuilder: (context, index) => _QuickPick(
              reference: references[index],
              onTap: () => onPicked(references[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickPick extends StatelessWidget {
  const _QuickPick({required this.reference, required this.onTap});

  final MusicReference reference;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: reference.name,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: Container(
          constraints: BoxConstraints(maxWidth: 180.w),
          padding: EdgeInsets.only(
            left: Sp.xsmall.w,
            right: Sp.medium.w,
            top: Sp.xsmall.h,
            bottom: Sp.xsmall.h,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: Sp.huge.radiusR,
            border: Border.all(color: context.colors.borderSecondary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Sp.xsmall.w,
            children: [
              ReferenceAvatar(reference: reference, size: Sp.xlarge.r + 4),
              Flexible(
                child: Text(
                  reference.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: listTitleStyle(
                    context,
                  ).copyWith(color: context.colors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
