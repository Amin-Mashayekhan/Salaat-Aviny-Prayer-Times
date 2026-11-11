import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/core/time/tz_database.dart';
import 'package:prayer_core/prayer_core.dart';
import 'package:timezone/timezone.dart' as tz;

/// The only place that decides the UTC offset of a civil date (rules T-3,
/// T-4 and T-7 in `docs/04-DOMAIN-SPEC.md`).
///
/// There is no daylight-saving logic of our own here: a zone with DST is
/// handled entirely by the bundled IANA database, and a user who distrusts
/// it chooses a fixed offset.
class ZoneOffsetResolver {
  /// Creates a resolver and makes sure the database is loaded.
  ZoneOffsetResolver() {
    ensureTimeZonesInitialized();
  }

  /// Whether [zoneId] exists in the database.
  bool knowsZone(String zoneId) {
    try {
      tz.getLocation(zoneId);
      return true;
    } on tz.LocationNotFoundException {
      return false;
    }
  }

  /// All zone ids in the database, sorted.
  List<String> get zoneIds =>
      tz.timeZoneDatabase.locations.keys.toList()..sort();

  /// Offset of [zoneId] at the UTC [instant].
  Duration offsetAt(String zoneId, DateTime instant) {
    final location = tz.getLocation(zoneId);
    return tz.TZDateTime.from(instant.toUtc(), location).timeZoneOffset;
  }

  /// The offset used for all prayer times of the civil [date].
  ///
  /// Fixed rule: the typed offset on every date. Automatic rule: the offset
  /// the zone has at 12:00 local time of that date, resolved in two steps
  /// (rule T-7) so the answer is right even for zones that change offset
  /// near midnight.
  Duration offsetFor({
    required LocationOffset rule,
    required String zoneId,
    required CivilDate date,
  }) {
    if (rule.mode == OffsetMode.fixed) {
      return Duration(minutes: rule.fixedMinutes ?? 0);
    }
    final utcNoon = DateTime.utc(date.year, date.month, date.day, 12);
    final first = offsetAt(zoneId, utcNoon);
    return offsetAt(zoneId, utcNoon.subtract(first));
  }

  /// The offset in effect at [instant]. Used to find "today" in a place;
  /// prayer times of a date use [offsetFor] instead.
  Duration currentOffset({
    required LocationOffset rule,
    required String zoneId,
    required DateTime instant,
  }) => rule.mode == OffsetMode.fixed
      ? Duration(minutes: rule.fixedMinutes ?? 0)
      : offsetAt(zoneId, instant);

  /// The civil date at [instant] in a place with offset [offset].
  CivilDate civilDateAt(DateTime instant, Duration offset) =>
      CivilDate.fromDateTime(instant.toUtc().add(offset));
}
