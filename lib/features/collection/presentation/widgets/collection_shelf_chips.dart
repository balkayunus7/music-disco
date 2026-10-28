part of '../pages/collection_page.dart';

class CollectionShelfChips extends StatelessWidget {
  const CollectionShelfChips({
    super.key,
    required this.collection,
    required this.selected,
    required this.onSelected,
  });

  final CollectionState collection;
  final CollectionShelf? selected;
  final ValueChanged<CollectionShelf?> onSelected;

  static String _labelKey(CollectionShelf? shelf) => switch (shelf) {
    null => LocaleKeys.collection_all,
    CollectionShelf.nightWalk => LocaleKeys.shelf_night_walk,
    CollectionShelf.slowMornings => LocaleKeys.shelf_slow_mornings,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Sp.xsmall.w,
      runSpacing: Sp.xsmall.h,
      children: [
        for (final shelf in <CollectionShelf?>[null, ...CollectionShelf.values])
          ChoiceTile(
            label: _labelKey(
              shelf,
            ).tr(args: ['${collection.tracksIn(shelf).length}']),
            isExpanded: false,
            isSelected: shelf == selected,
            onTap: () => onSelected(shelf),
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
