part of '../pages/taste_page.dart';

class TasteSection extends StatelessWidget {
  const TasteSection({
    super.key,
    required this.title,
    required this.child,
    this.onEdit,
  });

  final String title;
  final Widget child;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final onEdit = this.onEdit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: m18w700(context)),
              ),
            ),
            if (onEdit != null)
              TextLink(
                text: LocaleKeys.taste_edit_action.tr(),
                trailingIcon: Icons.edit_outlined,
                onTap: onEdit,
              ),
          ],
        ),
        Sp.medium.heightBox,
        child,
      ],
    );
  }
}

class TasteDivider extends StatelessWidget {
  const TasteDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Sp.xlarge.padVR,
      child: Divider(height: 1, color: context.colors.borderSecondary),
    );
  }
}
