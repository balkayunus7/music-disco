import 'dart:io';

import 'package:flutter/foundation.dart';

const _proxyDefine = String.fromEnvironment('HTTP_TOOLKIT_PROXY');

String? parseProxyEndpoint(String raw) {
  final value = raw.trim().replaceFirst(RegExp(r'^http://'), '');
  final match = RegExp(r'^([A-Za-z0-9.\-]+):(\d{1,5})/?$').firstMatch(value);
  if (match == null) return null;
  final port = int.parse(match.group(2)!);
  return port >= 1 && port <= 65535 ? '${match.group(1)}:$port' : null;
}

void setupDebugHttpProxy({
  String endpoint = _proxyDefine,
  bool enabled = kDebugMode,
}) {
  if (!enabled) return;
  if (endpoint.trim().isEmpty) {
    debugPrint('HTTP_TOOLKIT_PROXY is not set; traffic is not proxied.');
    return;
  }
  final proxy = parseProxyEndpoint(endpoint);
  if (proxy == null) {
    debugPrint('HTTP_TOOLKIT_PROXY must look like host:port; ignoring it.');
    return;
  }
  HttpOverrides.global = _DebugProxyOverrides(proxy);
  debugPrint('HTTP traffic is routed through $proxy (debug only).');
}

class _DebugProxyOverrides extends HttpOverrides {
  _DebugProxyOverrides(this.proxy);

  final String proxy;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (_) => 'PROXY $proxy';
    client.badCertificateCallback = (_, _, _) => true;
    return client;
  }
}
