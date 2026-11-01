import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/genre.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:music_disco/features/taste/domain/use_cases/i_taste_store.dart';

part 'taste_state.dart';

class TasteCubit extends Cubit<TasteState> {
  TasteCubit({ITasteStore? store}) : _store = store, super(_restore(store));
  final ITasteStore? _store;

  static TasteState _restore(ITasteStore? store) {
    final saved = store?.read() ?? const TasteProfile();
    return TasteState(saved: saved, draft: saved);
  }

  void startEditing() {
    if (state.isSaving) return;
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

  Future<bool> save() async {
    if (state.isSaving) return false;
    final draft = state.draft;
    if (_store != null) {
      emit(state.copyWith(isSaving: true));
      try {
        await _store.write(draft);
      } on Object {
        if (!isClosed) emit(state.copyWith(isSaving: false));
        return false;
      }
    }
    if (isClosed) return false;
    emit(TasteState(saved: draft, draft: draft));
    return true;
  }

  void _emitDraft(TasteProfile draft) {
    if (state.isSaving) return;
    emit(state.copyWith(draft: draft, notice: TasteNotice.none));
  }
}
