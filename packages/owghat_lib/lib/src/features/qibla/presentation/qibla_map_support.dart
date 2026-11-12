import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

/// The tile server the map reads from (OpenStreetMap standard layer).
const String qiblaTileUrlTemplate =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// The satellite layer: Esri World Imagery (aerial photographs). Note the
/// row-before-column order of the template, which is how that server numbers
/// its tiles.
const String qiblaSatelliteTileUrlTemplate =
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/'
    'MapServer/tile/{z}/{y}/{x}';

/// Deepest zoom at which the imagery server has real photographs nearly
/// everywhere (checked for Mecca and Neyshabur). Deeper views enlarge the
/// zoom-18 picture instead of asking for tiles that often only say "map data
/// not yet available".
const int qiblaSatelliteNativeZoom = 18;

/// Names this app to the tile server, as the OpenStreetMap tile policy asks.
const String qiblaTileUserAgent = 'app.salaat.desktop';

/// The tile provider of the qibla map.
///
/// `null` means the default one, which downloads tiles from the internet.
/// Tests override it with [BlankTileProvider] so no test touches the network.
final qiblaTileProviderProvider = Provider<TileProvider?>((ref) => null);

/// The most map pictures kept on disk, in bytes. The map is meant to be
/// looked at online, not downloaded: only the tiles just seen are kept, so
/// that moving the map back and forth does not ask the server again.
const int qiblaTileCacheBytes = 16 * 1000 * 1000;

/// An HTTP client for map tiles that retries a failed request a few times.
http.Client createTileHttpClient() => RetryClient(http.Client());

/// The provider that downloads tiles for real over [client], with a small
/// disk cache.
///
/// Every `TileLayer` disposes its provider when it goes away (a change of map
/// style, the map switched off). A provider that made its own HTTP client
/// closes it then, and the next layer gets only errors. With a client passed
/// in, the provider leaves it open; the caller owns and closes it.
///
/// [cachingProvider] defaults to the bounded disk cache.
TileProvider createNetworkTileProvider(
  http.Client client, {
  MapCachingProvider? cachingProvider,
}) => NetworkTileProvider(
  httpClient: client,
  cachingProvider:
      cachingProvider ??
      BuiltInMapCachingProvider.getOrCreateInstance(
        maxCacheSize: qiblaTileCacheBytes,
      ),
);

/// A tile provider that shows empty tiles and never uses the network.
class BlankTileProvider extends TileProvider {
  /// Creates the provider.
  BlankTileProvider();

  // A 1x1 transparent PNG.
  static final Uint8List _transparentPixel = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=',
  );

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(_transparentPixel);
}
