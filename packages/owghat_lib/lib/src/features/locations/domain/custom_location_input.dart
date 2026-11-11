import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';

/// Why a custom location was refused.
enum LocationInputError {
  /// The name is empty.
  nameEmpty,

  /// Latitude outside the supported range.
  latitudeRange,

  /// Longitude outside -180 to 180.
  longitudeRange,

  /// Elevation outside 0 to 9000 metres.
  elevationRange,

  /// The IANA zone id is not in the database.
  unknownZone,

  /// A fixed offset outside UTC-12 to UTC+14.
  offsetRange,
}

/// Validates the fields of a custom location; null means valid.
LocationInputError? validateCustomLocation({
  required String name,
  required double latitude,
  required double longitude,
  required double elevationMeters,
  required String zoneId,
  required LocationOffset offset,
  required ZoneOffsetResolver resolver,
}) {
  if (name.trim().isEmpty) return LocationInputError.nameEmpty;
  if (latitude.isNaN || latitude.abs() > SavedLocation.maxLatitude) {
    return LocationInputError.latitudeRange;
  }
  if (longitude.isNaN || longitude.abs() > 180) {
    return LocationInputError.longitudeRange;
  }
  if (elevationMeters.isNaN || elevationMeters < 0 || elevationMeters > 9000) {
    return LocationInputError.elevationRange;
  }
  if (offset.mode == OffsetMode.fixed) {
    final minutes = offset.fixedMinutes;
    if (minutes == null ||
        minutes < LocationOffset.minFixedMinutes ||
        minutes > LocationOffset.maxFixedMinutes) {
      return LocationInputError.offsetRange;
    }
  } else if (!resolver.knowsZone(zoneId)) {
    return LocationInputError.unknownZone;
  }
  return null;
}
