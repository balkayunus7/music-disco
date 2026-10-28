import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/collection/domain/use_cases/i_collection_store.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';

part 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  CollectionCubit({ICollectionStore? store})
    : _store = store,
      super(_restore(store));

  final ICollectionStore? _store;

  static CollectionState _restore(ICollectionStore? store) {
    final snapshot = store?.read();
    return snapshot == null
        ? const CollectionState()
        : CollectionState(tracks: snapshot.tracks, shelves: snapshot.shelves);
  }

  Future<bool> save(Track track, {CollectionShelf? shelf}) {
    if (state.contains(track.id)) return Future.value(true);
    return _commit(
      state.copyWith(
        tracks: [...state.tracks, track],
        shelves: {...state.shelves, track.id: ?shelf},
      ),
    );
  }

  Future<bool> remove(String trackId) {
    if (!state.contains(trackId)) return Future.value(true);
    return _commit(
      state.copyWith(
        tracks: state.tracks.where((track) => track.id != trackId).toList(),
        shelves: {...state.shelves}..remove(trackId),
      ),
    );
  }

  Future<bool> assignShelf(String trackId, CollectionShelf? shelf) {
    if (!state.contains(trackId)) return Future.value(false);
    if (state.shelves[trackId] == shelf) return Future.value(true);
    final shelves = {...state.shelves};
    if (shelf == null) {
      shelves.remove(trackId);
    } else {
      shelves[trackId] = shelf;
    }
    return _commit(state.copyWith(shelves: shelves));
  }

  Future<bool> _commit(CollectionState next) async {
    if (state.isSaving) return false;
    if (_store != null) {
      emit(state.copyWith(isSaving: true));
      try {
        await _store.write((tracks: next.tracks, shelves: next.shelves));
      } on Object {
        if (!isClosed) emit(state.copyWith(isSaving: false));
        return false;
      }
    }
    if (isClosed) return false;
    emit(next.copyWith(isSaving: false));
    return true;
  }
}
