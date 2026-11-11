import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// A saved location with its name, coordinates and zone filled in.
@immutable
class ResolvedLocation {
  /// Creates a resolved location.
  const ResolvedLocation({
    required this.id,
    required this.nameFa,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
    required this.elevationMeters,
    required this.zoneId,
    required this.offset,
    required this.isCustom,
  });

  /// Resolves [saved] against the bundled [repository]; null if a built-in
  /// city no longer exists.
  static ResolvedLocation? from(
    SavedLocation saved,
    LocationRepository repository,
  ) {
    if (saved.kind == LocationKind.custom) {
      return ResolvedLocation(
        id: saved.id,
        nameFa: saved.name!,
        nameEn: saved.name!,
        latitude: saved.latitude!,
        longitude: saved.longitude!,
        elevationMeters: saved.elevationMeters,
        zoneId: saved.zoneId,
        offset: saved.offset,
        isCustom: true,
      );
    }
    final city = repository.cityById(saved.cityId!);
    if (city == null) return null;
    return ResolvedLocation(
      id: saved.id,
      nameFa: city.nameFa,
      nameEn: city.nameEn,
      latitude: city.latitude,
      longitude: city.longitude,
      elevationMeters: 0,
      zoneId: saved.zoneId,
      offset: saved.offset,
      isCustom: false,
    );
  }

  /// Saved-location id.
  final String id;

  /// Persian name.
  final String nameFa;

  /// English name.
  final String nameEn;

  /// Latitude in degrees, north positive.
  final double latitude;

  /// Longitude in degrees, east positive.
  final double longitude;

  /// Elevation in metres.
  final double elevationMeters;

  /// IANA zone id (used when the offset rule is automatic).
  final String zoneId;

  /// The offset rule.
  final LocationOffset offset;

  /// Whether the user typed this location.
  final bool isCustom;

  /// The name in [language].
  String nameIn(AppLanguage language) =>
      language == AppLanguage.fa ? nameFa : nameEn;

  @override
  bool operator ==(Object other) =>
      other is ResolvedLocation &&
      other.id == id &&
      other.nameFa == nameFa &&
      other.nameEn == nameEn &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.elevationMeters == elevationMeters &&
      other.zoneId == zoneId &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(
    id,
    nameFa,
    nameEn,
    latitude,
    longitude,
    elevationMeters,
    zoneId,
    offset,
  );
}
