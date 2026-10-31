part of 'reference_search_cubit.dart';

enum SearchStatus { idle, loading, ready, failure }

class ReferenceSearchState extends Equatable {
  const ReferenceSearchState({
    this.query = '',
    this.results = const [],
    this.status = SearchStatus.idle,
  });

  final String query;
  final List<MusicReference> results;
  final SearchStatus status;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get isEmptyResult =>
      status == SearchStatus.ready && hasQuery && results.isEmpty;

  ReferenceSearchState copyWith({
    List<MusicReference>? results,
    SearchStatus? status,
  }) {
    return ReferenceSearchState(
      query: query,
      results: results ?? this.results,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [query, results, status];
}
