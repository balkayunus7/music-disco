import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/taste/domain/models/genre.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';

part 'taste_state.dart';

class TasteCubit extends Cubit<TasteState> {
  TasteCubit() : super(const TasteState());

  void startEditing() {
    emit(TasteState(saved: state.saved, draft: state.saved));
  }

  void dismissNotice() {
    if (state.notice == TasteNotice.none) return;
    emit(state.copyWith(notice: TasteNotice.none));
  }

  void toggleGenre(Genre genre) {
    final draft = state.draft;
    if (draft.genres.contains(genre)) {
      final genres = draft.genres.where((g) => g != genre).toList();
      _emitDraft(draft.copyWith(genres: genres));
      return;
    }
    if (draft.isGenreFull) {
      emit(state.copyWith(notice: TasteNotice.genreLimit));
      return;
    }
    final genres = [...draft.genres, genre]
      ..sort((a, b) => a.index.compareTo(b.index));
    _emitDraft(draft.copyWith(genres: genres, isMixed: false));
  }

  void toggleMixed() {
    final draft = state.draft;
    _emitDraft(
      draft.isMixed
          ? draft.copyWith(isMixed: false)
          : draft.copyWith(isMixed: true, genres: const []),
    );
  }

  void toggleReference(MusicReference reference) {
    final draft = state.draft;
    if (draft.hasReference(reference.id)) {
      removeReference(reference.id);
      return;
    }
    if (draft.isReferenceFull) {
      emit(state.copyWith(notice: TasteNotice.referenceLimit));
      return;
    }
    _emitDraft(draft.copyWith(references: [...draft.references, reference]));
  }

  void removeReference(String id) {
    final draft = state.draft;
    _emitDraft(
      draft.copyWith(
        references: draft.references.where((r) => r.id != id).toList(),
      ),
    );
  }

  void selectLanguage(MusicLanguage language) {
    _emitDraft(state.draft.copyWith(language: language));
  }

  void save() {
    emit(TasteState(saved: state.draft, draft: state.draft));
  }

  void _emitDraft(TasteProfile draft) {
    emit(state.copyWith(draft: draft, notice: TasteNotice.none));
  }
}
