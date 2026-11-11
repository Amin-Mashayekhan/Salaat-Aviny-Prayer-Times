import 'package:prayer_core/src/calculation/civil_date.dart';
import 'package:prayer_core/src/calculation/prayer.dart';
import 'package:prayer_core/src/calculation/prayer_times.dart';

/// Adds the user's per-prayer offsets (in minutes, may be negative).
///
/// Prayers missing from [minutes] are left unchanged; null times stay null.
PrayerTimes applyOffsets(PrayerTimes times, Map<Prayer, int> minutes) {
  return times.map(
    (prayer, value) => value + Duration(minutes: minutes[prayer] ?? 0),
  );
}

/// Rounds to the nearest whole minute, halves rounding up.
///
/// The result is not wrapped to 24 hours.
Duration roundToMinute(Duration value) {
  final minutes = (value.inMicroseconds / Duration.microsecondsPerMinute + 0.5)
      .floor();
  return Duration(minutes: minutes);
}

/// Rounds every time of [times] to the minute (see [roundToMinute]).
PrayerTimes roundTimesToMinute(PrayerTimes times) =>
    times.map((_, value) => roundToMinute(value));

/// The minute of the day (0 to 1439) of a time that may exceed 24 hours.
///
/// Use this only for display; never to build an instant.
int minuteOfDay(Duration value) {
  final minutes = roundToMinute(value).inMinutes;
  return minutes % Duration.minutesPerDay;
}

/// Converts times after local midnight to UTC instants.
///
/// `instant = localMidnightUtc(date) + time`, where
/// `localMidnightUtc(date) = DateTime.utc(y, m, d) - utcOffset`.
/// Null times are omitted from the result.
Map<Prayer, DateTime> toUtcInstants({
  required CivilDate date,
  required Duration utcOffset,
  required PrayerTimes times,
}) {
  final localMidnightUtc = date.asUtcMidnight.subtract(utcOffset);
  return {
    for (final entry in times.entries)
      if (entry.value != null) entry.key: localMidnightUtc.add(entry.value!),
  };
}
