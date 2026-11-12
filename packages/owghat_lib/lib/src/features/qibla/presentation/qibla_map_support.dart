import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The tile server the map reads from (OpenStreetMap standard layer).
const String qiblaTileUrlTemplate =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Names this app to the tile server, as the OpenStreetMap tile policy asks.
const String qiblaTileUserAgent = 'app.salaat.desktop';

/// INJECTION POINT: the tile provider of the qibla map.
///
/// `null` means the default one, which downloads tiles from the internet.
/// Tests override it with [BlankTileProvider] so no test touches the network.
final qiblaTileProviderProvider = Provider<TileProvider?>((ref) => null);

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
