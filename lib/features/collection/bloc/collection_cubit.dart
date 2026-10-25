import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';

part 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  CollectionCubit() : super(const CollectionState());

  void save(Track track) {
    if (state.contains(track.id)) return;
    emit(state.copyWith(tracks: [...state.tracks, track]));
  }

  void remove(String trackId) {
    if (!state.contains(trackId)) return;
    emit(
      state.copyWith(
        tracks: state.tracks.where((track) => track.id != trackId).toList(),
        shelves: {...state.shelves}..remove(trackId),
      ),
    );
  }

  void assignShelf(String trackId, CollectionShelf? shelf) {
    if (!state.contains(trackId) || state.shelves[trackId] == shelf) return;
    final shelves = {...state.shelves};
    if (shelf == null) {
      shelves.remove(trackId);
    } else {
      shelves[trackId] = shelf;
    }
    emit(state.copyWith(shelves: shelves));
  }
}
