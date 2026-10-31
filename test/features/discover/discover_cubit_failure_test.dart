import 'package:flutter_test/flutter_test.dart';
import 'package:music_disco/features/discover/bloc/discover_cubit.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/track.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_discovery_repository.dart';

void main() {
  test('an empty round reports noResults', () async {
    final cubit = DiscoverCubit(_Repository(() async => const []));
    addTearDown(cubit.close);

    await cubit.startRound();

    expect(cubit.state.status, DiscoverRoundStatus.failure);
    expect(cubit.state.failure, DiscoverFailure.noResults);
  });

  test('a provider error reports unavailable and a retry clears it', () async {
    var shouldFail = true;
    final cubit = DiscoverCubit(
      _Repository(() async {
        if (shouldFail) throw Exception('503');
        return const [];
      }),
    );
    addTearDown(cubit.close);

    await cubit.startRound();
    expect(cubit.state.status, DiscoverRoundStatus.failure);
    expect(cubit.state.failure, DiscoverFailure.unavailable);

    shouldFail = false;
    await cubit.startRound();
    expect(cubit.state.failure, DiscoverFailure.noResults);
  });
}

class _Repository implements IDiscoveryRepository {
  _Repository(this._round);

  final Future<List<Track>> Function() _round;

  @override
  Future<List<Track>> fetchRound(
    DiscoveryPreferences preferences, {
    required int count,
    Set<String> excludeIds = const {},
  }) => _round();

  @override
  Future<Track?> fetchReplacement(
    DiscoveryPreferences preferences, {
    required TrackFeedback feedback,
    required Set<String> excludeIds,
    String? rejectedTrackId,
  }) async => null;
}
