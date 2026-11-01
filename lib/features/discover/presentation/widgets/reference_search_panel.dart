part of '../pages/reference_page.dart';

class ReferenceSearchPanel extends StatelessWidget {
  const ReferenceSearchPanel({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selected,
    required this.onPicked,
    this.autofocus = false,
    this.onCancel,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final MusicReference? selected;
  final bool autofocus;
  final ValueChanged<MusicReference> onPicked;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final savedReferences = context.select<TasteCubit, List<MusicReference>>(
      (cubit) => cubit.state.saved.references,
    );
    final onCancel = this.onCancel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: Sp.s12.w,
          children: [
            Expanded(
              child: SearchField(
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                hint: LocaleKeys.search_hint.tr(),
                clearLabel: LocaleKeys.search_clear.tr(),
                onChanged: context.read<ReferenceSearchCubit>().updateQuery,
              ),
            ),
            if (onCancel != null)
              TextLink(text: LocaleKeys.reference_cancel.tr(), onTap: onCancel),
          ],
        ),
        Sp.s12.heightBox,
        BlocBuilder<ReferenceSearchCubit, ReferenceSearchState>(
          builder: (context, search) {
            final message = switch (search) {
              ReferenceSearchState(status: SearchStatus.failure) =>
                LocaleKeys.search_error.tr(),
              ReferenceSearchState(isEmptyResult: true) =>
                LocaleKeys.search_no_results.tr(),
              _ => null,
            };
            final selectedId = selected?.id;
            final pinned = !search.hasQuery && selected != null
                ? [selected!]
                : const <MusicReference>[];
            final taken = {for (final reference in pinned) reference.id};
            final saved = !search.hasQuery
                ? [
                    for (final reference in savedReferences)
                      if (taken.add(reference.id)) search.resolve(reference),
                  ]
                : const <MusicReference>[];
            final results = [
              for (final reference in search.results)
                if (search.hasQuery || taken.add(reference.id)) reference,
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 4,
                  child: search.status == SearchStatus.loading
                      ? LinearProgressIndicator(
                          color: context.colors.primary,
                          backgroundColor: context.colors.borderSecondary,
                        )
                      : null,
                ),
                _ReferenceSection(
                  references: pinned,
                  selectedId: selectedId,
                  onPicked: onPicked,
                ),
                _ReferenceSection(
                  title: LocaleKeys.reference_saved_title.tr(),
                  references: saved,
                  selectedId: selectedId,
                  onPicked: onPicked,
                ),
                _ReferenceSection(
                  title: search.hasQuery
                      ? null
                      : LocaleKeys.reference_suggested_title.tr(),
                  references: results,
                  selectedId: selectedId,
                  onPicked: onPicked,
                ),
                if (message != null)
                  Padding(
                    padding: Sp.s16.padVR,
                    child: Text(
                      message,
                      style: bodyTextStyle(
                        context,
                      ).copyWith(color: context.colors.textSecondary),
                    ),
                  ),
                if (search.status == SearchStatus.failure)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextLink(
                      text: LocaleKeys.retry.tr(),
                      trailingIcon: Icons.refresh_rounded,
                      onTap: context.read<ReferenceSearchCubit>().retry,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ReferenceSection extends StatelessWidget {
  const _ReferenceSection({
    required this.references,
    required this.selectedId,
    required this.onPicked,
    this.title,
  });
  final String? title;
  final List<MusicReference> references;
  final String? selectedId;
  final ValueChanged<MusicReference> onPicked;

  @override
  Widget build(BuildContext context) {
    if (references.isEmpty) return const SizedBox.shrink();
    final title = this.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(top: Sp.s16.h, bottom: Sp.s8.h),
            child: Text(title, style: sectionTitleStyle(context)),
          ),
        for (final reference in references)
          ReferenceRow(
            key: ValueKey(reference.id),
            reference: reference,
            hasDivider: true,
            isSelected: reference.id == selectedId,
            semanticLabel: reference.name,
            onTap: () => onPicked(reference),
            trailing: ReferenceToggleMark(
              isSelected: reference.id == selectedId,
            ),
          ),
      ],
    );
  }
}
