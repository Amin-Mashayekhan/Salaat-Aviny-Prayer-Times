import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

/// All prayer times of one civil date at one location, ready to show and to
/// schedule.
@immutable
class PrayerDay {
  /// Creates a day.
  const PrayerDay({
    required this.date,
    required this.utcOffset,
    required this.times,
    required this.instants,
  });

  /// The civil date (in the location).
  final CivilDate date;

  /// The UTC offset used for the whole day.
  final Duration utcOffset;

  /// Times after local midnight, with the user offsets applied and rounded to
  /// the minute. Values may be 24 hours or more; null means "does not occur".
  final PrayerTimes times;

  /// The same times as UTC instants (only the ones that occur).
  final Map<Prayer, DateTime> instants;

  /// UTC instant of local midnight at the start of [date].
  DateTime get localMidnightUtc => date.asUtcMidnight.subtract(utcOffset);

  @override
  bool operator ==(Object other) =>
      other is PrayerDay &&
      other.date == date &&
      other.utcOffset == utcOffset &&
      other.times == times;

  @override
  int get hashCode => Object.hash(date, utcOffset, times);
}

/// Computes the [PrayerDay] of [date].
///
/// The UTC offset comes from [resolver] and the calculation is the
/// pure `PrayerCalculator`; user offsets are applied afterwards and the result
/// is rounded to the minute, which is also what the azan is scheduled at.
PrayerDay computePrayerDay({
  required CivilDate date,
  required ResolvedLocation location,
  required CalculationSettings calculation,
  required ZoneOffsetResolver resolver,
}) {
  final utcOffset = resolver.offsetFor(
    rule: location.offset,
    zoneId: location.zoneId,
    date: date,
  );
  final raw = const PrayerCalculator().compute(
    date: date,
    latitude: location.latitude,
    longitude: location.longitude,
    elevationMeters: location.elevationMeters,
    utcOffset: utcOffset,
    params: calculation.params,
  );
  final times = roundTimesToMinute(
    applyOffsets(raw, calculation.offsetsMinutes),
  );
  return PrayerDay(
    date: date,
    utcOffset: utcOffset,
    times: times,
    instants: toUtcInstants(date: date, utcOffset: utcOffset, times: times),
  );
}
