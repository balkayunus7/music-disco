import 'package:music_disco/features/discover/data/curated_discovery_repository.dart';

/// Predictable local fixture used by widget tests.
class MockDiscoveryRepository extends CuratedDiscoveryRepository {
  MockDiscoveryRepository({super.latency = Duration.zero});
  static const catalog = CuratedDiscoveryRepository.catalog;
}
