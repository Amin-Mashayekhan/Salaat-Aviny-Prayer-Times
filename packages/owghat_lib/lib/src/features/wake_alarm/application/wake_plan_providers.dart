import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/next_occurrence.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_plan.dart';
import 'package:prayer_core/prayer_core.dart';

/// A one-off alarm that belongs to no saved alarm: the "test in two minutes"
/// button. It is never written to the settings.
@immutable
class WakeTestAlarm {
  /// Creates a test alarm.
  const WakeTestAlarm({required this.alarm, required this.occurrence});

  /// The synthetic alarm (plays the default sound, no after-action).
  final WakeAlarm alarm;

  /// When it rings.
  final WakeOccurrence occurrence;
}

/// Run-time facts the plan needs that are not user settings.
@immutable
class WakeBookkeeping {
  /// Creates the state.
  const WakeBookkeeping({
    this.editedAt = const {},
    this.onceFired = const {},
    this.test,
    this.refresh = 0,
  });

  /// When the user last created or changed each alarm during this run.
  final Map<String, DateTime> editedAt;

  /// `once` alarms that fired and have not been edited since.
  final Set<String> onceFired;

  /// The pending test alarm, if any.
  final WakeTestAlarm? test;

  /// Bumped to make the plan recompute (after an alarm fired, after a
  /// resume or a clock change).
  final int refresh;

  /// Copy with changes; [clearTest] removes the test alarm.
  WakeBookkeeping copyWith({
    Map<String, DateTime>? editedAt,
    Set<String>? onceFired,
    WakeTestAlarm? test,
    bool clearTest = false,
    int? refresh,
  }) => WakeBookkeeping(
    editedAt: editedAt ?? this.editedAt,
    onceFired: onceFired ?? this.onceFired,
    test: clearTest ? null : (test ?? this.test),
    refresh: refresh ?? this.refresh,
  );
}

/// Holder of [WakeBookkeeping]. Only `WakeAlarmController` writes it.
class WakeBookkeepingNotifier extends Notifier<WakeBookkeeping> {
  @override
  WakeBookkeeping build() => const WakeBookkeeping();

  /// The user created or changed alarm [id] at [at]: nothing before [at] is
  /// late for it, and a `once` alarm may fire again.
  void touched(String id, DateTime at) {
    state = state.copyWith(
      editedAt: {...state.editedAt, id: at},
      onceFired: {...state.onceFired}..remove(id),
    );
  }

  /// Forgets alarm [id] (deleted).
  void forgotten(String id) {
    state = state.copyWith(
      editedAt: {...state.editedAt}..remove(id),
      onceFired: {...state.onceFired}..remove(id),
    );
  }

  /// A `once` alarm fired.
  void fired(String id) {
    state = state.copyWith(onceFired: {...state.onceFired, id});
  }

  /// Sets or clears the test alarm.
  void setTest(WakeTestAlarm? test) {
    state = test == null
        ? state.copyWith(clearTest: true)
        : state.copyWith(test: test);
  }

  /// Makes the plan recompute.
  void bump() {
    state = state.copyWith(refresh: state.refresh + 1);
  }
}

/// Provider of the run-time wake bookkeeping.
final wakeBookkeepingProvider =
    NotifierProvider<WakeBookkeepingNotifier, WakeBookkeeping>(
      WakeBookkeepingNotifier.new,
    );

/// The resolved plan of all enabled alarms.
///
/// It recomputes when the alarm list, the location, the calculation settings,
/// the civil date or the bookkeeping change. Only reads settings.
final wakeAlarmPlanProvider = Provider<WakeAlarmPlan>((ref) {
  final alarms = ref.watch(settingsProvider.select((s) => s.wakeAlarms));
  final book = ref.watch(wakeBookkeepingProvider);
  final test = book.test;
  // With nothing to schedule do not touch the location, the clock ticker or
  // the calculator at all.
  if (test == null && alarms.every((alarm) => !alarm.enabled)) {
    return WakeAlarmPlan.empty;
  }
  // The civil date changing is a reason to recompute: tomorrow's occurrence
  // becomes today's.
  ref.watch(todayProvider);
  final clock = ref.watch(clockProvider);
  return buildWakePlan(
    alarms: alarms,
    nowUtc: clock.now().toUtc(),
    prayerDay: (date) => ref.watch(prayerDayProvider(date)),
    resolver: ref.watch(zoneOffsetResolverProvider),
    location: ref.watch(activeLocationProvider),
    editedAt: book.editedAt,
    onceFired: book.onceFired,
    extra: [?test?.occurrence],
  );
});

/// The wake-up occurrences the schedule engine must know about.
///
/// `alarmOccurrencesProvider` (scheduler) reads this, so there is nothing to
/// override.
final wakeAlarmOccurrencesProvider = Provider<List<AlarmOccurrence>>((ref) {
  final plan = ref.watch(wakeAlarmPlanProvider);
  return [for (final occurrence in plan.engine) occurrence.toAlarmOccurrence()];
});

/// The next time a saved alarm will ring (for the Home "next wake-up" line),
/// or null when none is enabled. The test alarm is not counted.
final nextWakeOccurrenceProvider = Provider<WakeOccurrence?>((ref) {
  final plan = ref.watch(wakeAlarmPlanProvider);
  final test = ref.watch(wakeBookkeepingProvider).test?.occurrence.alarmId;
  WakeOccurrence? best;
  for (final occurrence in plan.upcoming.values) {
    if (occurrence.alarmId == test) continue;
    if (best == null || occurrence.instantUtc.isBefore(best.instantUtc)) {
      best = occurrence;
    }
  }
  return best;
});
