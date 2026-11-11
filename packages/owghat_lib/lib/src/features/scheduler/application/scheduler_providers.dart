import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/platform/power_events.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/scheduler/application/schedule_engine.dart';
import 'package:owghat_lib/src/features/scheduler/domain/event_dispatcher.dart';
import 'package:owghat_lib/src/features/scheduler/domain/handled_events_store.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// Where handled events are remembered. Injected at start-up.
final handledEventsStoreProvider = Provider<HandledEventsStore>(
  (ref) => InMemoryHandledEventsStore(),
);

/// Carries out events. Injected at start-up.
final eventDispatcherProvider = Provider<ScheduleDispatcher>(
  (ref) => throw StateError('eventDispatcherProvider was not overridden'),
);

/// The power and clock event source. Injected at start-up.
final powerEventsProvider = Provider<PowerEvents>(
  (ref) => const NoPowerEvents(),
);

/// A clock unaffected by clock changes, used by the watchdog. Null means a
/// running `Stopwatch`; tests inject their own.
final monotonicClockProvider = Provider<Duration Function()?>((ref) => null);

/// Resolved wake-up alarm occurrences to schedule (filled by the wake-up
/// feature; empty until then).
final alarmOccurrencesProvider = Provider<List<AlarmOccurrence>>((ref) => []);

/// Local time of day, in seconds, at which a day-rollover marker fires.
const Duration rolloverOffset = Duration(seconds: 5);

/// Builds the events of today and tomorrow from the current settings.
///
/// Only reads state; it never writes settings (rule T-5).
List<ScheduledEvent> buildScheduleEvents(Ref ref) {
  final now = ref.read(clockProvider).now().toUtc();
  final settings = ref.read(settingsProvider);
  final location = ref.read(activeLocationProvider);
  final resolver = ref.read(zoneOffsetResolverProvider);

  final currentOffset = resolver.currentOffset(
    rule: location.offset,
    zoneId: location.zoneId,
    instant: now,
  );
  final today = resolver.civilDateAt(now, currentOffset);
  final days = <CivilDate, PrayerDay>{
    for (final date in [today, today.addDays(1)])
      date: computePrayerDay(
        date: date,
        location: location,
        calculation: settings.calculation,
        resolver: resolver,
      ),
  };

  final rollovers = <CivilDate, DateTime>{};
  for (final date in [today.addDays(1), today.addDays(2)]) {
    final offset = resolver.offsetFor(
      rule: location.offset,
      zoneId: location.zoneId,
      date: date,
    );
    rollovers[date] = date.asUtcMidnight.subtract(offset).add(rolloverOffset);
  }

  return const ScheduleBuilder().build(
    instantsByDate: {
      for (final entry in days.entries) entry.key: entry.value.instants,
    },
    azanEnabled: settings.azan.enabledPrayers,
    reminderMinutes: settings.reminders.minutesBefore,
    alarms: ref.read(alarmOccurrencesProvider),
    rolloverByDate: rollovers,
  );
}

/// The running schedule engine. Reading this provider starts it.
final scheduleEngineProvider = Provider<ScheduleEngine>((ref) {
  final engine = ScheduleEngine(
    clock: ref.read(clockProvider),
    buildEvents: () => buildScheduleEvents(ref),
    dispatcher: ref.watch(eventDispatcherProvider),
    handled: ref.watch(handledEventsStoreProvider),
    monotonic: ref.read(monotonicClockProvider),
  );

  void rebuild() => unawaited(engine.rebuild());

  // Anything that changes what is scheduled rebuilds the engine. Rebuilding
  // is cheap and idempotent, so a coarse trigger is fine.
  ref
    ..listen(settingsProvider, (_, _) => rebuild())
    ..listen(effectiveCorrectionProvider, (_, _) => rebuild())
    ..listen(alarmOccurrencesProvider, (_, _) => rebuild());

  final subscription = ref.read(powerEventsProvider).events.listen((event) {
    if (event != PowerEvent.suspending) rebuild();
  });
  ref.onDispose(() {
    unawaited(subscription.cancel());
    engine.dispose();
  });

  unawaited(engine.start());
  return engine;
});
