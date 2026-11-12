import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:owghat_lib/src/features/qibla/presentation/qibla_map_support.dart';

/// A client that remembers whether it was closed.
class _SpyClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw UnimplementedError();

  @override
  void close() => closed = true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('disposing the tile provider leaves the shared client open', () async {
    // Every TileLayer disposes its provider when the map style changes or the
    // map is switched off. The client must survive that, otherwise the next
    // layer can load nothing and the map stays blank.
    final client = _SpyClient();
    final provider = createNetworkTileProvider(
      client,
      cachingProvider: const DisabledMapCachingProvider(),
    );
    provider.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(client.closed, isFalse);
    final again = createNetworkTileProvider(
      client,
      cachingProvider: const DisabledMapCachingProvider(),
    );
    again.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(client.closed, isFalse);
  });

  test('the tile client retries and can be closed by its owner', () {
    final client = createTileHttpClient();
    expect(client, isA<http.Client>());
    client.close();
  });
}
