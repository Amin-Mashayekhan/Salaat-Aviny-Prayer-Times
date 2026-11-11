import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/coordinates.dart';
import 'package:owghat_lib/src/features/locations/domain/custom_location_input.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/number_input.dart';

/// How a coordinate is typed.
enum CoordinateFormat {
  /// One decimal-degree number.
  decimal,

  /// Degrees, minutes and seconds.
  dms,
}

/// The raw text of one coordinate as typed in the add-location form.
@immutable
class CoordinateInput {
  /// A decimal-degree coordinate.
  const CoordinateInput.decimal(this.text)
    : format = CoordinateFormat.decimal,
      minutes = '',
      seconds = '',
      negative = false;

  /// A degrees-minutes-seconds coordinate; [negative] is south or west.
  const CoordinateInput.dms({
    required String degrees,
    this.minutes = '',
    this.seconds = '',
    this.negative = false,
  }) : format = CoordinateFormat.dms,
       text = degrees;

  /// Decimal or DMS.
  final CoordinateFormat format;

  /// The decimal text, or the degrees text for DMS.
  final String text;

  /// Minutes text (DMS only; empty means zero).
  final String minutes;

  /// Seconds text (DMS only; empty means zero).
  final String seconds;

  /// South or west (DMS only).
  final bool negative;

  /// The decimal-degree value, or null if the text is not a valid number
  /// (for DMS also when minutes or seconds are out of range).
  double? parse() {
    if (format == CoordinateFormat.decimal) return parseNumberInput(text);
    final degrees = parseIntInput(text);
    final min = minutes.trim().isEmpty ? 0 : parseIntInput(minutes);
    final sec = seconds.trim().isEmpty ? 0.0 : parseNumberInput(seconds);
    if (degrees == null || min == null || sec == null) return null;
    final dms = Dms(
      degrees: degrees,
      minutes: min,
      seconds: sec,
      negative: negative,
    );
    return dms.isValid ? dms.decimal : null;
  }
}

/// Everything typed in the custom-location form.
@immutable
class CustomLocationDraft {
  /// Creates a draft.
  const CustomLocationDraft({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.elevationText,
    required this.zoneId,
    this.offset = const LocationOffset.automatic(),
  });

  /// The name typed by the user.
  final String name;

  /// Latitude input.
  final CoordinateInput latitude;

  /// Longitude input.
  final CoordinateInput longitude;

  /// Elevation text in metres; empty means zero.
  final String elevationText;

  /// The chosen IANA zone id.
  final String zoneId;

  /// Automatic or fixed offset rule.
  final LocationOffset offset;

  /// The first problem found, or null when the draft is valid.
  LocationInputError? validate(ZoneOffsetResolver resolver) =>
      validateCustomLocation(
        name: name,
        latitude: latitude.parse() ?? double.nan,
        longitude: longitude.parse() ?? double.nan,
        elevationMeters: elevationText.trim().isEmpty
            ? 0
            : parseNumberInput(elevationText) ?? double.nan,
        zoneId: zoneId,
        offset: offset,
        resolver: resolver,
      );

  /// The saved location for a valid draft, with the given [id].
  SavedLocation build(String id) => SavedLocation.custom(
    id: id,
    name: name.trim(),
    latitude: latitude.parse()!,
    longitude: longitude.parse()!,
    zoneId: zoneId,
    elevationMeters: elevationText.trim().isEmpty
        ? 0
        : parseNumberInput(elevationText)!,
    offset: offset,
  );
}

/// An unused id of the form `custom:N`.
String nextCustomLocationId(Iterable<String> existingIds) {
  final taken = existingIds.toSet();
  var n = 1;
  for (final id in taken) {
    if (id.startsWith('custom:')) {
      final value = int.tryParse(id.substring(7));
      if (value != null && value >= n) n = value + 1;
    }
  }
  while (taken.contains('custom:$n')) {
    n++;
  }
  return 'custom:$n';
}

/// The saved-location id of a built-in city.
String builtinLocationId(int cityId) => 'city:$cityId';

/// Zone ids that contain [query] (case and `_`/space differences ignored), at
/// most [limit]. An empty query returns the first [limit] ids.
List<String> filterZoneIds(List<String> ids, String query, {int limit = 40}) {
  final q = query.trim().toLowerCase().replaceAll(RegExp(r'[\s_]+'), '_');
  if (q.isEmpty) return ids.take(limit).toList();
  final result = <String>[];
  for (final id in ids) {
    if (id.toLowerCase().contains(q)) {
      result.add(id);
      if (result.length >= limit) break;
    }
  }
  return result;
}
