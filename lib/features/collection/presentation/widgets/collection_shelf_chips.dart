part of '../pages/collection_page.dart';

class CollectionShelfChips extends StatelessWidget {
  const CollectionShelfChips({
    super.key,
    required this.collection,
    required this.selectedId,
    required this.onSelected,
    required this.onCreate,
  });

  final CollectionState collection;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Sp.xsmall.w,
      runSpacing: Sp.xsmall.h,
      children: [
        ChoiceTile(
          label: LocaleKeys.collection_all.tr(args: ['${collection.count}']),
          isExpanded: false,
          isSelected: selectedId == null,
          onTap: () => onSelected(null),
        ),
        for (final shelf in collection.shelves)
          ChoiceTile(
            key: ValueKey(shelf.id),
            label: '${shelf.name} · ${collection.countIn(shelf.id)}',
            isExpanded: false,
            isSelected: shelf.id == selectedId,
            onTap: () => onSelected(shelf.id),
          ),
        ChoiceTile(
          label: LocaleKeys.collection_new.tr(),
          icon: Icons.add_rounded,
          isExpanded: false,
          isSelected: false,
          onTap: onCreate,
        ),
      ],
    );
  }
}

class CollectionShelfActions extends StatelessWidget {
  const CollectionShelfActions({
    super.key,
    required this.onRename,
    required this.onDelete,
  });

  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Sp.medium.w,
      children: [
        TextLink(
          text: LocaleKeys.collection_rename.tr(),
          trailingIcon: Icons.edit_outlined,
          onTap: onRename,
        ),
        TextLink(
          text: LocaleKeys.collection_delete.tr(),
          trailingIcon: Icons.delete_outline_rounded,
          onTap: onDelete,
        ),
      ],
    );
  }
}

class CollectionShelfEmptyView extends StatelessWidget {
  const CollectionShelfEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: context.colors.border,
        radius: Sp.large.r,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Sp.xlarge.w,
          vertical: Sp.huge.h,
        ),
        child: Text(
          LocaleKeys.collection_shelf_empty.tr(),
          textAlign: TextAlign.center,
          style: bodyTextStyle(
            context,
          ).copyWith(color: context.colors.textSecondary),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          Radius.circular(radius),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
