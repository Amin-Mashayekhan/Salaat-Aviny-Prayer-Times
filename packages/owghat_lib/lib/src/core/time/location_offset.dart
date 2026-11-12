import 'package:owghat_lib/src/core/utils/json_value.dart';

/// How the UTC offset of a location is determined.
enum OffsetMode {
  /// From the bundled IANA time-zone database. Recommended.
  automatic,

  /// A fixed number of minutes east of UTC on every day of the year.
  fixed,
}

/// The offset rule of one location. There is deliberately no daylight-saving
/// field: a zone with DST is handled by the database, never by this app.
class LocationOffset extends JsonValue {
  /// Creates an offset rule.
  const LocationOffset({this.mode = OffsetMode.automatic, this.fixedMinutes});

  /// Automatic (database) offset.
  const LocationOffset.automatic()
    : mode = OffsetMode.automatic,
      fixedMinutes = null;

  /// Fixed offset of [minutes] east of UTC.
  const LocationOffset.fixed(int minutes)
    : mode = OffsetMode.fixed,
      fixedMinutes = minutes;

  /// Reads the JSON form.
  factory LocationOffset.fromJson(Object? raw) {
    final map = Json.map(raw);
    final mode = Json.enumValue(
      OffsetMode.values,
      map['mode'],
      OffsetMode.automatic,
    );
    if (mode == OffsetMode.fixed) {
      final minutes = Json.integer(map['minutes'], 210);
      return LocationOffset.fixed(
        minutes.clamp(minFixedMinutes, maxFixedMinutes),
      );
    }
    return const LocationOffset.automatic();
  }

  /// Smallest fixed offset, UTC-12:00.
  static const minFixedMinutes = -720;

  /// Largest fixed offset, UTC+14:00.
  static const maxFixedMinutes = 840;

  /// Automatic or fixed.
  final OffsetMode mode;

  /// Minutes east of UTC when [mode] is [OffsetMode.fixed].
  final int? fixedMinutes;

  @override
  Map<String, Object?> toJson() => {
    'mode': mode.name,
    if (mode == OffsetMode.fixed) 'minutes': fixedMinutes,
  };
}
