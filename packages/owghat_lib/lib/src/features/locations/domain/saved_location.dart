import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/core/utils/json_value.dart';

export 'package:owghat_lib/src/core/time/location_offset.dart';

/// Where a saved location comes from.
enum LocationKind {
  /// A city of the bundled database.
  builtin,

  /// Coordinates typed by the user.
  custom,
}

/// A location the user saved. Built-in ones only store the city id; the
/// name and coordinates are looked up in the bundled database.
class SavedLocation extends JsonValue {
  /// A built-in city.
  const SavedLocation.builtin({
    required this.id,
    required int this.cityId,
    this.offset = const LocationOffset.automatic(),
  }) : kind = LocationKind.builtin,
       name = null,
       latitude = null,
       longitude = null,
       elevationMeters = 0,
       zoneId = 'Asia/Tehran';

  /// A user-defined place.
  const SavedLocation.custom({
    required this.id,
    required String this.name,
    required double this.latitude,
    required double this.longitude,
    required this.zoneId,
    this.elevationMeters = 0,
    this.offset = const LocationOffset.automatic(),
  }) : kind = LocationKind.custom,
       cityId = null;

  /// Reads the JSON form; returns null if the entry is unusable.
  static SavedLocation? fromJson(Object? raw) {
    final map = Json.map(raw);
    final id = Json.string(map['id'], '');
    if (id.isEmpty) return null;
    final offset = LocationOffset.fromJson(map['offset']);
    final kind = Json.enumValue(
      LocationKind.values,
      map['kind'],
      LocationKind.builtin,
    );
    if (kind == LocationKind.builtin) {
      final cityId = map['cityId'];
      if (cityId is! int) return null;
      return SavedLocation.builtin(id: id, cityId: cityId, offset: offset);
    }
    final lat = Json.numberOrNull(map['latitude'], null);
    final lon = Json.numberOrNull(map['longitude'], null);
    if (lat == null || lon == null) return null;
    if (lat.abs() > maxLatitude || lon.abs() > 180) return null;
    return SavedLocation.custom(
      id: id,
      name: Json.string(map['name'], id),
      latitude: lat,
      longitude: lon,
      elevationMeters: Json.number(map['elevationM'], 0).clamp(0, 9000),
      zoneId: Json.string(map['zoneId'], 'UTC'),
      offset: offset,
    );
  }

  /// Largest latitude accepted (the calculation is undefined at the poles).
  static const maxLatitude = 89.9;

  /// Stable identifier, unique among saved locations.
  final String id;

  /// Built-in or custom.
  final LocationKind kind;

  /// City id, for built-in locations.
  final int? cityId;

  /// Display name, for custom locations.
  final String? name;

  /// Latitude in degrees, for custom locations.
  final double? latitude;

  /// Longitude in degrees, for custom locations.
  final double? longitude;

  /// Elevation above sea level in metres, for custom locations.
  final double elevationMeters;

  /// IANA zone id used when the offset mode is automatic.
  final String zoneId;

  /// The offset rule.
  final LocationOffset offset;

  /// Copy with a different offset rule.
  SavedLocation withOffset(LocationOffset offset) =>
      kind == LocationKind.builtin
      ? SavedLocation.builtin(id: id, cityId: cityId!, offset: offset)
      : SavedLocation.custom(
          id: id,
          name: name!,
          latitude: latitude!,
          longitude: longitude!,
          zoneId: zoneId,
          elevationMeters: elevationMeters,
          offset: offset,
        );

  @override
  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    if (kind == LocationKind.builtin) 'cityId': cityId,
    if (kind == LocationKind.custom) ...{
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'elevationM': elevationMeters,
      'zoneId': zoneId,
    },
    'offset': offset.toJson(),
  };
}
