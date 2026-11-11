import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/next_occurrence.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';

/// Everything the wake-up feature has resolved from the alarm list at one
/// moment: what the schedule engine must know and what the OS must be asked
/// to wake for.
@immutable
class WakeAlarmPlan {
  /// Creates a plan.
  const WakeAlarmPlan({required this.engine, required this.upcoming});

  /// Nothing scheduled.
  static const empty = WakeAlarmPlan(engine: [], upcoming: {});

  /// Occurrences for the schedule engine, sorted by time. Includes one that
  /// is slightly in the past (inside the catch-up window) so that an alarm
  /// is still run when the PC resumes a few seconds late.
  final List<WakeOccurrence> engine;

  /// For every alarm that will ring again: its next occurrence strictly after
  /// now. This is what the OS is asked to wake for.
  final Map<String, WakeOccurrence> upcoming;

  @override
  bool operator ==(Object other) =>
      other is WakeAlarmPlan &&
      listEquals(other.engine, engine) &&
      mapEquals(other.upcoming, upcoming);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(engine), Object.hashAll(upcoming.values));
}

/// Resolves [alarms] into a [WakeAlarmPlan].
///
/// - [editedAt]: when the user created or changed an alarm during this run.
///   Nothing before that moment is "late" for it, so a new alarm set for a
///   time that has just passed rings tomorrow instead of right now.
/// - [onceFired]: `once` alarms that already fired.
/// - [extra]: fixed occurrences that belong to no saved alarm (the
///   "test in two minutes" button).
/// - [grace]: the catch-up window of wake-up alarms (10 minutes).
WakeAlarmPlan buildWakePlan({
  required List<WakeAlarm> alarms,
  required DateTime nowUtc,
  required PrayerDayLookup prayerDay,
  required ZoneOffsetResolver resolver,
  required ResolvedLocation location,
  Map<String, DateTime> editedAt = const {},
  Set<String> onceFired = const {},
  List<WakeOccurrence> extra = const [],
  Duration grace = const Duration(minutes: 10),
}) {
  final now = nowUtc.toUtc();
  final graceStart = now.subtract(grace);
  final engine = <WakeOccurrence>[];
  final upcoming = <String, WakeOccurrence>{};

  for (final alarm in alarms) {
    if (!alarm.enabled) continue;
    final fired = onceFired.contains(alarm.id);
    final edited = editedAt[alarm.id];
    final from = edited != null && edited.isAfter(graceStart)
        ? edited
        : graceStart;
    engine.addAll(
      upcomingOccurrences(
        alarm,
        nowUtc: from,
        prayerDay: prayerDay,
        resolver: resolver,
        location: location,
        count: 2,
        onceFired: fired,
      ),
    );
    final next = nextOccurrence(
      alarm,
      nowUtc: now,
      prayerDay: prayerDay,
      resolver: resolver,
      location: location,
      onceFired: fired,
    );
    if (next != null) upcoming[alarm.id] = next;
  }

  for (final occurrence in extra) {
    if (occurrence.instantUtc.isAfter(graceStart)) engine.add(occurrence);
    if (occurrence.instantUtc.isAfter(now)) {
      upcoming[occurrence.alarmId] = occurrence;
    }
  }

  engine.sort((a, b) {
    final byInstant = a.instantUtc.compareTo(b.instantUtc);
    return byInstant != 0 ? byInstant : a.alarmId.compareTo(b.alarmId);
  });
  return WakeAlarmPlan(engine: engine, upcoming: upcoming);
}
