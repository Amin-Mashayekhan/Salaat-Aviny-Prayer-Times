import 'package:meta/meta.dart';
import 'package:prayer_core/src/calculation/civil_date.dart';
import 'package:prayer_core/src/calculation/prayer.dart';

/// What a [ScheduledEvent] asks the app to do.
enum EventKind {
  /// Play the azan of a prayer.
  azan,

  /// Warn that an azan is coming.
  reminder,

  /// A wake-up alarm is due.
  wakeAlarm,

  /// A new civil day began: rebuild the schedule.
  dayRollover,
}

/// Something that must happen at a UTC instant.
@immutable
class ScheduledEvent {
  /// Creates an event. Prefer `ScheduleBuilder` over calling this directly.
  const ScheduledEvent({
    required this.kind,
    required this.instantUtc,
    required this.date,
    this.prayer,
    this.alarmId,
    this.relatedInstantUtc,
  });

  /// What to do.
  final EventKind kind;

  /// When to do it (UTC).
  final DateTime instantUtc;

  /// The civil date, in the location's zone, this event belongs to.
  final CivilDate date;

  /// The prayer, for [EventKind.azan] and [EventKind.reminder].
  final Prayer? prayer;

  /// The alarm id, for [EventKind.wakeAlarm].
  final String? alarmId;

  /// For a reminder: the instant of the azan it announces.
  final DateTime? relatedInstantUtc;

  /// Stable identity: `<kind>:<prayer or alarm id>:<yyyy-MM-dd>`.
  ///
  /// The same event has the same id across rebuilds and restarts, which is
  /// what makes exactly-once delivery possible.
  String get id =>
      '${kind.name}:${prayer?.name ?? alarmId ?? 'day'}:'
      '${date.iso}';

  @override
  bool operator ==(Object other) =>
      other is ScheduledEvent &&
      other.id == id &&
      other.instantUtc == instantUtc;

  @override
  int get hashCode => Object.hash(id, instantUtc);

  @override
  String toString() => 'ScheduledEvent($id @ ${instantUtc.toIso8601String()})';
}
