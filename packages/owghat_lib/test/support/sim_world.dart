import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/platform/power_events.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/scheduler/domain/event_dispatcher.dart';
import 'package:owghat_lib/src/features/scheduler/domain/handled_events_store.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

/// Shared test harness: fake time, a controllable wall clock and the real
/// provider graph with a recording dispatcher.
class Dispatched {
  Dispatched(this.event, this.decision, this.at);
  final ScheduledEvent event;
  final CatchUpDecision decision;
  final DateTime at;
  String get id => event.id;
}

class RecordingDispatcher implements ScheduleDispatcher {
  RecordingDispatcher(this._now);
  final DateTime Function() _now;
  final List<Dispatched> calls = [];
  Object? failWith;

  @override
  Future<void> dispatch(ScheduledEvent event, CatchUpDecision decision) async {
    calls.add(Dispatched(event, decision, _now()));
    final failure = failWith;
    if (failure is Exception) throw failure;
  }

  List<Dispatched> azans([CatchUpDecision? decision]) => [
    for (final c in calls)
      if (c.event.kind == EventKind.azan &&
          (decision == null || c.decision == decision))
        c,
  ];
}

/// A test world: fake time, a controllable wall clock, and the real provider
/// graph with a recording dispatcher.
class SimWorld {
  SimWorld(
    this.async,
    this.repo, {
    HandledEventsStore? handled,
    AppSettings? settings,
  }) : handled = handled ?? InMemoryHandledEventsStore(),
       initial = settings ?? const AppSettings.defaults() {
    dispatcher = RecordingDispatcher(wall);
  }

  final FakeAsync async;
  final LocationRepository repo;
  final HandledEventsStore handled;
  final AppSettings initial;

  /// Start: 2026-11-11 00:00 in Tehran (UTC+03:30).
  final DateTime base = DateTime.utc(2026, 11, 10, 20, 30);

  /// Wall-clock shift applied on top of the passage of (fake) time.
  Duration jump = Duration.zero;

  late final RecordingDispatcher dispatcher;
  final StreamController<PowerEvent> power = StreamController.broadcast();
  late ProviderContainer container;

  DateTime wall() => base.add(async.elapsed).add(jump);

  void start() {
    container = ProviderContainer(
      overrides: [
        locationRepositoryProvider.overrideWithValue(repo),
        systemClockProvider.overrideWithValue(Clock(wall)),
        monotonicClockProvider.overrideWithValue(() => async.elapsed),
        eventDispatcherProvider.overrideWithValue(dispatcher),
        handledEventsStoreProvider.overrideWithValue(handled),
        powerEventsProvider.overrideWithValue(SimPower(power.stream)),
        initialSettingsProvider.overrideWithValue(initial),
      ],
    )..read(scheduleEngineProvider);
    async.flushMicrotasks();
  }

  void dispose() {
    container.dispose();
    unawaited(power.close());
  }

  /// Local clock time in Tehran of the current wall time.
  String local() {
    final t = wall().add(const Duration(hours: 3, minutes: 30));
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  /// Moves (fake) time forward to local [hour]:[minute] of 2026-11-11.
  void advanceTo(int hour, int minute, {int second = 0}) {
    final target = base.add(
      Duration(hours: hour, minutes: minute, seconds: second),
    );
    async
      ..elapse(target.difference(wall()))
      ..flushMicrotasks();
  }
}

class SimPower implements PowerEvents {
  SimPower(this.events);
  @override
  final Stream<PowerEvent> events;
}
