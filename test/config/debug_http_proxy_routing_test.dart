import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:music_disco/config/debug_http_proxy.dart';

void main() {
  tearDown(() => HttpOverrides.global = null);

  test('package:http requests reach the configured proxy', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final firstLines = <String>[];
    final subscription = server.listen((socket) {
      socket.cast<List<int>>().transform(utf8.decoder).listen((chunk) {
        if (firstLines.isEmpty) firstLines.add(chunk.split('\r\n').first);
        socket.destroy();
      });
    });
    addTearDown(() async {
      await subscription.cancel();
      await server.close();
    });

    setupDebugHttpProxy(endpoint: 'localhost:${server.port}', enabled: true);
    final client = http.Client();
    addTearDown(client.close);
    await client
        .get(Uri.parse('http://music-disco.invalid/ping'))
        .then<void>((_) {}, onError: (_) {})
        .timeout(const Duration(seconds: 5));

    expect(firstLines, isNotEmpty);
    expect(
      firstLines.single,
      startsWith('GET http://music-disco.invalid/ping'),
    );
  });
}
