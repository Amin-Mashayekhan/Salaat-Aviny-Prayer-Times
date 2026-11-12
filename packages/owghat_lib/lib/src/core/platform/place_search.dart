import 'package:flutter/foundation.dart';

/// Why a place search or lookup did not give an answer.
enum PlaceSearchFailure {
  /// The computer is not connected to the internet (or the server cannot be
  /// reached).
  offline,

  /// The server did not answer in time.
  timeout,

  /// The server asked to slow down or is overloaded.
  busy,

  /// The server answered with something unusable.
  badResponse,

  /// This platform cannot search.
  unsupported,

  /// Anything else.
  failed,
}

/// Thrown by [PlaceSearchService].
class PlaceSearchException implements Exception {
  /// Creates the exception.
  const PlaceSearchException(this.failure, [this.message = '']);

  /// What went wrong.
  final PlaceSearchFailure failure;

  /// Detail for the log (never shown to the user).
  final String message;

  @override
  String toString() => 'PlaceSearchException($failure) $message';
}

/// A place found by name.
@immutable
class FoundPlace {
  /// Creates a place.
  const FoundPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.region = '',
    this.country = '',
  });

  /// The name in the language that was asked for ("Mumbai").
  final String name;

  /// Region and country line, as short as it can be ("Maharashtra · India").
  final String region;

  /// The country, when the server gave it.
  final String country;

  /// Degrees north.
  final double latitude;

  /// Degrees east.
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is FoundPlace &&
      other.name == name &&
      other.region == region &&
      other.country == country &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(name, region, country, latitude, longitude);

  @override
  String toString() => 'FoundPlace($name, $latitude, $longitude)';
}

/// What prayer-time calculation needs beyond the coordinates.
@immutable
class PlaceDetails {
  /// Creates the details.
  const PlaceDetails({required this.zoneId, this.elevationMeters = 0});

  /// The IANA time-zone id ("Asia/Kolkata").
  final String zoneId;

  /// Height above sea level in metres.
  final double elevationMeters;

  @override
  bool operator ==(Object other) =>
      other is PlaceDetails &&
      other.zoneId == zoneId &&
      other.elevationMeters == elevationMeters;

  @override
  int get hashCode => Object.hash(zoneId, elevationMeters);
}

/// Looks places up by name on the internet.
///
/// It is used only when the person presses "Search": the typed text goes to
/// the search service and nothing else does. What the app needs afterwards is
/// saved on the computer, so everything keeps working offline.
abstract interface class PlaceSearchService {
  /// Places that match [query], best first. [language] is the language code of
  /// the names to return. [settlementsOnly] restricts the answer to cities,
  /// towns and villages. Throws a [PlaceSearchException].
  Future<List<FoundPlace>> search(
    String query, {
    required String language,
    bool settlementsOnly = false,
    int limit = 8,
  });

  /// The time zone and height of a point. Throws a [PlaceSearchException].
  Future<PlaceDetails> details(double latitude, double longitude);
}

/// The service of a platform that cannot search.
class UnsupportedPlaceSearch implements PlaceSearchService {
  /// Creates it.
  const UnsupportedPlaceSearch();

  @override
  Future<List<FoundPlace>> search(
    String query, {
    required String language,
    bool settlementsOnly = false,
    int limit = 8,
  }) =>
      Future.error(const PlaceSearchException(PlaceSearchFailure.unsupported));

  @override
  Future<PlaceDetails> details(double latitude, double longitude) =>
      Future.error(const PlaceSearchException(PlaceSearchFailure.unsupported));
}
