import 'package:meta/meta.dart';
import 'package:prayer_core/src/calculation/civil_date.dart';
import 'package:prayer_core/src/calculation/prayer.dart';
import 'package:prayer_core/src/schedule/scheduled_event.dart';

/// One occurrence of a wake-up alarm, already resolved to an instant.
@immutable
class AlarmOccurrence {
  /// Creates an occurrence.
  const AlarmOccurrence({
    required this.alarmId,
    required this.instantUtc,
    required this.date,
  });

  /// Identity of the alarm.
  final String alarmId;

  /// When it fires.
  final DateTime instantUtc;

  /// Civil date (location zone) of the occurrence.
  final CivilDate date;
}

/// Turns resolved prayer instants and settings into a sorted event list.
class ScheduleBuilder {
  /// Creates a builder (stateless).
  const ScheduleBuilder();

  /// Builds the events.
  ///
  /// - [instantsByDate]: UTC instant of every prayer that occurs, per date.
  /// - [azanEnabled]: prayers whose azan is switched on.
  /// - [reminderMinutes]: minutes before the azan; 0 or missing means off.
  ///   Reminders exist only for prayers whose azan is enabled.
  /// - [alarms]: resolved wake-up alarm occurrences.
  /// - [rolloverByDate]: instant of the day-rollover marker per date.
  ///
  /// The result is sorted by instant, then by kind, then by id.
  List<ScheduledEvent> build({
    required Map<CivilDate, Map<Prayer, DateTime>> instantsByDate,
    required Set<Prayer> azanEnabled,
    Map<Prayer, int> reminderMinutes = const {},
    List<AlarmOccurrence> alarms = const [],
    Map<CivilDate, DateTime> rolloverByDate = const {},
  }) {
    final events = <ScheduledEvent>[];
    for (final dayEntry in instantsByDate.entries) {
      for (final entry in dayEntry.value.entries) {
        final prayer = entry.key;
        if (!prayer.hasAzan || !azanEnabled.contains(prayer)) continue;
        events.add(
          ScheduledEvent(
            kind: EventKind.azan,
            instantUtc: entry.value,
            date: dayEntry.key,
            prayer: prayer,
          ),
        );
        final minutes = reminderMinutes[prayer] ?? 0;
        if (minutes > 0) {
          events.add(
            ScheduledEvent(
              kind: EventKind.reminder,
              instantUtc: entry.value.subtract(Duration(minutes: minutes)),
              date: dayEntry.key,
              prayer: prayer,
              relatedInstantUtc: entry.value,
            ),
          );
        }
      }
    }
    for (final alarm in alarms) {
      events.add(
        ScheduledEvent(
          kind: EventKind.wakeAlarm,
          instantUtc: alarm.instantUtc,
          date: alarm.date,
          alarmId: alarm.alarmId,
        ),
      );
    }
    for (final entry in rolloverByDate.entries) {
      events.add(
        ScheduledEvent(
          kind: EventKind.dayRollover,
          instantUtc: entry.value,
          date: entry.key,
        ),
      );
    }
    events.sort((a, b) {
      final byInstant = a.instantUtc.compareTo(b.instantUtc);
      if (byInstant != 0) return byInstant;
      final byKind = a.kind.index.compareTo(b.kind.index);
      return byKind != 0 ? byKind : a.id.compareTo(b.id);
    });
    return events;
  }
}
