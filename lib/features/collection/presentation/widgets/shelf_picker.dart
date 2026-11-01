import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/widgets/app_bottom_sheet.dart';
import 'package:music_disco/core/widgets/app_dialog.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';

part 'shelf_name_dialog.dart';

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
      padding: Sp.s20.padAllR,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: sheetTitleStyle(context)),
          Sp.s8.heightBox,
          Text(
            hint,
            style: bodyTextStyle(
              context,
            ).copyWith(color: context.colors.textSecondary),
          ),
          Sp.s12.heightBox,
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
