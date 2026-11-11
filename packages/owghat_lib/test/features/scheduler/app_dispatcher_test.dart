import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/platform/app_notifier.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/scheduler/application/wake_alarm_hook.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/platform_world.dart';
import '../../support/test_data.dart';

void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  Future<void> dispatch(
    PlatformWorld w,
    ScheduledEvent event,
    CatchUpDecision decision,
  ) => w.read(eventDispatcherProvider).dispatch(event, decision);

  /// A world whose clock is at [at] (Tehran time of day).
  PlatformWorld worldAt(int hour, int minute, {AppSettings? settings}) {
    final w = PlatformWorld(
      repo,
      settings: settings,
      now: PlatformWorld.tehran(hour, minute),
    );
    addTearDown(w.dispose);
    return w;
  }

  group('azan', () {
    test(
      'fire: plays the azan and shows the toast with a Stop button',
      () async {
        final w = worldAt(11, 48);
        await dispatch(
          w,
          w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
          CatchUpDecision.fire,
        );
        expect(w.audio.plays.single.sound, SoundRef.defaultAzan);
        expect(w.audio.plays.single.volume, closeTo(0.6, 1e-9));
        final toast = w.notifier.shown.single;
        expect(toast.title, 'اذان ظهر');
        expect(toast.body, 'تهران · ۱۱:۴۸');
        expect(toast.buttons.single.kind, NotificationActionKind.stop);
        expect(toast.buttons.single.label, 'توقف');
        expect(w.read(azanPlaybackProvider).prayer, Prayer.dhuhr);
      },
    );

    test('fireLate: still plays, and the toast shows the azan time', () async {
      final w = worldAt(11, 50);
      await dispatch(
        w,
        w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
        CatchUpDecision.fireLate,
      );
      expect(w.audio.plays, hasLength(1));
      expect(w.notifier.shown.single.body, 'تهران · ۱۱:۴۸');
    });

    test('notifyMissed: a quiet toast, no sound', () async {
      final w = worldAt(17, 0);
      await dispatch(
        w,
        w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
        CatchUpDecision.notifyMissed,
      );
      expect(w.audio.plays, isEmpty);
      final toast = w.notifier.shown.single;
      expect(toast.title, 'اذان ظهر پخش نشد');
      expect(toast.body, 'رایانه در ساعت ۱۱:۴۸ در حالت خواب بود.');
      expect(toast.buttons, isEmpty);
      expect(toast.silent, isTrue);
    });

    for (final decision in [
      CatchUpDecision.drop,
      CatchUpDecision.notYetDue,
      CatchUpDecision.alreadyHandled,
    ]) {
      test('$decision: does nothing at all', () async {
        final w = worldAt(11, 48);
        await dispatch(
          w,
          w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
          decision,
        );
        expect(w.audio.plays, isEmpty);
        expect(w.notifier.shown, isEmpty);
      });
    }

    test('muted: no sound, a toast without Stop', () async {
      final w = worldAt(
        11,
        48,
        settings: AppSettings(
          azan: AzanSettings(
            mute: MuteSetting(until: PlatformWorld.tehran(13, 0)),
          ),
        ),
      );
      await dispatch(
        w,
        w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
        CatchUpDecision.fire,
      );
      expect(w.audio.plays, isEmpty);
      final toast = w.notifier.shown.single;
      expect(toast.title, 'اذان ظهر');
      expect(toast.buttons, isEmpty);
    });

    test('a mute that has run out no longer mutes', () async {
      final w = worldAt(
        14,
        0,
        settings: AppSettings(
          azan: AzanSettings(
            mute: MuteSetting(until: PlatformWorld.tehran(13, 0)),
          ),
        ),
      );
      await dispatch(
        w,
        w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
        CatchUpDecision.fireLate,
      );
      expect(w.audio.plays, hasLength(1));
    });

    test('master switch off: silent and no toast', () async {
      final w = worldAt(
        11,
        48,
        settings: const AppSettings(azan: AzanSettings(enabled: false)),
      );
      await dispatch(
        w,
        w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
        CatchUpDecision.fire,
      );
      expect(w.audio.plays, isEmpty);
      expect(w.notifier.shown, isEmpty);
    });

    test('a prayer whose azan is off is not played', () async {
      final w = worldAt(15, 0);
      await dispatch(
        w,
        w.azanEvent(Prayer.asr, hour: 15, minute: 0),
        CatchUpDecision.fire,
      );
      expect(w.audio.plays, isEmpty);
      expect(w.notifier.shown, isEmpty);
    });

    test('English with Latin digits and the 12-hour clock', () async {
      final w = worldAt(
        17,
        20,
        settings: const AppSettings(
          language: AppLanguage.en,
          digits: DigitStyle.latin,
          hourFormat: HourFormat.h12,
        ),
      );
      await dispatch(
        w,
        w.azanEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fire,
      );
      final toast = w.notifier.shown.single;
      expect(toast.title, 'Maghrib azan');
      expect(toast.body, 'Tehran · 5:20 PM');
      expect(toast.buttons.single.label, 'Stop');
    });
  });

  group('reminder', () {
    test('fire: quiet toast with the lead time, and the chime', () async {
      final w = worldAt(17, 10);
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fire,
      );
      final toast = w.notifier.shown.single;
      expect(toast.title, '۱۰ دقیقه تا اذان مغرب');
      expect(toast.body, 'تهران · ساعت ۱۷:۲۰');
      expect(toast.silent, isTrue);
      expect(toast.buttons, isEmpty);
      expect(w.audio.plays.single.sound, SoundRef.chime);
      expect(w.read(azanPlaybackProvider).playing, isFalse);
    });

    test('fireLate: shows the true remaining time', () async {
      // The reminder was due at 17:10 but the PC woke at 17:14.
      final w = worldAt(17, 14);
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fireLate,
      );
      expect(w.notifier.shown.single.title, '۶ دقیقه تا اذان مغرب');
    });

    test('remaining time rounds up to whole minutes', () async {
      final w = PlatformWorld(
        repo,
        now: PlatformWorld.tehran(17, 14, second: 30),
      );
      addTearDown(w.dispose);
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fireLate,
      );
      expect(w.notifier.shown.single.title, '۶ دقیقه تا اذان مغرب');
    });

    test('chime switched off: toast only', () async {
      final w = worldAt(
        17,
        10,
        settings: const AppSettings(reminders: ReminderSettings(chime: false)),
      );
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fire,
      );
      expect(w.notifier.shown, hasLength(1));
      expect(w.audio.plays, isEmpty);
    });

    test('muted: toast but no chime', () async {
      final w = worldAt(
        17,
        10,
        settings: const AppSettings(
          azan: AzanSettings(mute: MuteSetting(indefinite: true)),
        ),
      );
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fire,
      );
      expect(w.notifier.shown, hasLength(1));
      expect(w.audio.plays, isEmpty);
    });

    test('the chime never cuts into a playing azan', () async {
      final w = worldAt(17, 10);
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.dhuhr);
      w.audio.plays.clear();
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fire,
      );
      expect(w.audio.plays, isEmpty);
      expect(w.notifier.shown, hasLength(1));
    });

    test('nothing is shown once the azan itself is due', () async {
      final w = worldAt(17, 21);
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fireLate,
      );
      expect(w.notifier.shown, isEmpty);
      expect(w.audio.plays, isEmpty);
    });

    test('drop: nothing', () async {
      final w = worldAt(17, 30);
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.drop,
      );
      expect(w.notifier.shown, isEmpty);
    });
  });

  group('wake-up alarm and day rollover', () {
    ScheduledEvent wake(PlatformWorld w) => ScheduledEvent(
      kind: EventKind.wakeAlarm,
      instantUtc: w.now,
      date: CivilDate(2026, 11, 11),
      alarmId: 'a1',
    );

    test('fire and fireLate are forwarded to the wake-up handler', () async {
      final received = <ScheduledEvent>[];
      final w = PlatformWorld(
        repo,
        extra: [
          wakeAlarmHandlerProvider.overrideWithValue((event) async {
            received.add(event);
          }),
        ],
      );
      addTearDown(w.dispose);
      await dispatch(w, wake(w), CatchUpDecision.fire);
      await dispatch(w, wake(w), CatchUpDecision.fireLate);
      await dispatch(w, wake(w), CatchUpDecision.drop);
      expect(received, hasLength(2));
      expect(w.notifier.shown, isEmpty);
    });

    test('the default handler does nothing and does not throw', () async {
      final w = worldAt(7, 0);
      await dispatch(w, wake(w), CatchUpDecision.fire);
      expect(w.notifier.shown, isEmpty);
    });

    test('a failing handler never escapes', () async {
      final w = PlatformWorld(
        repo,
        extra: [
          wakeAlarmHandlerProvider.overrideWithValue(
            (event) async => throw StateError('boom'),
          ),
        ],
      );
      addTearDown(w.dispose);
      await dispatch(w, wake(w), CatchUpDecision.fire);
    });

    test('day rollover is left to the engine', () async {
      final w = worldAt(0, 0);
      await dispatch(
        w,
        ScheduledEvent(
          kind: EventKind.dayRollover,
          instantUtc: w.now,
          date: CivilDate(2026, 11, 11),
        ),
        CatchUpDecision.fire,
      );
      expect(w.notifier.shown, isEmpty);
      expect(w.audio.plays, isEmpty);
    });
  });

  group('failure paths', () {
    test(
      'audio throws: the toast is still shown, with a notice, no Stop',
      () async {
        final w = worldAt(11, 48);
        w.audio.failAll = true;
        await dispatch(
          w,
          w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
          CatchUpDecision.fire,
        );
        expect(w.notifier.shown, hasLength(2));
        expect(w.notifier.shown.first.title, 'اذان ظهر');
        expect(w.notifier.shown.first.buttons, isEmpty);
        expect(w.notifier.shown.last.body, 'پخش اذان ممکن نشد.');
        expect(w.read(azanPlaybackProvider).playing, isFalse);
      },
    );

    test(
      'a missing user file falls back to the default azan with a notice',
      () async {
        const missing = SoundRef.file('C:/gone/azan.mp3');
        final w = worldAt(
          11,
          48,
          settings: const AppSettings(
            azan: AzanSettings(
              perPrayer: {
                Prayer.fajr: PrayerAzan(enabled: true),
                Prayer.dhuhr: PrayerAzan(enabled: true, sound: missing),
                Prayer.asr: PrayerAzan(),
                Prayer.maghrib: PrayerAzan(enabled: true),
                Prayer.isha: PrayerAzan(),
              },
            ),
          ),
        );
        w.audio.failing.add(missing);
        await dispatch(
          w,
          w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
          CatchUpDecision.fire,
        );
        expect(w.audio.plays.last.sound, SoundRef.defaultAzan);
        expect(w.notifier.shown.first.buttons, hasLength(1)); // still playing
        expect(
          w.notifier.shown.last.body,
          'فایل صدای اذان پیدا نشد؛ صدای پیش\u200cفرض پخش شد.',
        );
      },
    );

    test(
      'the notifier throws: the azan still plays and nothing escapes',
      () async {
        final w = worldAt(11, 48);
        w.notifier.failAll = true;
        await dispatch(
          w,
          w.azanEvent(Prayer.dhuhr, hour: 11, minute: 48),
          CatchUpDecision.fire,
        );
        expect(w.audio.plays, hasLength(1));
      },
    );

    test('everything throws: still nothing escapes', () async {
      final w = worldAt(17, 10);
      w.audio.failAll = true;
      w.notifier.failAll = true;
      await dispatch(
        w,
        w.azanEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fire,
      );
      await dispatch(
        w,
        w.reminderEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.fire,
      );
      await dispatch(
        w,
        w.azanEvent(Prayer.maghrib, hour: 17, minute: 20),
        CatchUpDecision.notifyMissed,
      );
    });
  });
}
