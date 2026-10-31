import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_reference_catalog.dart';

part 'reference_search_state.dart';

class ReferenceSearchCubit extends Cubit<ReferenceSearchState> {
  ReferenceSearchCubit(
    this._catalog, {
    this.debounce = const Duration(milliseconds: 300),
  }) : super(const ReferenceSearchState());

  final IReferenceCatalog _catalog;
  final Duration debounce;

  int _request = 0;
  Set<String> _referenceIds = const {};
  int _refreshRequest = 0;

  Future<void> load({Iterable<MusicReference> references = const []}) async {
    _referenceIds = {for (final reference in references) reference.id};
    await Future.wait([_search(state.query), _refreshReferences()]);
  }

  Future<void> retry() async {
    await Future.wait([_search(state.query), _refreshReferences()]);
  }

  Future<void> _refreshReferences() async {
    final request = ++_refreshRequest;
    if (_referenceIds.isEmpty) return;
    try {
      final references = await _catalog.findByIds(_referenceIds);
      if (isClosed || request != _refreshRequest) return;
      emit(
        state.copyWith(
          catalogReferences: Map.unmodifiable({
            ...state.catalogReferences,
            for (final reference in references) reference.id: reference,
          }),
        ),
      );
    } on Object {
      // Saved artists stay available when catalog details cannot be refreshed.
    }
  }

  Future<void> updateQuery(String query) {
    if (query == state.query) return Future.value();
    return _search(query, debounced: true);
  }

  Future<void> _search(String query, {bool debounced = false}) async {
    final request = ++_request;
    emit(state.copyWith(query: query, status: SearchStatus.loading));
    if (debounced && debounce > Duration.zero) {
      await Future<void>.delayed(debounce);
      if (isClosed || request != _request) return;
    }
    try {
      final results = await _catalog.search(query);
      if (isClosed || request != _request) return;
      emit(state.copyWith(results: results, status: SearchStatus.ready));
    } on Object {
      if (isClosed || request != _request) return;
      emit(state.copyWith(results: const [], status: SearchStatus.failure));
    }
  }
}
