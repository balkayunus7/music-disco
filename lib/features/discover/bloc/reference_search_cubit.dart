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

  Future<void> load({ReferenceKind? kind}) => _search(state.query, kind);

  Future<void> updateQuery(String query) {
    if (query == state.query) return Future.value();
    return _search(query, state.kind, debounced: true);
  }

  Future<void> selectKind(ReferenceKind kind) {
    if (kind == state.kind && state.status != SearchStatus.idle) {
      return Future.value();
    }
    return _search(state.query, kind);
  }

  Future<void> _search(
    String query,
    ReferenceKind? kind, {
    bool debounced = false,
  }) async {
    final request = ++_request;
    emit(
      ReferenceSearchState(
        query: query,
        kind: kind,
        results: state.results,
        status: SearchStatus.loading,
      ),
    );
    if (debounced && debounce > Duration.zero) {
      await Future<void>.delayed(debounce);
      if (isClosed || request != _request) return;
    }
    try {
      final results = await _catalog.search(query, kind: kind);
      if (isClosed || request != _request) return;
      emit(state.copyWith(results: results, status: SearchStatus.ready));
    } on Object {
      if (isClosed || request != _request) return;
      emit(state.copyWith(results: const [], status: SearchStatus.failure));
    }
  }
}
