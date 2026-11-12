import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
/// [SocketException], [HandshakeException] or [TimeoutException] when the
/// server cannot be reached.
typedef HttpGetText = Future<HttpTextResponse> Function(
  Uri uri, {
  Map<String, String> headers,
  Duration timeout,
});

/// [HttpGetText] over `dart:io`.
Future<HttpTextResponse> ioHttpGetText(
  Uri uri, {
  Map<String, String> headers = const {},
  Duration timeout = const Duration(seconds: 15),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final request = await client.getUrl(uri).timeout(timeout);
    headers.forEach(request.headers.set);
    final response = await request.close().timeout(timeout);
    final body = await response.transform(utf8.decoder).join().timeout(timeout);
    return HttpTextResponse(response.statusCode, body);
  } finally {
    client.close(force: true);
  }
}
