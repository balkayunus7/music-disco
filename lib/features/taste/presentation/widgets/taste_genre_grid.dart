part of '../pages/taste_genres_page.dart';

class TasteGenreGrid extends StatelessWidget {
  const TasteGenreGrid({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<Genre> selected;
  final ValueChanged<Genre> onToggle;

  static const int _columns = 2;

  @override
  Widget build(BuildContext context) {
    const genres = Genre.values;
    return Column(
      spacing: Sp.xsmall.h,
      children: [
        for (var i = 0; i < genres.length; i += _columns)
          Row(
            spacing: Sp.xsmall.w,
            children: [
              for (final genre in genres.skip(i).take(_columns))
                Expanded(
                  child: ChoiceTile(
                    label: genre.labelKey.tr(),
                    hasIndicator: true,
                    isSelected: selected.contains(genre),
                    onTap: () => onToggle(genre),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
