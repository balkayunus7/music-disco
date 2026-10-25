import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/use_cases/i_reference_catalog.dart';

class MockReferenceCatalog implements IReferenceCatalog {
  MockReferenceCatalog({this.latency = const Duration(milliseconds: 180)});

  final Duration latency;

  static const int resultLimit = 6;

  static const jamesBlake = MusicReference(
    id: 'artist-james-blake',
    name: 'James Blake',
    kind: ReferenceKind.artist,
    mood: Mood.oldFeeling,
  );
  static const bonobo = MusicReference(
    id: 'artist-bonobo',
    name: 'Bonobo',
    kind: ReferenceKind.artist,
    mood: Mood.afterHours,
  );
  static const parcels = MusicReference(
    id: 'artist-parcels',
    name: 'Parcels',
    kind: ReferenceKind.artist,
    mood: Mood.turnItUp,
  );
  static const menITrust = MusicReference(
    id: 'artist-men-i-trust',
    name: 'Men I Trust',
    kind: ReferenceKind.artist,
    mood: Mood.softSide,
  );
  static const khruangbin = MusicReference(
    id: 'artist-khruangbin',
    name: 'Khruangbin',
    kind: ReferenceKind.artist,
    mood: Mood.slowDown,
  );
  static const kerala = MusicReference(
    id: 'song-kerala',
    name: 'Kerala',
    artist: 'Bonobo',
    kind: ReferenceKind.song,
    mood: Mood.afterHours,
  );
  static const tieduprightnow = MusicReference(
    id: 'song-tieduprightnow',
    name: 'Tieduprightnow',
    artist: 'Parcels',
    kind: ReferenceKind.song,
    mood: Mood.turnItUp,
  );
  static const aWalk = MusicReference(
    id: 'song-a-walk',
    name: 'A Walk',
    artist: 'Tycho',
    kind: ReferenceKind.song,
    mood: Mood.oldFeeling,
  );
  static const showMeHow = MusicReference(
    id: 'song-show-me-how',
    name: 'Show Me How',
    artist: 'Men I Trust',
    kind: ReferenceKind.song,
    mood: Mood.softSide,
  );

  static const List<MusicReference> catalog = [
    jamesBlake,
    bonobo,
    parcels,
    menITrust,
    khruangbin,
    MusicReference(
      id: 'artist-tycho',
      name: 'Tycho',
      kind: ReferenceKind.artist,
      mood: Mood.oldFeeling,
    ),
    MusicReference(
      id: 'artist-lana-del-rey',
      name: 'Lana Del Rey',
      kind: ReferenceKind.artist,
      mood: Mood.softSide,
    ),
    MusicReference(
      id: 'artist-duman',
      name: 'Duman',
      kind: ReferenceKind.artist,
      mood: Mood.noRules,
    ),
    MusicReference(
      id: 'artist-madrigal',
      name: 'Madrigal',
      kind: ReferenceKind.artist,
      mood: Mood.afterHours,
    ),
    kerala,
    tieduprightnow,
    aWalk,
    showMeHow,
    MusicReference(
      id: 'song-friday-morning',
      name: 'Friday Morning',
      artist: 'Khruangbin',
      kind: ReferenceKind.song,
      mood: Mood.slowDown,
    ),
    MusicReference(
      id: 'song-retrograde',
      name: 'Retrograde',
      artist: 'James Blake',
      kind: ReferenceKind.song,
      mood: Mood.noRules,
    ),
  ];

  static const List<MusicReference> _featuredArtists = [
    bonobo,
    parcels,
    menITrust,
    khruangbin,
  ];
  static const List<MusicReference> _featuredSongs = [
    kerala,
    tieduprightnow,
    aWalk,
    showMeHow,
  ];
  static const List<MusicReference> _featuredMixed = [
    jamesBlake,
    kerala,
    tieduprightnow,
  ];

  @override
  Future<List<MusicReference>> search(
    String query, {
    ReferenceKind? kind,
  }) async {
    await Future<void>.delayed(latency);
    final needle = _fold(query.trim());
    if (needle.isEmpty) {
      return switch (kind) {
        ReferenceKind.artist => _featuredArtists,
        ReferenceKind.song => _featuredSongs,
        null => _featuredMixed,
      };
    }
    return catalog
        .where((reference) => kind == null || reference.kind == kind)
        .where(
          (reference) =>
              _fold(reference.name).contains(needle) ||
              _fold(reference.artist ?? '').contains(needle),
        )
        .take(resultLimit)
        .toList();
  }

  static String _fold(String value) => value
      .replaceAll('İ', 'i')
      .replaceAll('I', 'i')
      .toLowerCase()
      .replaceAll('ı', 'i');
}
