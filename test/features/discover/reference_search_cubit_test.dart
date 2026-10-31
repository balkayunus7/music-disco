import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_disco/features/discover/bloc/reference_search_cubit.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_reference_catalog.dart';

const _saved = MusicReference(id: 'duman', name: 'Duman', mood: Mood.turnItUp);
const _updated = MusicReference(
  id: 'duman',
  name: 'Duman',
  mood: Mood.turnItUp,
  imageUrl: 'https://example.com/duman.jpg',
);

void main() {
  test('refreshes saved artist photos while keeping suggestions', () async {
    final details = Completer<List<MusicReference>>();
    final catalog = _Catalog(details: () => details.future);
    final cubit = ReferenceSearchCubit(catalog, debounce: Duration.zero);
    addTearDown(cubit.close);

    final loading = cubit.load(references: [_saved]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.status, SearchStatus.ready);
    expect(cubit.state.resolve(_saved), _saved);

    details.complete([_updated]);
    await loading;
    expect(catalog.requestedIds, {_saved.id});
    expect(cubit.state.results, [_saved]);
    expect(cubit.state.resolve(_saved).imageUrl, _updated.imageUrl);
  });

  test('finishing search does not replace refreshed artist details', () async {
    final search = Completer<List<MusicReference>>();
    final catalog = _Catalog(
      search: (_) => search.future,
      details: () async => [_updated],
    );
    final cubit = ReferenceSearchCubit(catalog, debounce: Duration.zero);
    addTearDown(cubit.close);

    final loading = cubit.load(references: [_saved]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.resolve(_saved), _updated);

    search.complete([_saved]);
    await loading;
    await cubit.updateQuery('Duman');
    expect(cubit.state.query, 'Duman');
    expect(cubit.state.resolve(_saved), _updated);
    expect(cubit.state.status, SearchStatus.ready);
  });

  test('late photo refresh preserves the current search query', () async {
    final details = Completer<List<MusicReference>>();
    final cubit = ReferenceSearchCubit(
      _Catalog(details: () => details.future),
      debounce: Duration.zero,
    );
    addTearDown(cubit.close);

    final loading = cubit.load(references: [_saved]);
    await cubit.updateQuery('Tarkan');
    details.complete([_updated]);
    await loading;

    expect(cubit.state.query, 'Tarkan');
    expect(cubit.state.status, SearchStatus.ready);
    expect(cubit.state.resolve(_saved), _updated);
  });

  test('failed refresh or missing artists preserve saved selections', () async {
    var fail = true;
    final catalog = _Catalog(
      details: () async {
        if (fail) throw StateError('Offline');
        return [];
      },
    );
    final cubit = ReferenceSearchCubit(catalog);
    addTearDown(cubit.close);

    await cubit.load(references: [_saved]);
    expect(cubit.state.status, SearchStatus.ready);
    expect(cubit.state.resolve(_saved), same(_saved));

    fail = false;
    await cubit.retry();
    expect(cubit.state.resolve(_saved), same(_saved));
    expect(cubit.state.results, [_saved]);
  });

  test('closing the page while details load does not emit again', () async {
    final details = Completer<List<MusicReference>>();
    final cubit = ReferenceSearchCubit(_Catalog(details: () => details.future));
    final loading = cubit.load(references: [_saved]);
    await cubit.close();
    details.complete([_updated]);
    await loading;
    expect(cubit.isClosed, isTrue);
  });
}

class _Catalog implements IReferenceCatalog {
  _Catalog({
    Future<List<MusicReference>> Function(String)? search,
    required this.details,
  }) : _search = search ?? ((_) async => [_saved]);

  final Future<List<MusicReference>> Function(String) _search;
  final Future<List<MusicReference>> Function() details;
  Set<String>? requestedIds;

  @override
  Future<List<MusicReference>> search(String query) => _search(query);

  @override
  Future<List<MusicReference>> findByIds(Set<String> ids) {
    requestedIds = ids;
    return details();
  }
}
