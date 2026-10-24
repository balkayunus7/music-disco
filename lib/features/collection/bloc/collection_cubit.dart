import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';

part 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  CollectionCubit() : super(const CollectionState());

  void save(Track track) {
    if (state.contains(track.id)) return;
    emit(CollectionState(tracks: [...state.tracks, track]));
  }

  void remove(String trackId) {
    if (!state.contains(trackId)) return;
    emit(
      CollectionState(
        tracks: state.tracks.where((track) => track.id != trackId).toList(),
      ),
    );
  }
}
