part of '../pages/discover_home_page.dart';

class StudioStartingPoint extends StatelessWidget {
  const StudioStartingPoint({
    super.key,
    required this.genreLabels,
    required this.references,
    required this.onEdit,
  });

  final List<String> genreLabels;
  final List<MusicReference> references;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: Sp.small.w,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  LocaleKeys.studio_taste_title.tr(),
                  style: listTitleStyle(context),
                ),
              ),
            ),
            TextLink(
              text: LocaleKeys.studio_taste_edit.tr(),
              trailingIcon: Icons.edit_outlined,
              onTap: onEdit,
            ),
          ],
        ),
        MotionSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : 280.ms,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: Sp.xsmall.w,
            runSpacing: Sp.xsmall.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final label in genreLabels)
                PillLabel(text: label, isStrong: false, dense: true),
              for (final reference in references)
                _ReferenceTag(reference: reference),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferenceTag extends StatelessWidget {
  const _ReferenceTag({required this.reference});

  final MusicReference reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Sp.tiny.w + 2,
        Sp.tiny.h + 1,
        Sp.small.w,
        Sp.tiny.h + 1,
      ),
      decoration: BoxDecoration(
        borderRadius: Sp.huge.radiusR,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Sp.xsmall.w,
        children: [
          ReferenceAvatar(reference: reference, size: Sp.xlarge.r),
          Flexible(
            child: Text(
              reference.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: listTitleStyle(
                context,
              ).copyWith(color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
