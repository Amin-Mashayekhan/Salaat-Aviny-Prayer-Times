import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// What a plain HTTP GET returned.
class HttpTextResponse {
  /// Creates a response.
  const HttpTextResponse(this.statusCode, this.body);

  /// The HTTP status code.
  final int statusCode;

  /// The body as text (UTF-8).
  final String body;
}

/// Fetches [uri] with GET and returns the answer as text. Throws
/// `http.ClientException` (or, on some platforms, a socket error) or a
/// [TimeoutException] when the server cannot be reached.
typedef HttpGetText = Future<HttpTextResponse> Function(
  Uri uri, {
  Map<String, String> headers,
  Duration timeout,
});

/// [HttpGetText] over `package:http`, which works on every platform,
/// including browsers (the servers used allow cross-origin requests; a browser
/// ignores the User-Agent header and sends its own).
Future<HttpTextResponse> packageHttpGetText(
  Uri uri, {
  Map<String, String> headers = const {},
  Duration timeout = const Duration(seconds: 15),
}) async {
  final client = http.Client();
  try {
    final response = await client.get(uri, headers: headers).timeout(timeout);
    return HttpTextResponse(
      response.statusCode,
      utf8.decode(response.bodyBytes, allowMalformed: true),
    );
  } finally {
    client.close();
  }
}
