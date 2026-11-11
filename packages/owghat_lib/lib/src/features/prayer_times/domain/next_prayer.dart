import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

/// One prayer time of one day as an instant.
@immutable
class PrayerMoment {
  /// Creates a moment.
  const PrayerMoment({
    required this.prayer,
    required this.instant,
    required this.date,
  });

  /// Which prayer.
  final Prayer prayer;

  /// When (UTC).
  final DateTime instant;

  /// The civil date it belongs to.
  final CivilDate date;

  @override
  bool operator ==(Object other) =>
      other is PrayerMoment &&
      other.prayer == prayer &&
      other.instant == instant &&
      other.date == date;

  @override
  int get hashCode => Object.hash(prayer, instant, date);

  @override
  String toString() => 'PrayerMoment($prayer @ ${instant.toIso8601String()})';
}

/// The period we are in and the event we are waiting for.
@immutable
class NextPrayerState {
  /// Creates the state.
  const NextPrayerState({
    required this.current,
    required this.next,
    required this.remaining,
  });

  /// The latest event already passed, or null before the first one.
  final PrayerMoment? current;

  /// The next event, or null if none is known (polar night and so on).
  final PrayerMoment? next;

  /// Time until [next]; zero if there is none.
  final Duration remaining;
}

/// Finds the current period and the next event.
///
/// [days] should cover yesterday, today and tomorrow so that the period
/// before the first event of today and after the last one both resolve.
/// Only rows the user shows are considered ([display]); sunset is therefore
/// skipped when hidden, exactly as on the home screen.
NextPrayerState computeNextPrayer({
  required Iterable<PrayerDay> days,
  required DisplaySettings display,
  required DateTime now,
}) {
  final moments = <PrayerMoment>[
    for (final day in days)
      for (final entry in day.instants.entries)
        if (display.shows(entry.key))
          PrayerMoment(prayer: entry.key, instant: entry.value, date: day.date),
  ]..sort((a, b) => a.instant.compareTo(b.instant));

  PrayerMoment? current;
  PrayerMoment? next;
  for (final moment in moments) {
    if (moment.instant.isAfter(now)) {
      next = moment;
      break;
    }
    current = moment;
  }
  return NextPrayerState(
    current: current,
    next: next,
    remaining: next == null ? Duration.zero : next.instant.difference(now),
  );
}
