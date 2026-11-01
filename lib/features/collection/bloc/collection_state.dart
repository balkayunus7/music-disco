part of 'collection_cubit.dart';

enum ShelfNameError { empty, tooLong, taken }

class CollectionState extends Equatable {
  const CollectionState({
    this.tracks = const [],
    this.shelves = const [],
    this.assignments = const {},
    this.isSaving = false,
  });

  final List<Track> tracks;
  final List<CollectionShelf> shelves;
  final Map<String, String> assignments;
  final bool isSaving;

  static const int maxShelfNameLength = 24;

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

  static String _foldName(String name) => normalizeShelfName(name)
      .replaceAll('İ', 'i')
      .replaceAll('I', 'i')
      .replaceAll('ı', 'i')
      .toLowerCase();

  CollectionShelf? shelfNamed(String name) {
    final key = _foldName(name);
    return shelves.where((shelf) => _foldName(shelf.name) == key).firstOrNull;
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
