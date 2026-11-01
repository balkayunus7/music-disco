part of 'taste_cubit.dart';

enum TasteNotice { none, genreLimit, referenceLimit }

class TasteState extends Equatable {
  const TasteState({
    this.saved = const TasteProfile(),
    this.draft = const TasteProfile(),
    this.notice = TasteNotice.none,
    this.isSaving = false,
  });
  final TasteProfile saved;
  final TasteProfile draft;
  final TasteNotice notice;
  final bool isSaving;

  bool get hasChanges => saved != draft;

  TasteState copyWith({
    TasteProfile? saved,
    TasteProfile? draft,
    TasteNotice? notice,
    bool? isSaving,
  }) {
    return TasteState(
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      notice: notice ?? this.notice,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [saved, draft, notice, isSaving];
}
