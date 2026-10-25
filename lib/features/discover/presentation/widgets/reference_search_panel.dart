part of '../pages/reference_page.dart';

class ReferenceSearchPanel extends StatelessWidget {
  const ReferenceSearchPanel({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedId,
    required this.onPicked,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? selectedId;
  final ValueChanged<MusicReference> onPicked;

  @override
  Widget build(BuildContext context) {
    final savedReferences = context.select<TasteCubit, List<MusicReference>>((cubit) => cubit.state.saved.references);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchField(
          controller: controller,
          focusNode: focusNode,
          hint: LocaleKeys.search_hint.tr(),
          clearLabel: LocaleKeys.search_clear.tr(),
          onChanged: context.read<ReferenceSearchCubit>().updateQuery,
        ),
        Sp.small.heightBox,
        BlocBuilder<ReferenceSearchCubit, ReferenceSearchState>(
          builder: (context, search) {
            final references = !search.hasQuery && savedReferences.isNotEmpty ? savedReferences : search.results;
            final message = switch (search) {
              ReferenceSearchState(status: SearchStatus.failure) => LocaleKeys.search_error.tr(),
              ReferenceSearchState(isEmptyResult: true) => LocaleKeys.search_no_results.tr(),
              _ => null,
            };
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final reference in references)
                  ReferenceRow(
                    key: ValueKey(reference.id),
                    reference: reference,
                    hasDivider: true,
                    isSelected: reference.id == selectedId,
                    semanticLabel: reference.name,
                    onTap: () => onPicked(reference),
                    trailing: ReferenceToggleMark(isSelected: reference.id == selectedId),
                  ),
                if (message != null)
                  Padding(
                    padding: Sp.medium.padVR,
                    child: Text(message, style: m13w500(context).copyWith(color: context.colors.textSecondary)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
