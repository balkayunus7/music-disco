import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/app_bottom_sheet.dart';
import 'package:music_disco/core/widgets/app_dialog.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';

sealed class ShelfPick {
  const ShelfPick();

  String? get existingId => switch (this) {
    ExistingShelfPick(:final shelfId) => shelfId,
    NewShelfPick() => null,
  };

  String? get newName => switch (this) {
    ExistingShelfPick() => null,
    NewShelfPick(:final name) => name,
  };
}

final class ExistingShelfPick extends ShelfPick {
  const ExistingShelfPick(this.shelfId);

  final String? shelfId;
}

final class NewShelfPick extends ShelfPick {
  const NewShelfPick(this.name);

  final String name;
}

Future<ShelfPick?> showShelfPicker(
  BuildContext context, {
  required CollectionState collection,
  String? selectedId,
  String? title,
  String? hint,
}) {
  return showAppBottomSheet<ShelfPick>(
    context,
    builder: (_) => ShelfPickerSheet(
      collection: collection,
      selectedId: selectedId,
      title: title ?? LocaleKeys.collection_save_to.tr(),
      hint: hint ?? LocaleKeys.collection_save_hint.tr(),
    ),
  );
}

class ShelfPickerSheet extends StatelessWidget {
  const ShelfPickerSheet({
    super.key,
    required this.collection,
    required this.selectedId,
    required this.title,
    required this.hint,
  });

  final CollectionState collection;
  final String? selectedId;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: Sp.large.padAllR,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: sheetTitleStyle(context)),
          Sp.xsmall.heightBox,
          Text(
            hint,
            style: bodyTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
          Sp.small.heightBox,
          ShelfOptions(
            collection: collection,
            selectedId: selectedId,
            onPicked: (pick) => Navigator.of(context).pop(pick),
          ),
        ],
      ),
    ),
  );
}

class ShelfOptions extends StatelessWidget {
  const ShelfOptions({
    super.key,
    required this.collection,
    required this.selectedId,
    required this.onPicked,
  });

  final CollectionState collection;
  final String? selectedId;
  final ValueChanged<ShelfPick> onPicked;

  Future<void> _create(BuildContext context) async {
    final name = await showShelfNameDialog(context, collection: collection);
    if (name == null || !context.mounted) return;
    onPicked(NewShelfPick(name));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final shelf in collection.shelves)
          SheetOptionTile(
            label: shelf.name,
            icon: Icons.album_outlined,
            isSelected: shelf.id == selectedId,
            onTap: () => onPicked(ExistingShelfPick(shelf.id)),
          ),
        SheetOptionTile(
          label: LocaleKeys.collection_new.tr(),
          icon: Icons.add_rounded,
          onTap: () => _create(context),
        ),
        SheetOptionTile(
          label: LocaleKeys.collection_no_shelf.tr(),
          icon: Icons.queue_music_rounded,
          isSelected: selectedId == null,
          onTap: () => onPicked(const ExistingShelfPick(null)),
        ),
      ],
    );
  }
}

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
      borderRadius: BorderRadius.circular(Sp.inputRadius),
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
            maxLength: CollectionState.maxShelfNameLength + 8,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            cursorColor: context.colors.textPrimary,
            style: inputTextStyle(context),
            onChanged: (_) => setState(() => _touched = true),
            onSubmitted: (_) => _submit(),
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => null,
            decoration: InputDecoration(
              hintText: LocaleKeys.collection_name_hint.tr(),
              hintStyle: inputTextStyle(
                context,
              ).copyWith(color: context.colors.textDisabled),
              filled: true,
              fillColor: context.colors.surfaceSecondary,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Sp.medium.w,
                vertical: Sp.medium.h,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(color: context.colors.textSecondary),
              ),
            ),
          ),
          if (errorText != null) ...[
            Sp.xsmall.heightBox,
            Text(
              errorText,
              style: secondaryTextStyle(
                context,
              ).copyWith(color: context.colors.error),
            ),
          ],
          Sp.large.heightBox,
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
