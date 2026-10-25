part of 'taste_cubit.dart';

enum TasteNotice { none, genreLimit, referenceLimit }

class TasteState extends Equatable {
  const TasteState({
    this.saved = const TasteProfile(),
    this.draft = const TasteProfile(),
    this.notice = TasteNotice.none,
  });

  final TasteProfile saved;
  final TasteProfile draft;
  final TasteNotice notice;

  bool get hasChanges => saved != draft;

  TasteState copyWith({
    TasteProfile? saved,
    TasteProfile? draft,
    TasteNotice? notice,
  }) {
    return TasteState(
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      notice: notice ?? this.notice,
    );
  }

  @override
  List<Object?> get props => [saved, draft, notice];
}
