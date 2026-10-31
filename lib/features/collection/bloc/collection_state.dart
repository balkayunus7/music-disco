part of 'collection_cubit.dart';

enum ShelfNameError { empty, tooLong, taken }

class CollectionState extends Equatable {
  const CollectionState({
    this.tracks = const [],
    this.shelves = const [],
    this.assignments = const {},
    this.isSaving = false,
  });

  static const int maxShelfNameLength = 24;

  final bool isSaving;
  final List<Track> tracks;
  final List<CollectionShelf> shelves;
  final Map<String, String> assignments;

  int get count => tracks.length;
  int countOf(List<Track> round) =>
      round.where((track) => contains(track.id)).length;
  int get shelfCount => shelves.length;
  bool get isEmpty => tracks.isEmpty;
  bool contains(String trackId) => tracks.any((track) => track.id == trackId);

  static String normalizeShelfName(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ');

  CollectionShelf? shelfById(String? id) =>
      shelves.where((shelf) => shelf.id == id).firstOrNull;

  CollectionShelf? shelfOf(String trackId) => shelfById(assignments[trackId]);

  CollectionShelf? shelfNamed(String name) {
    final key = normalizeShelfName(name).toLowerCase();
    return shelves
        .where((shelf) => shelf.name.toLowerCase() == key)
        .firstOrNull;
  }

  ShelfNameError? shelfNameError(String name, {String? exceptId}) {
    final normalized = normalizeShelfName(name);
    if (normalized.isEmpty) return ShelfNameError.empty;
    if (normalized.length > maxShelfNameLength) return ShelfNameError.tooLong;
    final existing = shelfNamed(normalized);
    if (existing != null && existing.id != exceptId) {
      return ShelfNameError.taken;
    }
    return null;
  }

  List<Track> tracksIn(String? shelfId) => shelfId == null
      ? tracks
      : tracks.where((track) => assignments[track.id] == shelfId).toList();

  List<Track> recentIn(String? shelfId) => tracksIn(shelfId).reversed.toList();

  int countIn(String? shelfId) => tracksIn(shelfId).length;

  CollectionState copyWith({
    bool? isSaving,
    List<Track>? tracks,
    List<CollectionShelf>? shelves,
    Map<String, String>? assignments,
  }) {
    return CollectionState(
      isSaving: isSaving ?? this.isSaving,
      tracks: tracks ?? this.tracks,
      shelves: shelves ?? this.shelves,
      assignments: assignments ?? this.assignments,
    );
  }

  @override
  List<Object?> get props => [tracks, shelves, assignments, isSaving];
}
