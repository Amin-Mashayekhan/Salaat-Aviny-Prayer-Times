import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/platform/power_events.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/scheduler/application/schedule_engine.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/scheduler/domain/event_dispatcher.dart';
import 'package:owghat_lib/src/features/scheduler/domain/handled_events_store.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/sim_world.dart';
import '../../support/test_data.dart';

void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  /// Tehran, 2026-11-11 (default settings): Fajr 05:10, Dhuhr 11:48,
  /// Maghrib 17:20; reminders 10 minutes before.
  void inWorld(
    String name,
    void Function(SimWorld w, FakeAsync async) body, {
    HandledEventsStore? handled,
    AppSettings? settings,
  }) {
    test(name, () {
      fakeAsync((async) {
        final world = SimWorld(
          async,
          repo,
          handled: handled,
          settings: settings,
        );
        addTearDown(world.dispose);
        world.start();
        body(world, async);
      });
    });
  }

  group('normal running', () {
    inWorld('plays each enabled azan once at its minute, with reminders', (
      w,
      async,
    ) {
      w.advanceTo(5, 9);
      expect(w.dispatcher.calls.map((c) => c.id), ['reminder:fajr:2026-11-11']);
      w.advanceTo(5, 10, second: 1);
      expect(w.dispatcher.azans().map((c) => c.id), ['azan:fajr:2026-11-11']);
      final fajr = w.dispatcher.azans().single;
      expect(fajr.decision, CatchUpDecision.fire);
      // It happened at 05:10:00 local, within one second.
      expect(
        fajr.at.difference(DateTime.utc(2026, 11, 11, 1, 40)).inSeconds.abs(),
        lessThanOrEqualTo(1),
      );
      w.advanceTo(23, 0);
      expect(w.dispatcher.azans().map((c) => c.id), [
        'azan:fajr:2026-11-11',
        'azan:dhuhr:2026-11-11',
        'azan:maghrib:2026-11-11',
      ]);
    });

    inWorld('a failing dispatcher never stops the schedule', (w, async) {
      w.dispatcher.failWith = Exception('audio device busy');
      w.advanceTo(12, 0);
      expect(w.dispatcher.azans().length, 2); // fajr and dhuhr both tried
      w.dispatcher.failWith = null;
      w.advanceTo(18, 0);
      expect(w.dispatcher.azans().length, 3);
    });
  });

  group('(a) thirty simulated days', () {
    inWorld('exactly one azan per enabled prayer per day, none duplicated', (
      w,
      async,
    ) {
      // 30 local days from 2026-11-11 00:00.
      for (var hour = 0; hour < 30 * 24; hour++) {
        async.elapse(const Duration(hours: 1));
        async.flushMicrotasks();
      }
      final ids = [for (final c in w.dispatcher.azans()) c.id];
      expect(ids.toSet().length, ids.length, reason: 'no duplicates');
      for (var day = 0; day < 30; day++) {
        final date = CivilDate(2026, 11, 11).addDays(day).iso;
        for (final prayer in ['fajr', 'dhuhr', 'maghrib']) {
          expect(ids, contains('azan:$prayer:$date'), reason: '$prayer $date');
        }
        expect(ids, isNot(contains('azan:asr:$date')));
        expect(ids, isNot(contains('azan:isha:$date')));
      }
      expect(w.dispatcher.azans().length, 90);
      expect(
        w.dispatcher.azans().every((c) => c.decision == CatchUpDecision.fire),
        isTrue,
      );
    });
  });

  group('(b) sleeping through an azan', () {
    inWorld('six hours asleep across Dhuhr gives one missed notice, no azan', (
      w,
      async,
    ) {
      w.advanceTo(8, 0);
      expect(w.dispatcher.azans().length, 1); // fajr
      w.jump += const Duration(
        hours: 6,
      ); // the PC slept; wall moved, time did not
      w.power.add(PowerEvent.resumed);
      async.flushMicrotasks();
      expect(w.local(), '14:00');
      final missed = w.dispatcher.azans(CatchUpDecision.notifyMissed);
      expect(missed.map((c) => c.id), ['azan:dhuhr:2026-11-11']);
      expect(w.dispatcher.azans(CatchUpDecision.fireLate), isEmpty);
      // A reminder for an azan that is already past is dropped silently.
      expect(
        w.dispatcher.calls.where(
          (c) =>
              c.event.kind == EventKind.reminder &&
              c.event.prayer == Prayer.dhuhr,
        ),
        isEmpty,
      );
    });

    inWorld('a short nap of 90 seconds still plays the azan, late', (w, async) {
      w.advanceTo(11, 47, second: 30);
      expect(w.dispatcher.azans().length, 1);
      w.jump += const Duration(seconds: 90);
      w.power.add(PowerEvent.resumed);
      async.flushMicrotasks();
      final late = w.dispatcher.azans(CatchUpDecision.fireLate);
      expect(late.map((c) => c.id), ['azan:dhuhr:2026-11-11']);
    });

    inWorld('after a long sleep only the latest azan may still play', (
      w,
      async,
    ) {
      w.advanceTo(4, 0);
      // Sleep from 04:00 to 17:21: Fajr, Dhuhr and Maghrib were all missed.
      w.jump += const Duration(hours: 13, minutes: 21);
      w.power.add(PowerEvent.resumed);
      async.flushMicrotasks();
      expect(w.dispatcher.azans(CatchUpDecision.fireLate).map((c) => c.id), [
        'azan:maghrib:2026-11-11',
      ]);
      expect(
        w.dispatcher.azans(CatchUpDecision.notifyMissed).map((c) => c.id),
        ['azan:fajr:2026-11-11', 'azan:dhuhr:2026-11-11'],
      );
    });
  });

  group('(d)(e) clock changes', () {
    inWorld('setting the clock back one hour never replays an azan', (
      w,
      async,
    ) {
      w.advanceTo(12, 0);
      final before = w.dispatcher.azans().length;
      expect(before, 2);
      w.jump -= const Duration(hours: 1);
      w.power.add(PowerEvent.timeChanged);
      async.flushMicrotasks();
      expect(w.dispatcher.azans().length, before);
      w.advanceTo(12, 30);
      expect(w.dispatcher.azans().length, before);
    });

    inWorld('setting the clock forward follows the catch-up table', (w, async) {
      w.advanceTo(16, 30);
      expect(w.dispatcher.azans().length, 2);
      w.jump += const Duration(hours: 1); // now 17:30, Maghrib was 17:20
      w.power.add(PowerEvent.timeChanged);
      async.flushMicrotasks();
      expect(
        w.dispatcher.azans(CatchUpDecision.notifyMissed).map((c) => c.id),
        ['azan:maghrib:2026-11-11'],
      );
    });

    inWorld('the watchdog notices a jump even without a system event', (
      w,
      async,
    ) {
      w.advanceTo(16, 30);
      w.jump += const Duration(hours: 1);
      async.elapse(const Duration(seconds: 16)); // one watchdog tick
      async.flushMicrotasks();
      expect(
        w.dispatcher.azans(CatchUpDecision.notifyMissed).map((c) => c.id),
        ['azan:maghrib:2026-11-11'],
      );
    });
  });

  group('(f) restart', () {
    test('an app restarted one minute after an azan does not replay it', () {
      fakeAsync((async) {
        final store = InMemoryHandledEventsStore();
        final first = SimWorld(async, repo, handled: store)..start();
        first.advanceTo(11, 48, second: 5);
        expect(first.dispatcher.azans().map((c) => c.id), [
          'azan:fajr:2026-11-11',
          'azan:dhuhr:2026-11-11',
        ]);
        first.dispose();

        async.elapse(const Duration(minutes: 1));
        final second = SimWorld(async, repo, handled: store);
        // A fresh world shares the same fake clock and the persisted store.
        second.start();
        async.flushMicrotasks();
        expect(second.dispatcher.azans(), isEmpty);
        second.advanceTo(17, 21);
        expect(second.dispatcher.azans().map((c) => c.id), [
          'azan:maghrib:2026-11-11',
        ]);
        second.dispose();
      });
    });

    test('a cold start never announces old missed azans', () {
      fakeAsync((async) {
        async.elapse(
          const Duration(hours: 14),
        ); // it is 14:00 when the app starts
        final w = SimWorld(async, repo)..start();
        async.flushMicrotasks();
        // Fajr and Dhuhr are long past: dropped quietly, no notice, no sound.
        expect(w.dispatcher.azans(), isEmpty);
        w.dispose();
      });
    });

    test('a cold start within the grace period plays the azan late', () {
      fakeAsync((async) {
        async.elapse(const Duration(hours: 11, minutes: 49));
        final w = SimWorld(async, repo)..start();
        async.flushMicrotasks();
        expect(w.dispatcher.azans(CatchUpDecision.fireLate).map((c) => c.id), [
          'azan:dhuhr:2026-11-11',
        ]);
        w.dispose();
      });
    });
  });

  group('(g) settings changes', () {
    inWorld('disabling an azan mid-day removes only future events', (w, async) {
      w.advanceTo(12, 0);
      expect(w.dispatcher.azans().length, 2);
      w.container
          .read(settingsProvider.notifier)
          .setPrayerAzan(Prayer.maghrib, const PrayerAzan());
      async.flushMicrotasks();
      w.advanceTo(18, 0);
      expect(w.dispatcher.azans().map((c) => c.event.prayer), [
        Prayer.fajr,
        Prayer.dhuhr,
      ]);
    });

    inWorld('enabling Asr mid-day schedules it', (w, async) {
      w.advanceTo(12, 0);
      w.container
          .read(settingsProvider.notifier)
          .setPrayerAzan(Prayer.asr, const PrayerAzan(enabled: true));
      async.flushMicrotasks();
      w.advanceTo(15, 0);
      expect(
        w.dispatcher.azans().map((c) => c.event.prayer),
        contains(Prayer.asr),
      );
    });

    inWorld('handled events stay handled when settings change', (w, async) {
      w.advanceTo(12, 0);
      final before = w.dispatcher.azans().length;
      w.container.read(settingsProvider.notifier).setHourFormat(HourFormat.h12);
      async.flushMicrotasks();
      expect(w.dispatcher.azans().length, before);
    });
  });

  group('rollover and the engine itself', () {
    inWorld('the next day is scheduled by the rollover without a restart', (
      w,
      async,
    ) {
      w.advanceTo(23, 59);
      async.elapse(const Duration(hours: 6)); // into 2026-11-12, past Fajr
      async.flushMicrotasks();
      expect(
        w.dispatcher.azans().map((c) => c.id),
        contains('azan:fajr:2026-11-12'),
      );
    });

    inWorld('the engine exposes its sorted events', (w, async) {
      final engine = w.container.read(scheduleEngineProvider);
      final events = engine.events;
      expect(events, isNotEmpty);
      for (var i = 1; i < events.length; i++) {
        expect(
          events[i].instantUtc.isBefore(events[i - 1].instantUtc),
          isFalse,
        );
      }
    });
  });

  test('ScheduleEngine can be used without Riverpod', () {
    fakeAsync((async) {
      final calls = <String>[];
      final base = DateTime.utc(2026);
      final events = [
        ScheduledEvent(
          kind: EventKind.azan,
          instantUtc: base.add(const Duration(minutes: 5)),
          date: CivilDate(2026, 1, 1),
          prayer: Prayer.fajr,
        ),
      ];
      final engine = ScheduleEngine(
        clock: Clock(() => base.add(async.elapsed)),
        buildEvents: () => events,
        dispatcher: _FnDispatcher((e, d) => calls.add('${e.id}/${d.name}')),
        handled: InMemoryHandledEventsStore(),
        monotonic: () => async.elapsed,
      );
      unawaited(engine.start());
      async.elapse(const Duration(minutes: 6));
      expect(calls, ['azan:fajr:2026-01-01/fire']);
      engine.dispose();
    });
  });
}

class _FnDispatcher implements ScheduleDispatcher {
  _FnDispatcher(this._fn);
  final void Function(ScheduledEvent, CatchUpDecision) _fn;

  @override
  Future<void> dispatch(ScheduledEvent event, CatchUpDecision decision) async =>
      _fn(event, decision);
}
