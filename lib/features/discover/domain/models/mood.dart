enum Mood {
  afterHours(discTitle: 'AFTER HOURS', collectionNumber: 1),
  turnItUp(discTitle: 'TURN IT UP', collectionNumber: 2),
  softSide(discTitle: 'SOFT SIDE', collectionNumber: 3),
  slowDown(discTitle: 'SLOW DOWN', collectionNumber: 4),
  oldFeeling(discTitle: 'OLD FEELING', collectionNumber: 5),
  noRules(discTitle: 'NO RULES', collectionNumber: 6);

  const Mood({required this.discTitle, required this.collectionNumber});
  final String discTitle;
  final int collectionNumber;
}
