import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/platform/power_events.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/scheduler/domain/event_dispatcher.dart';
import 'package:owghat_lib/src/features/scheduler/domain/handled_events_store.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_providers.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_plan_providers.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/fake_wake_services.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_countdown_state.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_services.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/test_data.dart';

/// Forwards wake-up events to the wake-up feature, like the real dispatcher.
class _Dispatcher implements ScheduleDispatcher {
  _Dispatcher(this.ref);
  final Ref ref;
  final List<String> ids = [];

  @override
  Future<void> dispatch(ScheduledEvent event, CatchUpDecision decision) async {
    ids.add(event.id);
    if (event.kind == EventKind.wakeAlarm) {
      await ref.read(wakeAlarmEventHandlerProvider)(event);
    }
  }
}

/// A test world: fake time starting at 2026-11-11 00:00 Tehran, the real
/// schedule engine and wake feature, fake platform services.
class _World {
  _World(this.async, this.repo, {List<WakeAlarm> alarms = const []})
    : initial = const AppSettings.defaults().copyWith(wakeAlarms: alarms);

  final FakeAsync async;
  final LocationRepository repo;
  final AppSettings initial;
  final DateTime base = DateTime.utc(2026, 11, 10, 20, 30);
  final StreamController<PowerEvent> power = StreamController.broadcast();
  final wake = FakeWakeTimerService();
  final powerControl = FakePowerControl();
  final player = FakeAlarmSoundPlayer();
  final handled = InMemoryHandledEventsStore();
  late final ProviderContainer container;
  late final _Dispatcher dispatcher;

  /// Shifts the wall clock without time passing for timers (a PC that slept).
  Duration jump = Duration.zero;

  DateTime wall() => base.add(async.elapsed).add(jump);

  /// Tehran local time (UTC+03:30) of 2026-11-11 [h]:[m] as UTC.
  DateTime at(int h, int m, [int s = 0, int day = 11]) => DateTime.utc(
    2026,
    11,
    day,
    h,
    m,
    s,
  ).subtract(const Duration(hours: 3, minutes: 30));

  void start() {
    container = ProviderContainer(
      overrides: [
        locationRepositoryProvider.overrideWithValue(repo),
        systemClockProvider.overrideWithValue(Clock(wall)),
        monotonicClockProvider.overrideWithValue(() => async.elapsed),
        eventDispatcherProvider.overrideWith((ref) {
          return dispatcher = _Dispatcher(ref);
        }),
        handledEventsStoreProvider.overrideWithValue(handled),
        powerEventsProvider.overrideWithValue(_Power(power.stream)),
        initialSettingsProvider.overrideWithValue(initial),
        wakeTimerServiceProvider.overrideWithValue(wake),
        powerControlProvider.overrideWithValue(powerControl),
        alarmSoundPlayerProvider.overrideWithValue(player),
      ],
    )..read(scheduleEngineProvider);
    container.read(wakeAlarmControllerProvider);
    flush();
  }

  void dispose() {
    container.dispose();
    unawaited(power.close());
  }

  /// Riverpod refreshes providers in a zero-length timer, so microtasks alone
  /// are not enough.
  void flush() {
    for (var i = 0; i < 3; i++) {
      async
        ..flushMicrotasks()
        ..elapse(Duration.zero);
    }
    async.flushMicrotasks();
  }

  /// Moves fake time to local [h]:[m]:[s] of the 11th.
  void advanceTo(int h, int m, [int s = 0]) {
    async.elapse(at(h, m, s).difference(wall()));
    flush();
  }

  void elapse(Duration d) {
    async.elapse(d);
    flush();
  }

  WakeAlarmController get controller =>
      container.read(wakeAlarmControllerProvider.notifier);
  WakeAlarmState get state => container.read(wakeAlarmControllerProvider);
  AppSettings get settings => container.read(settingsProvider);
  WakeCountdownState get countdown => container.read(wakeCountdownProvider);
}

class _Power implements PowerEvents {
  _Power(this.events);
  @override
  final Stream<PowerEvent> events;
}

void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  void inWorld(
    String name,
    void Function(_World w) body, {
    List<WakeAlarm> alarms = const [],
    void Function(_World w)? beforeStart,
  }) {
    test(name, () {
      fakeAsync((async) {
        final world = _World(async, repo, alarms: alarms);
        addTearDown(world.dispose);
        beforeStart?.call(world);
        world.start();
        body(world);
      });
    });
  }

  const daily4 = WakeAlarm(id: 'a1', afterSound: AfterSound.sleep);
  const lead = WakeTimings.wakeLead;

  group('engine integration', () {
    inWorld('enabled alarms reach the schedule engine', (w) {
      final engine = w.container.read(scheduleEngineProvider);
      final wakeEvents = engine.events.where(
        (e) => e.kind == EventKind.wakeAlarm,
      );
      expect(wakeEvents.map((e) => e.id), contains('wakeAlarm:a1:2026-11-11'));
      expect(wakeEvents.first.instantUtc, w.at(4, 0));
    }, alarms: [daily4]);

    inWorld('no alarms: the occurrence list stays empty and cheap', (w) {
      expect(w.container.read(alarmOccurrencesProvider), isEmpty);
    });

    inWorld('adding an alarm at run time reaches the engine', (w) {
      expect(w.controller.addAlarm(daily4), isNull);
      w.flush();
      final engine = w.container.read(scheduleEngineProvider);
      expect(
        engine.events.any((e) => e.id == 'wakeAlarm:a1:2026-11-11'),
        isTrue,
      );
    });
  });

  group('re-arming the OS wake requests', () {
    inWorld('arms the next occurrence, 30 s early', (w) {
      expect(w.wake.scheduled, {'a1': w.at(4, 0).subtract(lead)});
      expect(w.state.armed, {'a1': w.at(4, 0).subtract(lead)});
    }, alarms: [daily4]);

    inWorld('re-arms for the next day after the alarm fires', (w) {
      w.advanceTo(4, 0, 1);
      expect(w.wake.scheduled, {'a1': w.at(4, 0, 0, 12).subtract(lead)});
      // The engine still fired exactly once.
      expect(w.dispatcher.ids.where((i) => i.startsWith('wakeAlarm')), [
        'wakeAlarm:a1:2026-11-11',
      ]);
    }, alarms: [daily4]);

    inWorld('a changed alarm replaces its wake request', (w) {
      w.controller.updateAlarm(daily4.copyWith(hour: 5, minute: 30));
      w.flush();
      expect(w.wake.scheduled, {'a1': w.at(5, 30).subtract(lead)});
    }, alarms: [daily4]);

    inWorld('disabling cancels the wake request', (w) {
      expect(w.wake.scheduled, isNotEmpty);
      expect(w.controller.setEnabled('a1', enabled: false), isNull);
      w.flush();
      expect(w.wake.scheduled, isEmpty);
      expect(w.wake.log, contains('cancel:a1'));
      expect(w.state.armed, isEmpty);
      // Enabling again brings it back.
      w.controller.setEnabled('a1', enabled: true);
      w.flush();
      expect(w.wake.scheduled, hasLength(1));
    }, alarms: [daily4]);

    inWorld('deleting cancels the wake request and the setting', (w) {
      expect(w.controller.deleteAlarm('a1'), isNull);
      w.flush();
      expect(w.wake.scheduled, isEmpty);
      expect(w.settings.wakeAlarms, isEmpty);
      expect(w.controller.deleteAlarm('a1'), SettingsFailure.notFound);
    }, alarms: [daily4]);

    inWorld(
      'a wake request left from an earlier run is removed, ours is kept',
      (w) {
        expect(w.wake.leftOver, isEmpty);
        expect(w.wake.scheduled.keys, ['a1']);
        expect(w.wake.log, contains('cancel:wake-old'));
      },
      alarms: [daily4],
      beforeStart: (w) => w.wake.leftOver.add('wake-old'),
    );

    inWorld('an alarm about to ring is not given an OS request', (w) {
      // 20 s before the alarm the 30 s lead would be in the past.
      w.advanceTo(3, 59, 40);
      w.controller.updateAlarm(daily4.copyWith(minute: 0));
      w.flush();
      expect(w.wake.scheduled, isEmpty);
    }, alarms: [daily4.copyWith(enabled: false)]);

    inWorld('failures to arm are surfaced and retried on the next change', (w) {
      expect(w.state.syncError, isNull);
      w.wake.failScheduleWith = Exception('Access is denied');
      w.controller.updateAlarm(daily4.copyWith(hour: 6));
      w.flush();
      expect(w.state.syncError, contains('Access is denied'));
      // The old request is still in place (at the old time) until it works.
      expect(w.wake.scheduled['a1'], w.at(4, 0).subtract(lead));
      w.wake.failScheduleWith = null;
      w.controller.updateAlarm(daily4.copyWith(hour: 6));
      w.flush();
      expect(w.state.syncError, isNull);
      expect(w.wake.scheduled['a1'], w.at(6, 0).subtract(lead));
    }, alarms: [daily4]);

    inWorld('resuming from sleep recomputes', (w) {
      w.advanceTo(2, 0);
      w.power.add(PowerEvent.resumed);
      w.flush();
      expect(w.wake.scheduled['a1'], w.at(4, 0).subtract(lead));
    }, alarms: [daily4]);
  });

  group('next wake-up for Home', () {
    inWorld('is the earliest enabled saved alarm, never the test alarm', (w) {
      expect(
        w.container.read(nextWakeOccurrenceProvider)!.instantUtc,
        w.at(4, 0),
      );
      w.controller.testInTwoMinutes();
      w.flush();
      expect(w.container.read(nextWakeOccurrenceProvider)!.alarmId, 'a1');
      w.controller.setEnabled('a1', enabled: false);
      w.flush();
      expect(w.container.read(nextWakeOccurrenceProvider), isNull);
    }, alarms: [daily4]);
  });

  group('capability probe', () {
    inWorld('is surfaced in the state and the provider', (w) {
      expect(w.state.capability, isNull);
      w.wake.capability = const WakeCapability(
        taskCreationOk: false,
        wakeTimersOnAc: WakeTimerPolicy.disabled,
        inProcessTimerOk: true,
      );
      unawaited(w.controller.probe());
      w.flush();
      expect(w.wake.probeCalls, 1);
      expect(w.state.capability!.taskCreationOk, isFalse);
      expect(w.container.read(wakeCapabilityProvider), w.state.capability);
      expect(
        w.state.capability!.issues,
        containsAll([
          WakeIssue.taskCreationFailed,
          WakeIssue.wakeTimersDisabledOnAc,
        ]),
      );
      expect(w.state.probing, isFalse);
    });

    inWorld('a probe that throws becomes a failed capability', (w) {
      // Replace the service result by throwing through a subclass.
      final failing = _ThrowingProbe();
      final c = ProviderContainer(
        overrides: [wakeTimerServiceProvider.overrideWithValue(failing)],
      );
      addTearDown(c.dispose);
      unawaited(c.read(wakeAlarmControllerProvider.notifier).probe());
      w.flush();
      final s = c.read(wakeAlarmControllerProvider);
      expect(s.problem, WakeProblem.probeFailed);
      expect(s.capability!.taskCreationOk, isFalse);
    });

    inWorld('opening the power options is passed through', (w) {
      unawaited(w.controller.openPowerOptions());
      w.flush();
      expect(w.wake.openCalls, 1);
    });
  });

  group('the alarm itself', () {
    inWorld('plays, holds the PC awake, then sleeps only after the countdown', (
      w,
    ) {
      w.advanceTo(4, 0, 1);
      expect(w.player.played.single, daily4.sound);
      expect(w.state.ringingAlarmId, 'a1');
      expect(w.wake.awakeHeld, isTrue);
      expect(w.countdown.active, isFalse);

      // Sound ends: the 30-second countdown starts.
      w.player.finish();
      w.flush();
      expect(w.countdown.active, isTrue);
      expect(w.countdown.kind, WakeCountdownKind.afterAlarm);
      expect(w.countdown.action, AfterSound.sleep);
      expect(w.countdown.total, const Duration(seconds: 30));
      expect(w.countdown.alarmId, 'a1');
      expect(w.powerControl.calls, isEmpty);

      w.elapse(const Duration(seconds: 10));
      expect(w.countdown.remaining, const Duration(seconds: 20));
      expect(w.powerControl.calls, isEmpty);
      w.elapse(const Duration(seconds: 19));
      expect(w.powerControl.calls, isEmpty, reason: '29 s: still waiting');
      w.elapse(const Duration(seconds: 1));
      expect(w.powerControl.calls, ['sleep']);
      expect(w.countdown.active, isFalse);
      expect(w.wake.awakeHeld, isFalse, reason: 'released before suspending');
    }, alarms: [daily4]);

    inWorld('hibernate is used for the hibernate action', (w) {
      w.controller.updateAlarm(
        daily4.copyWith(afterSound: AfterSound.hibernate),
      );
      w.advanceTo(4, 0, 1);
      w.player.finish();
      w.flush();
      expect(w.countdown.isHibernate, isTrue);
      w.elapse(const Duration(seconds: 30));
      expect(w.powerControl.calls, ['hibernate']);
    }, alarms: [daily4]);

    inWorld('cancelling the countdown keeps the PC awake and never suspends', (
      w,
    ) {
      w.advanceTo(4, 0, 1);
      w.player.finish();
      w.flush();
      w.elapse(const Duration(seconds: 12));
      w.controller.cancelCountdown();
      w.flush();
      expect(w.countdown.active, isFalse);
      expect(w.wake.awakeHeld, isTrue, reason: 'PC stays awake for the user');
      w.elapse(const Duration(minutes: 5));
      expect(w.powerControl.calls, isEmpty);
      expect(w.wake.awakeHeld, isTrue);
      // After the stay-awake window Windows may sleep by itself again.
      w.elapse(WakeTimings.stayAwakeAfter);
      expect(w.wake.awakeHeld, isFalse);
      expect(w.powerControl.calls, isEmpty);
    }, alarms: [daily4]);

    inWorld('no sound: the countdown starts at once', (w) {
      w.controller.updateAlarm(daily4.copyWith(playSound: false));
      w.advanceTo(4, 0, 1);
      expect(w.player.played, isEmpty);
      expect(w.countdown.active, isTrue);
      w.elapse(const Duration(seconds: 30));
      expect(w.powerControl.calls, ['sleep']);
    }, alarms: [daily4]);

    inWorld('afterSound nothing: no countdown, no suspend, brief hold', (w) {
      w.controller.updateAlarm(daily4.copyWith(afterSound: AfterSound.nothing));
      w.advanceTo(4, 0, 1);
      w.player.finish();
      w.flush();
      expect(w.countdown.active, isFalse);
      expect(w.powerControl.calls, isEmpty);
      expect(w.wake.awakeHeld, isTrue);
      w.elapse(WakeTimings.stayAwakeAfter);
      expect(w.wake.awakeHeld, isFalse);
    }, alarms: [daily4]);

    inWorld('stopping the sound still leaves the countdown cancellable', (w) {
      w.advanceTo(4, 0, 1);
      unawaited(w.controller.stopRinging());
      w.flush();
      expect(w.player.stops, 1);
      expect(w.countdown.active, isTrue);
      expect(w.powerControl.calls, isEmpty);
    }, alarms: [daily4]);

    inWorld('a missing sound falls back to the default', (w) {
      w.controller.updateAlarm(
        daily4.copyWith(sound: const SoundRef.file(r'C:\gone.mp3')),
      );
      w.player.failPlays = 1;
      w.advanceTo(4, 0, 1);
      expect(w.player.played.map((s) => s.encoded), [
        r'file:C:\gone.mp3',
        'asset:azan_default',
      ]);
      expect(w.state.ringingAlarmId, 'a1');
      w.player.finish();
      w.flush();
      expect(w.countdown.active, isTrue);
    }, alarms: [daily4]);

    inWorld('no sound at all: reported, and the PC is not put to sleep', (w) {
      w.player.failPlays = 2;
      w.advanceTo(4, 0, 1);
      expect(w.state.problem, WakeProblem.soundFailed);
      expect(w.countdown.active, isFalse);
      w.elapse(const Duration(minutes: 2));
      expect(w.powerControl.calls, isEmpty);
    }, alarms: [daily4]);

    inWorld('a refusal to sleep is reported, not thrown', (w) {
      w.powerControl.result = PowerResult.refused;
      w.advanceTo(4, 0, 1);
      w.player.finish();
      w.flush();
      w.elapse(const Duration(seconds: 30));
      expect(w.powerControl.calls, ['sleep']);
      expect(w.state.problem, WakeProblem.suspendRefused);
    }, alarms: [daily4]);

    inWorld('the engine is not blocked while the alarm rings', (w) {
      w.advanceTo(5, 0, 1);
      expect(w.player.playing, isTrue);
      // The sound is still playing at the Fajr azan (05:10 in Tehran).
      w.advanceTo(5, 11);
      expect(w.player.playing, isTrue);
      expect(w.dispatcher.ids, contains('reminder:fajr:2026-11-11'));
      expect(w.dispatcher.ids, contains('azan:fajr:2026-11-11'));
    }, alarms: [daily4.copyWith(hour: 5, afterSound: AfterSound.nothing)]);

    inWorld('a runaway sound is stopped after the maximum', (w) {
      w.advanceTo(4, 0, 1);
      w.elapse(WakeTimings.maxRing);
      expect(w.player.stops, 1);
      expect(w.player.playing, isFalse);
    }, alarms: [daily4]);

    inWorld('a second alarm takes over from a pending countdown', (w) {
      w.controller.addAlarm(const WakeAlarm(id: 'a2', minute: 1));
      w.advanceTo(4, 0, 1);
      w.advanceTo(4, 0, 50);
      w.player.finish();
      w.flush();
      expect(w.countdown.alarmId, 'a1');
      w.advanceTo(4, 1, 1);
      expect(w.state.ringingAlarmId, 'a2');
      expect(w.countdown.active, isFalse);
      // The old countdown would have ended at 04:01:20; nothing suspends.
      w.elapse(const Duration(seconds: 40));
      expect(w.powerControl.calls, isEmpty);
    }, alarms: [daily4]);

    inWorld('an event for a deleted alarm does nothing', (w) {
      final event = ScheduledEvent(
        kind: EventKind.wakeAlarm,
        instantUtc: w.at(4, 0),
        date: CivilDate(2026, 11, 11),
        alarmId: 'ghost',
      );
      unawaited(w.controller.handleWakeEvent(event));
      w.flush();
      expect(w.player.played, isEmpty);
      expect(w.state.ringingAlarmId, isNull);
      expect(w.wake.awakeHeld, isFalse);
    });

    inWorld('late by a few minutes it still runs (catch-up)', (w) {
      // The PC slept through the alarm and resumed at 04:05.
      w.jump = w.at(4, 5).difference(w.wall());
      w.power.add(PowerEvent.resumed);
      w.flush();
      expect(w.player.played, hasLength(1));
      expect(w.wake.scheduled['a1'], w.at(4, 0, 0, 12).subtract(lead));
    }, alarms: [daily4]);

    inWorld('more than ten minutes late it is dropped, tomorrow stays armed', (
      w,
    ) {
      w.jump = w.at(4, 40).difference(w.wall());
      w.power.add(PowerEvent.resumed);
      w.flush();
      expect(w.player.played, isEmpty);
      expect(w.wake.scheduled['a1'], w.at(4, 0, 0, 12).subtract(lead));
    }, alarms: [daily4]);
  });

  group('once alarms', () {
    const once = WakeAlarm(
      id: 'o1',
      repeat: AlarmRepeat.once,
      playSound: false,
    );

    inWorld(
      'disable themselves after firing, through the settings controller',
      (w) {
        expect(w.settings.wakeAlarms.single.enabled, isTrue);
        w.advanceTo(4, 0, 1);
        final saved = w.settings.wakeAlarms.single;
        expect(saved.enabled, isFalse);
        // Nothing else about the alarm changed.
        expect(
          saved.toJson()..remove('enabled'),
          once.toJson()..remove('enabled'),
        );
        // And its OS wake request is gone.
        expect(w.wake.scheduled, isEmpty);
        // It does not come back on later days.
        w.advanceTo(23, 0);
        expect(w.player.played, isEmpty);
        w.elapse(const Duration(days: 1, hours: 6));
        expect(
          w.dispatcher.ids.where((i) => i.startsWith('wakeAlarm:o1')),
          hasLength(1),
        );
      },
      alarms: [once],
    );

    inWorld('enabling it again lets it ring once more', (w) {
      w.advanceTo(4, 0, 1);
      expect(w.settings.wakeAlarms.single.enabled, isFalse);
      w.controller.setEnabled('o1', enabled: true);
      w.flush();
      expect(w.wake.scheduled['o1'], w.at(4, 0, 0, 12).subtract(lead));
    }, alarms: [once]);
  });

  group('sleep now and hibernate now', () {
    inWorld('sleep after a 5-second countdown', (w) {
      unawaited(w.controller.sleepNow());
      w.flush();
      expect(w.countdown.kind, WakeCountdownKind.sleepNow);
      expect(w.countdown.total, const Duration(seconds: 5));
      w.elapse(const Duration(seconds: 4));
      expect(w.countdown.remaining, const Duration(seconds: 1));
      expect(w.powerControl.calls, isEmpty);
      w.elapse(const Duration(seconds: 1));
      expect(w.powerControl.calls, ['sleep']);
      expect(w.countdown.active, isFalse);
    });

    inWorld('hibernate after a 5-second countdown', (w) {
      unawaited(w.controller.hibernateNow());
      w.flush();
      expect(w.countdown.kind, WakeCountdownKind.hibernateNow);
      expect(w.countdown.isHibernate, isTrue);
      w.elapse(const Duration(seconds: 5));
      expect(w.powerControl.calls, ['hibernate']);
    });

    inWorld('cancelling does not suspend and holds nothing', (w) {
      unawaited(w.controller.sleepNow());
      w.flush();
      w.elapse(const Duration(seconds: 3));
      w.controller.cancelCountdown();
      w.flush();
      expect(w.countdown.active, isFalse);
      w.elapse(const Duration(minutes: 1));
      expect(w.powerControl.calls, isEmpty);
      expect(w.wake.awakeHeld, isFalse);
    });

    inWorld('a second press restarts the countdown', (w) {
      unawaited(w.controller.sleepNow());
      w.flush();
      w.elapse(const Duration(seconds: 3));
      unawaited(w.controller.hibernateNow());
      w.flush();
      expect(w.countdown.kind, WakeCountdownKind.hibernateNow);
      w.elapse(const Duration(seconds: 4));
      expect(w.powerControl.calls, isEmpty);
      w.elapse(const Duration(seconds: 1));
      expect(w.powerControl.calls, ['hibernate']);
    });

    inWorld('hibernation switched off is reported', (w) {
      w.powerControl.result = PowerResult.unavailable;
      unawaited(w.controller.hibernateNow());
      w.flush();
      w.elapse(const Duration(seconds: 5));
      expect(w.state.problem, WakeProblem.hibernateUnavailable);
    });
  });

  group('test in two minutes', () {
    inWorld('arms the OS, rings once, and is not saved', (w) {
      final at = w.controller.testInTwoMinutes();
      w.flush();
      expect(at, w.wall().add(const Duration(minutes: 2)));
      expect(w.wake.scheduled.keys.single, startsWith('wake-test-'));
      expect(w.wake.scheduled.values.single, at.subtract(lead));
      expect(w.settings.wakeAlarms, isEmpty, reason: 'never written');

      w.elapse(const Duration(minutes: 2, seconds: 1));
      expect(w.player.played, hasLength(1));
      expect(w.wake.scheduled, isEmpty);
      // Plays and ends; no suspend.
      w.player.finish();
      w.flush();
      w.elapse(const Duration(minutes: 1));
      expect(w.powerControl.calls, isEmpty);
    });

    inWorld('can be repeated on the same day', (w) {
      w.controller.testInTwoMinutes();
      w.elapse(const Duration(minutes: 2, seconds: 1));
      w.player.finish();
      w.flush();
      w.controller.testInTwoMinutes();
      w.elapse(const Duration(minutes: 2, seconds: 1));
      expect(w.player.played, hasLength(2));
    });

    inWorld('can be cancelled', (w) {
      w.controller.testInTwoMinutes();
      w.flush();
      expect(w.wake.scheduled, hasLength(1));
      w.controller.cancelTest();
      w.flush();
      expect(w.wake.scheduled, isEmpty);
      w.elapse(const Duration(minutes: 3));
      expect(w.player.played, isEmpty);
    });
  });

  group('started by a wake task', () {
    inWorld('holds the PC awake for a short guard time', (w) {
      unawaited(w.controller.noteWakeLaunch('a1'));
      w.flush();
      expect(w.wake.awakeHeld, isTrue);
      w.elapse(WakeTimings.launchGuard);
      expect(w.wake.awakeHeld, isFalse);
    });
  });

  group('validation', () {
    inWorld('refuses unusable alarms and changes nothing', (w) {
      final c = w.controller;
      expect(c.addAlarm(const WakeAlarm(id: 'a b')), SettingsFailure.invalid);
      expect(c.addAlarm(const WakeAlarm(id: '')), SettingsFailure.invalid);
      expect(
        c.addAlarm(const WakeAlarm(id: 'x', minutesBefore: 721)),
        SettingsFailure.outOfRange,
      );
      expect(
        c.addAlarm(const WakeAlarm(id: 'x', volume: 1.5)),
        SettingsFailure.outOfRange,
      );
      expect(
        c.addAlarm(const WakeAlarm(id: 'x', repeat: AlarmRepeat.weekdays)),
        SettingsFailure.invalid,
      );
      expect(
        c.addAlarm(
          const WakeAlarm(id: 'x', repeat: AlarmRepeat.weekdays, weekdays: {8}),
        ),
        SettingsFailure.invalid,
      );
      expect(
        c.updateAlarm(const WakeAlarm(id: 'nope')),
        SettingsFailure.notFound,
      );
      expect(c.setEnabled('nope', enabled: true), SettingsFailure.notFound);
      expect(w.settings.wakeAlarms, isEmpty);
    });

    inWorld('duplicate ids are refused and new ids are unique and safe', (w) {
      expect(w.controller.addAlarm(const WakeAlarm(id: 'x')), isNull);
      expect(
        w.controller.addAlarm(const WakeAlarm(id: 'x')),
        SettingsFailure.duplicate,
      );
      final id = w.controller.newAlarmId();
      expect(RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*$').hasMatch(id), isTrue);
      expect(w.controller.addAlarm(WakeAlarm(id: id)), isNull);
      expect(w.controller.newAlarmId(), isNot(id));
    });
  });

  group('rules', () {
    inWorld('only SettingsController writes alarms and only on user actions', (
      w,
    ) {
      // Recalculation, date rollover and time passing never change settings.
      final before = w.settings;
      w.elapse(const Duration(days: 2));
      expect(identical(w.settings, before), isTrue);
    }, alarms: [daily4.copyWith(afterSound: AfterSound.nothing)]);
  });
}

class _ThrowingProbe extends NoWakeTimerService {
  @override
  Future<WakeCapability> probe() async => throw StateError('boom');
}
