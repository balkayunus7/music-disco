import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';

typedef CollectionSnapshot = ({
  List<Track> tracks,
  Map<String, CollectionShelf> shelves,
});

abstract interface class ICollectionStore {
  CollectionSnapshot read();
  Future<void> write(CollectionSnapshot snapshot);
}
