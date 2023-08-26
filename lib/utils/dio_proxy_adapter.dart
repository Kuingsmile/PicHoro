import 'dart:io';
import 'package:dio/io.dart';

IOHttpClientAdapter useProxy(String? proxyUrl) {
  if (proxyUrl != null && proxyUrl.isNotEmpty) {
    return IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'PROXY $proxyUrl';
        };
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  } else {
    return IOHttpClientAdapter();
  }
}
