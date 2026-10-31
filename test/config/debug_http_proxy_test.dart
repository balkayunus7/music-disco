import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_disco/config/debug_http_proxy.dart';

void main() {
  tearDown(() => HttpOverrides.global = null);

  test('parseProxyEndpoint accepts host:port and rejects anything else', () {
    expect(parseProxyEndpoint('localhost:8000'), 'localhost:8000');
    expect(parseProxyEndpoint(' 10.0.2.2:8000 '), '10.0.2.2:8000');
    expect(parseProxyEndpoint('192.168.1.5:8000'), '192.168.1.5:8000');
    expect(parseProxyEndpoint('http://192.168.1.7:8000'), '192.168.1.7:8000');
    expect(parseProxyEndpoint('http://localhost:8000/'), 'localhost:8000');
    expect(parseProxyEndpoint('https://localhost:8000'), isNull);
    expect(parseProxyEndpoint('http://localhost:8000/path'), isNull);
    expect(parseProxyEndpoint('localhost'), isNull);
    expect(parseProxyEndpoint('localhost:0'), isNull);
    expect(parseProxyEndpoint('localhost:70000'), isNull);
    expect(parseProxyEndpoint('a b:80; DIRECT'), isNull);
  });

  test('proxy is installed only when enabled with a valid endpoint', () {
    setupDebugHttpProxy(endpoint: 'localhost:8000', enabled: false);
    expect(HttpOverrides.current, isNull);
    setupDebugHttpProxy(endpoint: '', enabled: true);
    expect(HttpOverrides.current, isNull);
    setupDebugHttpProxy(endpoint: 'not valid', enabled: true);
    expect(HttpOverrides.current, isNull);
    setupDebugHttpProxy(endpoint: 'localhost:8000', enabled: true);
    expect(HttpOverrides.current, isNotNull);
  });
}
