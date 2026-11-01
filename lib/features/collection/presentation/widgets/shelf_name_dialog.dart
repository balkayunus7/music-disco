part of 'shelf_picker.dart';

Future<String?> showShelfNameDialog(
  BuildContext context, {
  required CollectionState collection,
  CollectionShelf? editing,
}) {
  return showAppDialog<String>(
    context,
    builder: (_) => _ShelfNameDialog(collection: collection, editing: editing),
  );
}

class _ShelfNameDialog extends StatefulWidget {
  const _ShelfNameDialog({required this.collection, required this.editing});
  final CollectionState collection;
  final CollectionShelf? editing;

  @override
  State<_ShelfNameDialog> createState() => _ShelfNameDialogState();
}

class _ShelfNameDialogState extends State<_ShelfNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.editing?.name,
  );
  bool _touched = false;

  static const int _inputSlack = 8;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ShelfNameError? get _error => widget.collection.shelfNameError(
    _controller.text,
    exceptId: widget.editing?.id,
  );

  void _submit() {
    if (_error != null) return;
    Navigator.of(
      context,
    ).pop(CollectionState.normalizeShelfName(_controller.text));
  }

  String? _errorText() {
    if (!_touched) return null;
    return switch (_error) {
      ShelfNameError.taken => LocaleKeys.collection_name_taken.tr(),
      ShelfNameError.tooLong => LocaleKeys.collection_name_too_long.tr(
        args: ['${CollectionState.maxShelfNameLength}'],
      ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    final border = OutlineInputBorder(
      borderRadius: Sp.inputRadius.radiusR,
      borderSide: BorderSide(color: context.colors.border),
    );
    final errorText = _errorText();
    return AppDialogFrame(
      title: isEditing
          ? LocaleKeys.collection_dialog_rename_title.tr()
          : LocaleKeys.collection_dialog_new_title.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: CollectionState.maxShelfNameLength + _inputSlack,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            cursorColor: context.colors.textPrimary,
            style: inputTextStyle(context),
            onChanged: (_) => setState(() => _touched = true),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              counterText: '',
              hintText: LocaleKeys.collection_name_hint.tr(),
              hintStyle: inputTextStyle(
                context,
              ).copyWith(color: context.colors.textDisabled),
              filled: true,
              fillColor: context.colors.surfaceSecondary,
              isDense: true,
              contentPadding: Sp.s16.padHVR(Sp.s16),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(color: context.colors.textSecondary),
              ),
            ),
          ),
          if (errorText != null) ...[
            Sp.s8.heightBox,
            Text(
              errorText,
              style: secondaryTextStyle(
                context,
              ).copyWith(color: context.colors.error),
            ),
          ],
          Sp.s20.heightBox,
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => AppDialogActions(
              confirmLabel: isEditing
                  ? LocaleKeys.collection_rename_confirm.tr()
                  : LocaleKeys.collection_create.tr(),
              onConfirm: _error == null ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }
}
