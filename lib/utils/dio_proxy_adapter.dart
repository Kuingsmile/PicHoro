import 'dart:io';
import 'package:dio/io.dart';

/// Creates and returns an [IOHttpClientAdapter] configured with the provided proxy URL.
///
/// If [proxyUrl] is null or empty, returns a default adapter with no proxy.
/// Otherwise, configures a client with the specified proxy and certificate handling.
IOHttpClientAdapter useProxy(String? proxyUrl) {
  if (proxyUrl == null || proxyUrl.isEmpty) {
    return IOHttpClientAdapter();
  }

  return IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.findProxy = (_) => 'PROXY $proxyUrl';
      client.badCertificateCallback = (_, __, ___) => true;
      return client;
    },
  );
}
