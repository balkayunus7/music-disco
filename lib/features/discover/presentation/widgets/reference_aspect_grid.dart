part of '../pages/reference_page.dart';

class ReferenceAspectGrid extends StatelessWidget {
  const ReferenceAspectGrid({super.key, required this.selected, required this.onSelected});

  final ReferenceAspect selected;
  final ValueChanged<ReferenceAspect> onSelected;

  static const int _columns = 2;

  @override
  Widget build(BuildContext context) {
    const aspects = ReferenceAspect.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Sp.xsmall.h,
      children: [
        for (var i = 0; i < aspects.length; i += _columns)
          Row(
            spacing: Sp.xsmall.w,
            children: [
              for (final aspect in aspects.skip(i).take(_columns))
                Expanded(
                  child: ChoiceTile(
                    label: aspect.labelKey.tr(),
                    isSelected: aspect == selected,
                    onTap: () => onSelected(aspect),
                  ),
                ),
            ],
          ),
        Sp.tiny.heightBox,
        AnimatedSwitcher(
          duration: 240.ms,
          child: Text(
            selected.captionKey.tr(),
            key: ValueKey(selected),
            style: m12w500(context).copyWith(color: context.colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
