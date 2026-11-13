import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/http_get.dart';
import 'package:owghat_lib/src/core/platform/place_search.dart';
import 'package:prayer_core/prayer_core.dart';

final Logger _log = Logger('PlaceSearch');

/// Names this app to the search servers, as their usage policies ask. It
/// carries the project page and nothing about the person.
const String placeSearchUserAgent =
    'Salaat/1.0 (+https://github.com/Amin-Mashayekhan/Salaat-Aviny-Prayer-Times)';

/// [PlaceSearchService] on public servers:
///
/// - the name search uses OpenStreetMap's Nominatim, which understands
///   spellings and names in many languages ("بمبئی هند", "Mumbai, India");
/// - the time zone and height of a chosen point come from Open-Meteo.
///
/// One request per press of "Search", and one more when a place is chosen;
/// nothing is sent in the background. The same query is not sent twice.
class OnlinePlaceSearch implements PlaceSearchService {
  /// Creates the service. The HTTP function is injectable for tests.
  OnlinePlaceSearch([this._get = packageHttpGetText]);

  final HttpGetText _get;
  final Map<String, List<FoundPlace>> _cache = {};

  static const Duration _timeout = Duration(seconds: 12);

  @override
  Future<List<FoundPlace>> search(
    String query, {
    required String language,
    bool settlementsOnly = false,
    int limit = 8,
  }) async {
    final text = query.trim();
    final key = '$language|$settlementsOnly|$limit|${text.toLowerCase()}';
    final cached = _cache[key];
    if (cached != null) return cached;
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': text,
      'format': 'jsonv2',
      'limit': '$limit',
      'addressdetails': '1',
      'dedupe': '1',
      'accept-language': language,
      if (settlementsOnly) 'featureType': 'settlement',
    });
    final places = parseNominatim(await _fetch(uri));
    _cache[key] = places;
    return places;
  }

  @override
  Future<PlaceDetails> details(double latitude, double longitude) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toStringAsFixed(4),
      'longitude': longitude.toStringAsFixed(4),
      'timezone': 'auto',
      'current': 'temperature_2m',
    });
    return parseOpenMeteoDetails(await _fetch(uri));
  }

  Future<String> _fetch(Uri uri) async {
    final HttpTextResponse response;
    try {
      response = await _get(
        uri,
        headers: const {
          'User-Agent': placeSearchUserAgent,
          'Accept': 'application/json',
        },
        timeout: _timeout,
      );
    } on TimeoutException {
      throw const PlaceSearchException(PlaceSearchFailure.timeout);
    } on SocketException catch (error) {
      _log.info('No connection: ${error.message}');
      throw const PlaceSearchException(PlaceSearchFailure.offline);
    } on HandshakeException {
      throw const PlaceSearchException(PlaceSearchFailure.offline);
    } on HttpException {
      throw const PlaceSearchException(PlaceSearchFailure.offline);
    } on http.ClientException catch (error) {
      _log.info('No connection: ${error.message}');
      throw const PlaceSearchException(PlaceSearchFailure.offline);
    } on Object catch (error) {
      throw PlaceSearchException(PlaceSearchFailure.failed, '$error');
    }
    final status = response.statusCode;
    if (status == 429 || status == 503 || status == 509) {
      throw PlaceSearchException(PlaceSearchFailure.busy, 'HTTP $status');
    }
    if (status != 200) {
      throw PlaceSearchException(PlaceSearchFailure.failed, 'HTTP $status');
    }
    return response.body;
  }
}

/// Reads the answer of Nominatim's `search?format=jsonv2`. Entries without a
/// usable position are skipped and places that sit on top of each other (the
/// same spot to 0.01 degree) appear once.
List<FoundPlace> parseNominatim(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    throw const PlaceSearchException(PlaceSearchFailure.badResponse);
  }
  if (decoded is! List) {
    throw const PlaceSearchException(PlaceSearchFailure.badResponse);
  }
  final places = <FoundPlace>[];
  for (final entry in decoded) {
    if (entry is! Map) continue;
    final latitude = double.tryParse('${entry['lat']}');
    final longitude = double.tryParse('${entry['lon']}');
    if (latitude == null || longitude == null) continue;
    if (!isValidCoordinate(latitude, longitude)) continue;
    final display = '${entry['display_name'] ?? ''}';
    final parts = [
      for (final part in display.split(','))
        if (part.trim().isNotEmpty) part.trim(),
    ];
    var name = '${entry['name'] ?? ''}'.trim();
    if (name.isEmpty && parts.isNotEmpty) name = parts.first;
    if (name.isEmpty) continue;
    final address = entry['address'];
    final country = address is Map ? '${address['country'] ?? ''}'.trim() : '';
    final rest = [
      for (var i = 0; i < parts.length; i++)
        if (parts[i] != name && !RegExp(r'^[\d\s\-]+$').hasMatch(parts[i]))
          parts[i],
    ];
    // Keep it short: the first two parts and the country.
    final shown = rest.length <= 3
        ? rest
        : [rest[0], rest[1], if (country.isNotEmpty) country else rest.last];
    // The same name at (almost) the same spot is one place.
    final duplicate = places.any(
      (p) =>
          p.name == name &&
          (p.latitude - latitude).abs() < 0.02 &&
          (p.longitude - longitude).abs() < 0.02,
    );
    if (duplicate) continue;
    places.add(
      FoundPlace(
        name: name,
        region: shown.join(' · '),
        country: country,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }
  return places;
}

/// Reads the answer of Open-Meteo's forecast endpoint called with
/// `timezone=auto`: the IANA zone and the height of the point.
PlaceDetails parseOpenMeteoDetails(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    throw const PlaceSearchException(PlaceSearchFailure.badResponse);
  }
  if (decoded is! Map) {
    throw const PlaceSearchException(PlaceSearchFailure.badResponse);
  }
  final zone = decoded['timezone'];
  if (zone is! String || zone.isEmpty) {
    throw const PlaceSearchException(PlaceSearchFailure.badResponse);
  }
  final elevation = decoded['elevation'];
  final metres = elevation is num ? elevation.toDouble() : 0.0;
  return PlaceDetails(
    zoneId: zone,
    elevationMeters: metres.clamp(0, 9000).toDouble(),
  );
}
