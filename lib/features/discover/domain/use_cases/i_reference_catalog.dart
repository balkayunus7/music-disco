import 'package:music_disco/features/discover/domain/models/music_reference.dart';

abstract interface class IReferenceCatalog {
  Future<List<MusicReference>> search(String query);
  Future<List<MusicReference>> findByIds(Set<String> ids);
}
