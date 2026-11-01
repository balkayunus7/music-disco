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
          spacing: Sp.s12.w,
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
        AdaptiveAnimatedSize(
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: Sp.s8.w,
            runSpacing: Sp.s8.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final label in genreLabels)
                PillLabel(text: label, isStrong: false),
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
        Sp.s4.w + 2,
        Sp.s4.h + 1,
        Sp.s12.w,
        Sp.s4.h + 1,
      ),
      decoration: BoxDecoration(
        borderRadius: Sp.s64.radiusR,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Sp.s8.w,
        children: [
          ReferenceAvatar(reference: reference, size: Sp.s24.r),
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
