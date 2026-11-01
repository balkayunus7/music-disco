import 'dart:async';

import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/collection/domain/models/collection_shelf.dart';
import 'package:music_disco/features/collection/domain/use_cases/i_collection_store.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_feedback_repository.dart';

part 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  CollectionCubit({
    ICollectionStore? store,
    String Function()? idGenerator,
    IDiscoveryFeedbackRepository? feedbackRepository,
    bool Function()? canRecordFeedback,
  }) : _store = store,
       _feedbackRepository = feedbackRepository,
       _canRecordFeedback = canRecordFeedback,
       _idGenerator = idGenerator ?? _timeId,
       super(_restore(store));

  final ICollectionStore? _store;
  final IDiscoveryFeedbackRepository? _feedbackRepository;
  final bool Function()? _canRecordFeedback;
  final String Function() _idGenerator;
  Future<void> _feedbackWrites = Future.value();

  static String _timeId() => 'shelf_${DateTime.now().microsecondsSinceEpoch}';

  static CollectionState _restore(ICollectionStore? store) {
    final snapshot = store?.read();
    return snapshot == null
        ? const CollectionState()
        : CollectionState(
            tracks: snapshot.tracks,
            shelves: snapshot.shelves,
            assignments: snapshot.assignments,
          );
  }

  String _newId() {
    var id = _idGenerator();
    while (state.shelves.any((shelf) => shelf.id == id)) {
      id = '${id}_';
    }
    return id;
  }

  ({List<CollectionShelf> shelves, String? id})? _resolveShelf({
    String? shelfId,
    String? newShelfName,
  }) {
    if (newShelfName == null) {
      return (shelves: state.shelves, id: state.shelfById(shelfId)?.id);
    }
    final name = CollectionState.normalizeShelfName(newShelfName);
    final existing = state.shelfNamed(name);
    if (existing != null) return (shelves: state.shelves, id: existing.id);
    if (state.shelfNameError(name) != null) return null;
    final shelf = CollectionShelf(id: _newId(), name: name);
    return (shelves: [...state.shelves, shelf], id: shelf.id);
  }

  Future<bool> save(
    Track track, {
    String? shelfId,
    String? newShelfName,
  }) async {
    if (state.contains(track.id)) return true;
    final target = _resolveShelf(shelfId: shelfId, newShelfName: newShelfName);
    if (target == null) return false;
    final saved = await _commit(
      state.copyWith(
        tracks: [...state.tracks, track],
        shelves: target.shelves,
        assignments: {...state.assignments, track.id: ?target.id},
      ),
    );
    if (saved) _recordSaved(track.id, true);
    return saved;
  }

  Future<bool> remove(String trackId) async {
    if (!state.contains(trackId)) return true;
    final removed = await _commit(
      state.copyWith(
        tracks: state.tracks.where((track) => track.id != trackId).toList(),
        assignments: {...state.assignments}..remove(trackId),
      ),
    );
    if (removed) _recordSaved(trackId, false);
    return removed;
  }

  void _recordSaved(String trackId, bool isSaved) {
    _feedbackWrites = _feedbackWrites.then((_) async {
      if (_canRecordFeedback?.call() == false) return;
      try {
        await _feedbackRepository?.recordSaved(trackId, isSaved: isSaved);
      } on Object {
        return;
      }
    });
    unawaited(_feedbackWrites);
  }

  Future<bool> assignShelf(
    String trackId, {
    String? shelfId,
    String? newShelfName,
  }) {
    if (!state.contains(trackId)) return Future.value(false);
    final target = _resolveShelf(shelfId: shelfId, newShelfName: newShelfName);
    if (target == null) return Future.value(false);
    if (state.assignments[trackId] == target.id &&
        target.shelves == state.shelves) {
      return Future.value(true);
    }
    final assignments = {...state.assignments};
    if (target.id == null) {
      assignments.remove(trackId);
    } else {
      assignments[trackId] = target.id!;
    }
    return _commit(
      state.copyWith(shelves: target.shelves, assignments: assignments),
    );
  }

  Future<CollectionShelf?> createShelf(String name) async {
    final target = _resolveShelf(newShelfName: name);
    final id = target?.id;
    if (target == null || id == null) return null;
    final shelf = target.shelves.firstWhere((shelf) => shelf.id == id);
    if (target.shelves == state.shelves) return shelf;
    return await _commit(state.copyWith(shelves: target.shelves))
        ? shelf
        : null;
  }

  Future<bool> renameShelf(String id, String name) {
    final shelf = state.shelfById(id);
    final normalized = CollectionState.normalizeShelfName(name);
    if (shelf == null ||
        state.shelfNameError(normalized, exceptId: id) != null) {
      return Future.value(false);
    }
    if (shelf.name == normalized) return Future.value(true);
    return _commit(
      state.copyWith(
        shelves: [
          for (final item in state.shelves)
            item.id == id ? CollectionShelf(id: id, name: normalized) : item,
        ],
      ),
    );
  }

  Future<bool> deleteShelf(String id) {
    if (state.shelfById(id) == null) return Future.value(true);
    return _commit(
      state.copyWith(
        shelves: state.shelves.where((shelf) => shelf.id != id).toList(),
        assignments: {
          for (final entry in state.assignments.entries)
            if (entry.value != id) entry.key: entry.value,
        },
      ),
    );
  }

  Future<bool> _commit(CollectionState next) async {
    if (state.isSaving) return false;
    if (_store != null) {
      emit(state.copyWith(isSaving: true));
      try {
        await _store.write((
          tracks: next.tracks,
          shelves: next.shelves,
          assignments: next.assignments,
        ));
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
