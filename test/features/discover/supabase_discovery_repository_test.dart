import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:music_disco/features/discover/data/supabase_discovery_repository.dart';
import 'package:music_disco/features/discover/domain/models/discovery_preferences.dart';
import 'package:music_disco/features/discover/domain/models/track_feedback.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/domain/models/taste_profile.dart';
import 'package:supabase/supabase.dart';

Map<String, dynamic> _track({String id = 'abcdefghijk'}) => {
  'id': 'yt:$id',
  'youtubeId': id,
  'title': 'Sil Baştan',
  'artist': 'Şebnem Ferah',
  'mood': 'oldFeeling',
  'genres': ['rock'],
  'language': 'turkish',
  'energy': 0.5,
  'hasVocals': true,
  'durationSeconds': 240,
  'reasons': {'en': 'Reflective rock.', 'tr': 'Düşünceli rock.'},
};

SupabaseDiscoveryRepository _repository(
  Future<http.Response> Function(http.Request) handler,
) {
  final client = SupabaseClient(
    'http://localhost:54321',
    'test-anon-key',
    httpClient: MockClient(handler),
  );
  addTearDown(client.dispose);
  return SupabaseDiscoveryRepository(client);
}

http.Response _response(Object data, {int status = 200}) => http.Response.bytes(
  utf8.encode(jsonEncode(data)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test(
    'sends musical preferences and restores verified tracks/reasons',
    () async {
      final repository = _repository((request) async {
        expect(request.url.path, '/functions/v1/recommend-tracks');
        final body = jsonDecode(request.body);
        expect(body['action'], 'recommend');
        expect(body['count'], 4);
        expect(body['excludeIds'], ['old-track']);
        expect(body['preferences']['taste']['language'], 'turkish');
        expect(body.containsKey('userId'), isFalse);
        return _response({
          'tracks': [_track()],
        });
      });
      final tracks = await repository.fetchRound(
        const DiscoveryPreferences(
          taste: TasteProfile(language: MusicLanguage.turkish),
        ),
        count: 4,
        excludeIds: {'old-track'},
      );
      expect(tracks.single.duration, const Duration(minutes: 4));
      expect(tracks.single.recommendationReason('tr'), 'Düşünceli rock.');
      expect(tracks.single.recommendationReason('de'), 'Reflective rock.');
    },
  );

  test('replacement associates feedback with the rejected song', () async {
    final repository = _repository((request) async {
      final body = jsonDecode(request.body);
      expect(body['feedback'], {
        'trackId': 'yt:abcdefghijk',
        'kind': 'alreadyKnown',
      });
      expect(body['count'], 1);
      return _response({
        'tracks': [_track(id: '12345678901')],
      });
    });
    final track = await repository.fetchReplacement(
      const DiscoveryPreferences(),
      feedback: TrackFeedback.alreadyKnown,
      rejectedTrackId: 'yt:abcdefghijk',
      excludeIds: {'yt:abcdefghijk'},
    );
    expect(track?.id, 'yt:12345678901');
  });

  test('drops duplicate, excluded and wrong-language tracks', () async {
    final repository = _repository(
      (_) async => _response({
        'tracks': [
          _track(),
          _track(),
          _track(id: '12345678901'),
          {..._track(id: 'ABCDEFGHIJK'), 'language': 'english'},
        ],
      }),
    );
    final tracks = await repository.fetchRound(
      const DiscoveryPreferences(
        taste: TasteProfile(language: MusicLanguage.turkish),
      ),
      count: 4,
      excludeIds: {'yt:12345678901'},
    );
    expect(tracks.map((track) => track.id), ['yt:abcdefghijk']);
  });

  test(
    'rejects invalid playback IDs, metadata and excessive responses',
    () async {
      for (final tracks in [
        [
          {..._track(), 'youtubeId': 'invalid'},
        ],
        [
          {..._track(), 'energy': 2},
        ],
        [
          {..._track(), 'durationSeconds': 0},
        ],
        [
          {..._track(), 'reasons': <String, String>{}},
        ],
        [_track(), _track()],
      ]) {
        final repository = _repository(
          (_) async => _response({'tracks': tracks}),
        );
        await expectLater(
          repository.fetchRound(const DiscoveryPreferences(), count: 1),
          throwsA(isA<FormatException>()),
        );
      }
    },
  );

  test(
    'provider/configuration errors surface without local fallback',
    () async {
      for (final status in [401, 429, 502, 503]) {
        final repository = _repository(
          (_) async => _response({'error': 'Unavailable'}, status: status),
        );
        await expectLater(
          repository.fetchRound(const DiscoveryPreferences(), count: 4),
          throwsA(isA<FunctionException>()),
        );
      }
    },
  );

  test(
    'save/remove feedback reaches server; legacy songs stay local',
    () async {
      final kinds = <String>[];
      final repository = _repository((request) async {
        final body = jsonDecode(request.body);
        expect(body['action'], 'feedback');
        kinds.add(body['feedback']['kind']);
        return _response({'success': true});
      });
      await repository.recordSaved('legacy-local', isSaved: true);
      await repository.recordSaved('yt:abcdefghijk', isSaved: true);
      await repository.recordSaved('yt:abcdefghijk', isSaved: false);
      expect(kinds, ['saved', 'removed']);
    },
  );
}
