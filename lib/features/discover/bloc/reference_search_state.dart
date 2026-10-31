part of 'reference_search_cubit.dart';

enum SearchStatus { idle, loading, ready, failure }

class ReferenceSearchState extends Equatable {
  const ReferenceSearchState({
    this.query = '',
    this.results = const [],
    this.status = SearchStatus.idle,
    this.catalogReferences = const {},
  });

  final String query;
  final List<MusicReference> results;
  final SearchStatus status;
  final Map<String, MusicReference> catalogReferences;

  MusicReference resolve(MusicReference reference) =>
      catalogReferences[reference.id] ?? reference;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get isEmptyResult =>
      status == SearchStatus.ready && hasQuery && results.isEmpty;

  ReferenceSearchState copyWith({
    String? query,
    List<MusicReference>? results,
    SearchStatus? status,
    Map<String, MusicReference>? catalogReferences,
  }) {
    return ReferenceSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      status: status ?? this.status,
      catalogReferences: catalogReferences ?? this.catalogReferences,
    );
  }

  @override
  List<Object?> get props => [query, results, status, catalogReferences];
}
