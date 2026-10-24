part of 'collection_cubit.dart';

class CollectionState extends Equatable {
  const CollectionState({this.tracks = const []});

  /// Saved tracks in the order they were saved.
  final List<Track> tracks;

  int get count => tracks.length;
  bool get isEmpty => tracks.isEmpty;
  bool contains(String trackId) => tracks.any((track) => track.id == trackId);

  @override
  List<Object?> get props => [tracks];
}
