import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:prayer_core/prayer_core.dart';

/// Looks up the prayer times of a civil date at the active location.
typedef PrayerDayLookup = PrayerDay Function(CivilDate date);

/// How many civil days after today are searched for an occurrence. Covers
/// "one chosen weekday" with a week of polar days without a prayer time.
const int wakeSearchDays = 14;

/// One resolved firing of a wake-up alarm.
@immutable
class WakeOccurrence {
  /// Creates an occurrence.
  const WakeOccurrence({
    required this.alarmId,
    required this.instantUtc,
    required this.date,
  });

  /// The alarm it belongs to.
  final String alarmId;

  /// When it fires.
  final DateTime instantUtc;

  /// The civil date of [instantUtc] in the location zone (the date of the
  /// wall clock when the alarm rings).
  final CivilDate date;

  /// The form the schedule engine consumes.
  AlarmOccurrence toAlarmOccurrence() =>
      AlarmOccurrence(alarmId: alarmId, instantUtc: instantUtc, date: date);

  @override
  bool operator ==(Object other) =>
      other is WakeOccurrence &&
      other.alarmId == alarmId &&
      other.instantUtc == instantUtc &&
      other.date == date;

  @override
  int get hashCode => Object.hash(alarmId, instantUtc, date);

  @override
  String toString() => 'WakeOccurrence($alarmId @ $instantUtc, $date)';
}

/// The first time [alarm] fires strictly after [nowUtc], or null.
///
/// See `docs/prayer-times.md`.
///
/// - A fixed-time alarm fires at its clock time in the location. A relative
///   alarm fires `minutesBefore` minutes before the chosen prayer, recomputed
///   for every day, so it follows the prayer through the year (even across
///   local midnight).
/// - The UTC offset of a date always comes from the same place as the prayer
///   times (`ZoneOffsetResolver`: one offset for the whole civil
///   date). This function has no daylight-saving logic of its own.
/// - `weekdays` is checked against the civil date *on which the alarm rings*
///   (so "40 minutes before Fajr" on a Friday means Friday morning).
/// - Null when the alarm is disabled, when a `once` alarm has already fired
///   ([onceFired]), when a `weekdays` alarm has no day, or when no day inside
///   the next [wakeSearchDays] has a usable time (polar days where the prayer
///   does not occur).
WakeOccurrence? nextOccurrence(
  WakeAlarm alarm, {
  required DateTime nowUtc,
  required PrayerDayLookup prayerDay,
  required ZoneOffsetResolver resolver,
  required ResolvedLocation location,
  bool onceFired = false,
}) {
  if (!alarm.enabled) return null;
  if (alarm.repeat == AlarmRepeat.once && onceFired) return null;
  if (alarm.repeat == AlarmRepeat.weekdays && alarm.weekdays.isEmpty) {
    return null;
  }

  final now = nowUtc.toUtc();
  final today = resolver.civilDateAt(
    now,
    resolver.currentOffset(
      rule: location.offset,
      zoneId: location.zoneId,
      instant: now,
    ),
  );

  WakeOccurrence? best;
  // Start one day back: a prayer time can be past 24:00 (Isha or midnight
  // after local midnight), so the previous day's computation may still hold
  // an instant later than now.
  for (var i = -1; i <= wakeSearchDays; i++) {
    final date = today.addDays(i);
    final found = _candidate(
      alarm,
      date: date,
      prayerDay: prayerDay,
      resolver: resolver,
      location: location,
    );
    if (found == null) continue;
    if (!found.instantUtc.isAfter(now)) continue;
    if (!_weekdayAllowed(alarm, found.date)) continue;
    if (best == null || found.instantUtc.isBefore(best.instantUtc)) {
      best = found;
    }
    // Candidates grow with the date; one more day covers the rare case of a
    // candidate that lands on a neighbouring civil date.
    if (date.compareTo(best.date) > 0) break;
  }
  return best;
}

/// Up to [count] consecutive occurrences of [alarm] after [nowUtc].
///
/// A `once` alarm has at most one.
List<WakeOccurrence> upcomingOccurrences(
  WakeAlarm alarm, {
  required DateTime nowUtc,
  required PrayerDayLookup prayerDay,
  required ZoneOffsetResolver resolver,
  required ResolvedLocation location,
  required int count,
  bool onceFired = false,
}) {
  final result = <WakeOccurrence>[];
  var from = nowUtc;
  final limit = alarm.repeat == AlarmRepeat.once ? 1 : count;
  while (result.length < limit) {
    final next = nextOccurrence(
      alarm,
      nowUtc: from,
      prayerDay: prayerDay,
      resolver: resolver,
      location: location,
      onceFired: onceFired,
    );
    if (next == null) break;
    result.add(next);
    from = next.instantUtc;
  }
  return result;
}

bool _weekdayAllowed(WakeAlarm alarm, CivilDate ringDate) =>
    alarm.repeat != AlarmRepeat.weekdays ||
    alarm.weekdays.contains(ringDate.weekday);

WakeOccurrence? _candidate(
  WakeAlarm alarm, {
  required CivilDate date,
  required PrayerDayLookup prayerDay,
  required ZoneOffsetResolver resolver,
  required ResolvedLocation location,
}) {
  switch (alarm.trigger) {
    case AlarmTriggerKind.fixedTime:
      final offset = resolver.offsetFor(
        rule: location.offset,
        zoneId: location.zoneId,
        date: date,
      );
      final instant = DateTime.utc(
        date.year,
        date.month,
        date.day,
        alarm.hour,
        alarm.minute,
      ).subtract(offset);
      return WakeOccurrence(alarmId: alarm.id, instantUtc: instant, date: date);
    case AlarmTriggerKind.relativeToPrayer:
      final day = prayerDay(date);
      final prayerInstant = day.instants[alarm.prayer];
      if (prayerInstant == null) return null;
      final instant = prayerInstant.subtract(
        Duration(minutes: alarm.minutesBefore),
      );
      return WakeOccurrence(
        alarmId: alarm.id,
        instantUtc: instant,
        // The wall-clock date at which the alarm rings, using the offset the
        // prayer times of this day were built with.
        date: CivilDate.fromDateTime(instant.add(day.utcOffset)),
      );
  }
}
