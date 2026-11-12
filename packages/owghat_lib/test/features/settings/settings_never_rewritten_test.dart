import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/platform/power_events.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/sim_world.dart';
import '../../support/test_data.dart';

/// Regression guard: the previous version of the app rewrote the "daylight
/// saving" dropdown from its own tables every second, undoing the user's
/// choice. Here only SettingsController methods called from a user action may
/// change settings. Never delete or weaken this test.
void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  String snapshot(SimWorld w) =>
      jsonEncode(w.container.read(settingsProvider).toJson());

  test('after the user picks a fixed offset nothing ever rewrites it', () {
    fakeAsync((async) {
      final w = SimWorld(async, repo)..start();
      addTearDown(w.dispose);

      // The one and only user action.
      final settings = w.container.read(settingsProvider.notifier);
      expect(
        settings.setLocationOffset('city:1', const LocationOffset.fixed(210)),
        isNull,
      );
      async.flushMicrotasks();
      final chosen = snapshot(w);
      expect(
        w.container.read(settingsProvider).activeLocation.offset.fixedMinutes,
        210,
      );

      // 30 simulated days of ticks, rollovers and rebuilds.
      for (var hour = 0; hour < 30 * 24; hour++) {
        async.elapse(const Duration(hours: 1));
        async.flushMicrotasks();
      }
      expect(snapshot(w), chosen, reason: 'after 30 days of engine ticks');

      // App restart: a new container over the same persisted settings.
      final restarted = SimWorld(
        async,
        repo,
        settings: w.container.read(settingsProvider),
      )..start();
      addTearDown(restarted.dispose);
      async.flushMicrotasks();
      expect(
        jsonEncode(restarted.container.read(settingsProvider).toJson()),
        chosen,
        reason: 'after a restart',
      );

      // Resume from sleep, clock changes, a location reload.
      w.power
        ..add(PowerEvent.resumed)
        ..add(PowerEvent.timeChanged);
      async.flushMicrotasks();
      w.container.invalidate(scheduleEngineProvider);
      w.container.read(scheduleEngineProvider);
      async.flushMicrotasks();
      expect(snapshot(w), chosen, reason: 'after resume and clock changes');
    });
  });

  test('the default Tehran location stays on the database offset', () {
    fakeAsync((async) {
      final w = SimWorld(async, repo)..start();
      addTearDown(w.dispose);
      final before = snapshot(w);
      for (var day = 0; day < 400; day++) {
        async.elapse(const Duration(days: 1));
        async.flushMicrotasks();
      }
      expect(snapshot(w), before);
      final offset = w.container.read(settingsProvider).activeLocation.offset;
      expect(offset.mode, OffsetMode.automatic);
      expect(offset.fixedMinutes, isNull);
    });
  });

  test('Tehran prayers keep their local time across the old DST dates', () {
    // 400 simulated days include 21 March and 22 September 2027.
    fakeAsync((async) {
      final w = SimWorld(async, repo)..start();
      addTearDown(w.dispose);
      final fajrs = <String, DateTime>{};
      for (var day = 0; day < 400; day++) {
        async.elapse(const Duration(days: 1));
        async.flushMicrotasks();
      }
      for (final c in w.dispatcher.azans()) {
        if (c.event.prayer == Prayer.dhuhr) {
          fajrs[c.event.date.iso] = c.event.instantUtc;
        }
      }
      DateTime dhuhr(String iso) => fajrs[iso]!;
      // Local Dhuhr moves by seconds per day, never by an hour.
      final march20 = dhuhr('2027-03-20')
          .add(const Duration(hours: 3, minutes: 30));
      final march22 = dhuhr('2027-03-22')
          .add(const Duration(hours: 3, minutes: 30));
      expect(
        (march22.hour * 60 + march22.minute) -
            (march20.hour * 60 + march20.minute),
        inInclusiveRange(-3, 3),
      );
    });
  });
}
