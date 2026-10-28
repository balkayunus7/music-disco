part of 'collection_cubit.dart';

class CollectionState extends Equatable {
  const CollectionState({
    this.tracks = const [],
    this.shelves = const {},
    this.isSaving = false,
  });

  final bool isSaving;
  final List<Track> tracks;
  final Map<String, CollectionShelf> shelves;

  int get count => tracks.length;
  int countOf(List<Track> round) =>
      round.where((track) => contains(track.id)).length;
  int get shelfCount => shelves.values.toSet().length;
  bool get isEmpty => tracks.isEmpty;
  bool contains(String trackId) => tracks.any((track) => track.id == trackId);

  List<Track> tracksIn(CollectionShelf? shelf) => shelf == null
      ? tracks
      : tracks.where((track) => shelves[track.id] == shelf).toList();

  CollectionState copyWith({
    bool? isSaving,
    List<Track>? tracks,
    Map<String, CollectionShelf>? shelves,
  }) {
    return CollectionState(
      isSaving: isSaving ?? this.isSaving,
      tracks: tracks ?? this.tracks,
      shelves: shelves ?? this.shelves,
    );
  }

  @override
  List<Object?> get props => [tracks, shelves, isSaving];
}
