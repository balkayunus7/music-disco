part of '../pages/settings_page.dart';

class SettingsChoiceSheet<T> extends StatelessWidget {
  const SettingsChoiceSheet({
    super.key,
    required this.title,
    required this.selected,
    required this.options,
  });
  final String title;
  final T selected;
  final Map<T, String> options;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: Sp.large.padAllR,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: sheetTitleStyle(context)),
          Sp.large.heightBox,
          for (final option in options.entries)
            SheetOptionTile(
              label: option.value,
              isSelected: option.key == selected,
              onTap: () => Navigator.of(context).pop(option.key),
            ),
        ],
      ),
    ),
  );
}

class SettingsProfileEditor extends StatefulWidget {
  const SettingsProfileEditor({
    super.key,
    required this.initialName,
    required this.onSave,
  });
  final String initialName;
  final Future<bool> Function(String) onSave;

  @override
  State<SettingsProfileEditor> createState() => _SettingsProfileEditorState();
}

class _SettingsProfileEditorState extends State<SettingsProfileEditor> {
  late final _name = TextEditingController(text: widget.initialName);
  final _form = GlobalKey<FormState>();
  bool _saving = false;
  bool _failed = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    var saved = false;
    try {
      saved = await widget.onSave(_name.text.trim());
    } on Exception {
      saved = false;
    }
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: Sp.large.padAllR.add(
        EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.settings_edit_profile.tr(),
              style: sheetTitleStyle(context),
            ),
            Sp.large.heightBox,
            TextFormField(
              controller: _name,
              enabled: !_saving,
              maxLength: 80,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              style: inputTextStyle(context),
              decoration: InputDecoration(
                constraints: const BoxConstraints(
                  minHeight: Sp.primaryButtonHeight,
                ),
                labelText: LocaleKeys.settings_name.tr(),
                labelStyle: bodyTextStyle(
                  context,
                ).copyWith(color: context.colors.textSecondary),
                filled: true,
                fillColor: context.colors.surfaceSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Sp.inputRadius),
                ),
              ),
              validator: (value) =>
                  MusicUserProperties(name: value ?? '').isValid
                  ? null
                  : LocaleKeys.settings_name_validation.tr(),
              onFieldSubmitted: (_) => _save(),
            ),
            if (_failed) ...[
              Sp.small.heightBox,
              Text(
                LocaleKeys.settings_save_error.tr(),
                style: bodyTextStyle(
                  context,
                ).copyWith(color: context.colors.error),
              ),
            ],
            Sp.large.heightBox,
            FancyButton(
              text: LocaleKeys.settings_save.tr(),
              isLoading: _saving,
              onTap: _save,
            ),
          ],
        ),
      ),
    ),
  );
}
