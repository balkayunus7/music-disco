import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';

typedef CollectionSnapshot = ({
  List<Track> tracks,
  List<CollectionShelf> shelves,
  Map<String, String> assignments,
});

abstract interface class ICollectionStore {
  CollectionSnapshot read();
  Future<void> write(CollectionSnapshot snapshot);
}
