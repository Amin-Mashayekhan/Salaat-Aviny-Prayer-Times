import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_simple_services.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_providers.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_labels.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/fake_wake_services.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_services.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/app_harness.dart';
import '../../support/test_data.dart';

// 20 Aban 1405, 15:30 in Tehran.
final _now = DateTime.utc(2026, 11, 11, 12);

/// A wake timer service whose probe the test releases by hand.
class _GatedWake extends FakeWakeTimerService {
  final Completer<WakeCapability> gate = Completer();

  @override
  Future<WakeCapability> probe() {
    probeCalls++;
    return gate.future;
  }
}

/// A wake timer service whose probe throws.
class _BrokenProbe extends FakeWakeTimerService {
  @override
  Future<WakeCapability> probe() async {
    probeCalls++;
    throw StateError('secret internal failure text');
  }
}

/// The fake platform of one test.
class _Rig {
  _Rig({FakeWakeTimerService? wake}) : wake = wake ?? FakeWakeTimerService();

  final FakeWakeTimerService wake;
  final power = FakePowerControl();
  final player = FakeAlarmSoundPlayer();
  final audio = FakeAudioOutput();
  final dialogs = FakeFileDialogs();

  List<Override> get overrides => [
    systemClockProvider.overrideWithValue(Clock.fixed(_now)),
    wakeTimerServiceProvider.overrideWithValue(wake),
    powerControlProvider.overrideWithValue(power),
    alarmSoundPlayerProvider.overrideWithValue(player),
    audioOutputProvider.overrideWithValue(audio),
    fileDialogsProvider.overrideWithValue(dialogs),
  ];
}

/// The apps opened by the running test.
final _opened = <AppHarness>[];

/// Like `testWidgets`, but ends by shutting the wake-up controller down: it
/// owns periodic timers (the hourly re-check) that Flutter would report as
/// pending, and the harness only disposes its container after that check.
void wakeTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    _opened.clear();
    await body(tester);
    await _release(tester);
  });
}

Future<void> _release(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  for (final harness in _opened) {
    harness.container.invalidate(wakeAlarmControllerProvider);
  }
  _opened.clear();
}

void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  Future<AppHarness> open(
    WidgetTester tester, {
    _Rig? rig,
    AppSettings? settings,
    Size size = const Size(1200, 800),
    double textScale = 1,
    Brightness brightness = Brightness.light,
    bool settle = true,
  }) async {
    final r = rig ?? _Rig();
    final harness = await AppHarness.pump(
      tester,
      repository: repo,
      now: _now,
      settings: settings,
      size: size,
      textScale: textScale,
      brightness: brightness,
      overrides: r.overrides,
    );
    _opened.add(harness);
    harness.container
        .read(destinationProvider.notifier)
        .select(Destination.wakeUp);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump();
    }
    return harness;
  }

  WakeAlarmController controllerOf(AppHarness h) =>
      h.container.read(wakeAlarmControllerProvider.notifier);

  WakeAlarmState stateOf(AppHarness h) =>
      h.container.read(wakeAlarmControllerProvider);

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, String key, String label) async {
    await tapKey(tester, key);
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  const fajrAlarm = WakeAlarm(
    id: 'wake-fajr',
    trigger: AlarmTriggerKind.relativeToPrayer,
  );
  const fixedAlarm = WakeAlarm(
    id: 'wake-four',
    label: 'کار صبح',
    // 04:00 every day.
    afterSound: AfterSound.sleep,
  );

  group('capability panel', () {
    wakeTest('green when the PC can wake itself', (tester) async {
      final rig = _Rig();
      await open(tester, rig: rig);
      // The page probes every time it opens.
      expect(rig.wake.probeCalls, 1);
      expect(find.byKey(const Key('wake-capability-ok')), findsOneWidget);
      expect(
        text(tester, 'wake-capability-title'),
        'این رایانه می‌تواند خودش را بیدار کند',
      );
      expect(find.byKey(const Key('wake-open-power')), findsNothing);
    });

    wakeTest('amber with a reason and a Power Options button', (tester) async {
      final rig = _Rig(
        wake: FakeWakeTimerService(
          capability: const WakeCapability(
            taskCreationOk: true,
            wakeTimersOnAc: WakeTimerPolicy.disabled,
            wakeTimersOnBattery: WakeTimerPolicy.enabled,
            inProcessTimerOk: true,
          ),
        ),
      );
      await open(tester, rig: rig);
      expect(find.byKey(const Key('wake-capability-warn')), findsOneWidget);
      expect(
        find.text(
          'ویندوز هنگام اتصال به برق، تایمرهای بیدارکننده را خاموش کرده است.',
        ),
        findsOneWidget,
      );
      await tapKey(tester, 'wake-open-power');
      expect(rig.wake.openCalls, 1);
      expect(find.byKey(const Key('wake-open-power-failed')), findsNothing);
    });

    wakeTest('says so when Power Options cannot be opened', (tester) async {
      final rig = _Rig(wake: _NoOpen());
      await open(tester, rig: rig);
      await tapKey(tester, 'wake-open-power');
      expect(find.byKey(const Key('wake-open-power-failed')), findsOneWidget);
    });

    wakeTest('a PC without wake support (nothing bound) is amber', (
      tester,
    ) async {
      // No wake overrides at all: the default service reports "unsupported".
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _now,
      );
      _opened.add(harness);
      harness.container
          .read(destinationProvider.notifier)
          .select(Destination.wakeUp);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('wake-capability-warn')), findsOneWidget);
      expect(
        find.byKey(const Key('wake-issue-taskCreationFailed')),
        findsOneWidget,
      );
    });

    wakeTest('every reason has its own plain sentence, in both languages', (
      tester,
    ) async {
      final cases = <WakeIssue, WakeCapability>{
        WakeIssue.taskCreationFailed: const WakeCapability(
          taskCreationOk: false,
          wakeTimersOnAc: WakeTimerPolicy.enabled,
          wakeTimersOnBattery: WakeTimerPolicy.enabled,
          inProcessTimerOk: true,
        ),
        WakeIssue.wakeTimersDisabledOnAc: const WakeCapability(
          taskCreationOk: true,
          wakeTimersOnAc: WakeTimerPolicy.disabled,
          wakeTimersOnBattery: WakeTimerPolicy.enabled,
          inProcessTimerOk: true,
        ),
        WakeIssue.wakeTimersDisabledOnBattery: const WakeCapability(
          taskCreationOk: true,
          wakeTimersOnAc: WakeTimerPolicy.enabled,
          wakeTimersOnBattery: WakeTimerPolicy.disabled,
          inProcessTimerOk: true,
        ),
        WakeIssue.wakeTimersImportantOnly: const WakeCapability(
          taskCreationOk: true,
          wakeTimersOnAc: WakeTimerPolicy.importantOnly,
          wakeTimersOnBattery: WakeTimerPolicy.enabled,
          inProcessTimerOk: true,
        ),
        WakeIssue.powerSettingUnknown: const WakeCapability(
          taskCreationOk: true,
          wakeTimersOnBattery: WakeTimerPolicy.enabled,
          inProcessTimerOk: true,
        ),
        WakeIssue.inProcessTimerUnavailable: const WakeCapability(
          wakeTimersOnAc: WakeTimerPolicy.enabled,
          wakeTimersOnBattery: WakeTimerPolicy.enabled,
        ),
        WakeIssue.modernStandby: const WakeCapability(
          taskCreationOk: true,
          wakeTimersOnAc: WakeTimerPolicy.enabled,
          wakeTimersOnBattery: WakeTimerPolicy.enabled,
          inProcessTimerOk: true,
          modernStandby: true,
        ),
      };
      expect(cases.keys.toSet(), WakeIssue.values.toSet());
      for (final language in ['fa', 'en']) {
        final l10n = lookupAppLocalizations(Locale(language));
        final seen = <String>{};
        for (final entry in cases.entries) {
          expect(entry.value.issues, contains(entry.key));
          await open(
            tester,
            rig: _Rig(wake: FakeWakeTimerService(capability: entry.value)),
            settings: language == 'fa' ? persianSettings : englishSettings,
          );
          final shown = text(tester, 'wake-issue-${entry.key.name}');
          expect(shown, entry.key.text(l10n));
          expect(shown, isNotEmpty);
          expect(shown, isNot(contains('Exception')));
          seen.add(shown);
          expect(find.byKey(const Key('wake-open-power')), findsOneWidget);
          // Fresh app for the next capability.
          await _release(tester);
        }
        expect(seen, hasLength(WakeIssue.values.length));
      }
    });

    wakeTest('the refresh button probes again; the panel shows progress', (
      tester,
    ) async {
      final gated = _GatedWake();
      final rig = _Rig(wake: gated);
      final harness = await open(tester, rig: rig, settle: false);
      expect(gated.probeCalls, 1);
      expect(stateOf(harness).probing, isTrue);
      expect(find.byKey(const Key('wake-capability-unknown')), findsOneWidget);
      expect(text(tester, 'wake-capability-title'), 'در حال بررسی این رایانه…');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gated.gate.complete(gated.capability);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('wake-capability-ok')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tapKey(tester, 'wake-refresh');
      expect(gated.probeCalls, 2);
    });

    wakeTest('a failed probe shows a plain message, never the exception', (
      tester,
    ) async {
      final broken = _BrokenProbe();
      await open(tester, rig: _Rig(wake: broken));
      expect(broken.probeCalls, 1);
      expect(find.byKey(const Key('wake-capability-warn')), findsOneWidget);
      expect(text(tester, 'wake-problem-text'), 'بررسی این رایانه کامل نشد.');
      expect(find.textContaining('secret internal failure'), findsNothing);
    });
  });

  group('alarm cards', () {
    wakeTest('an empty list explains itself', (tester) async {
      await open(tester);
      expect(find.byKey(const Key('wake-empty')), findsOneWidget);
    });

    wakeTest('label, trigger, repeat, after-action and next occurrence', (
      tester,
    ) async {
      final harness = await open(tester);
      controllerOf(harness)
        ..addAlarm(fixedAlarm)
        ..addAlarm(fajrAlarm);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('wake-empty')), findsNothing);

      // The labelled alarm: the name is the title, the time its own line.
      expect(text(tester, 'wake-title-wake-four'), 'کار صبح');
      expect(text(tester, 'wake-trigger-wake-four'), startsWith('ساعت '));
      expect(text(tester, 'wake-trigger-wake-four'), contains('۰۴:۰۰'));
      expect(text(tester, 'wake-repeat-wake-four'), 'هر روز');
      expect(text(tester, 'wake-after-wake-four'), 'پس از صدا: خواب');
      // 04:00 on the 12th (Tehran) is 12 h 30 min after 15:30 on the 11th.
      final next = text(tester, 'wake-next-wake-four');
      expect(next, startsWith('بعدی: ۱۲ ساعت و ۳۰ دقیقه دیگر'));
      expect(next, contains('پنجشنبه'));
      expect(next, contains('۰۴:۰۰'));

      // The unnamed one is titled by its trigger.
      expect(text(tester, 'wake-title-wake-fajr'), '۴۰ دقیقه قبل از اذان صبح');
      expect(find.byKey(const Key('wake-trigger-wake-fajr')), findsNothing);
      expect(find.byKey(const Key('wake-after-wake-fajr')), findsNothing);
    });

    wakeTest('English wording', (tester) async {
      final harness = await open(tester, settings: englishSettings);
      controllerOf(harness)
        ..addAlarm(fixedAlarm)
        ..addAlarm(
          fajrAlarm.copyWith(
            repeat: AlarmRepeat.weekdays,
            weekdays: {DateTime.saturday, DateTime.monday},
          ),
        );
      await tester.pumpAndSettle();
      expect(
        text(tester, 'wake-next-wake-four'),
        'Next: in 12 h 30 min (Thursday '
        '${Formatter.isolate('04:00')})',
      );
      expect(text(tester, 'wake-title-wake-fajr'), '40 min before Fajr');
      expect(text(tester, 'wake-repeat-wake-fajr'), 'On Saturday, Monday');
      expect(text(tester, 'wake-after-wake-four'), 'After the sound: sleep');
    });

    wakeTest('the switch turns an alarm off and on', (tester) async {
      final rig = _Rig();
      final harness = await open(tester, rig: rig);
      controllerOf(harness).addAlarm(fixedAlarm);
      await tester.pumpAndSettle();
      expect(rig.wake.scheduled.keys, contains('wake-four'));

      await tapKey(tester, 'wake-switch-wake-four');
      expect(harness.current.wakeAlarms.single.enabled, isFalse);
      expect(text(tester, 'wake-next-wake-four'), 'خاموش');
      // Disabling removes the wake request from the OS.
      expect(rig.wake.scheduled, isEmpty);

      await tapKey(tester, 'wake-switch-wake-four');
      expect(harness.current.wakeAlarms.single.enabled, isTrue);
      expect(text(tester, 'wake-next-wake-four'), startsWith('بعدی:'));
      expect(rig.wake.scheduled.keys, contains('wake-four'));
    });

    wakeTest('delete asks first', (tester) async {
      final rig = _Rig();
      final harness = await open(tester, rig: rig);
      controllerOf(harness).addAlarm(fixedAlarm);
      await tester.pumpAndSettle();

      await tapKey(tester, 'wake-delete-wake-four');
      expect(find.text('این بیدارباش حذف شود؟'), findsOneWidget);
      await tapKey(tester, 'wake-delete-cancel');
      expect(harness.current.wakeAlarms, hasLength(1));

      await tapKey(tester, 'wake-delete-wake-four');
      await tapKey(tester, 'wake-delete-confirm');
      expect(harness.current.wakeAlarms, isEmpty);
      expect(find.byKey(const Key('wake-empty')), findsOneWidget);
      expect(rig.wake.scheduled, isEmpty);
    });
  });

  group('editor', () {
    wakeTest('adds a fixed-time alarm through the dialog', (tester) async {
      final rig = _Rig();
      final harness = await open(tester, rig: rig);
      await tapKey(tester, 'wake-add');
      expect(find.text('بیدارباش جدید'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('wake-ed-label')), 'نماز');
      await pick(tester, 'wake-ed-hour', '۰۵');
      await pick(tester, 'wake-ed-minute', '۰۵');
      await tapKey(tester, 'wake-ed-repeat-weekdays');
      await tapKey(tester, 'wake-ed-day-6');
      await tapKey(tester, 'wake-ed-day-1');
      await tapKey(tester, 'wake-ed-after-hibernate');
      await tapKey(tester, 'wake-ed-save');

      expect(find.byType(AlertDialog), findsNothing);
      final alarm = harness.current.wakeAlarms.single;
      expect(alarm.label, 'نماز');
      expect(alarm.trigger, AlarmTriggerKind.fixedTime);
      expect(alarm.hour, 5);
      expect(alarm.minute, 5);
      expect(alarm.repeat, AlarmRepeat.weekdays);
      expect(alarm.weekdays, {DateTime.saturday, DateTime.monday});
      expect(alarm.afterSound, AfterSound.hibernate);
      expect(alarm.enabled, isTrue);
      expect(alarm.playSound, isTrue);
      expect(text(tester, 'wake-title-${alarm.id}'), 'نماز');
      expect(text(tester, 'wake-repeat-${alarm.id}'), 'در روزهای شنبه، دوشنبه');
      // The OS was asked to wake the PC for it.
      expect(rig.wake.scheduled.keys, contains(alarm.id));
    });

    wakeTest('adds an alarm relative to a prayer', (tester) async {
      final harness = await open(tester);
      await tapKey(tester, 'wake-add');
      await tapKey(tester, 'wake-ed-trigger-relative');
      expect(find.byKey(const Key('wake-ed-hour')), findsNothing);
      await pick(tester, 'wake-ed-prayer', 'اذان صبح');
      await tester.enterText(find.byKey(const Key('wake-ed-minutes')), '۴۰');
      await tester.pumpAndSettle();
      await tapKey(tester, 'wake-ed-save');
      final alarm = harness.current.wakeAlarms.single;
      expect(alarm.trigger, AlarmTriggerKind.relativeToPrayer);
      expect(alarm.prayer, Prayer.fajr);
      expect(alarm.minutesBefore, 40);
      expect(alarm.repeat, AlarmRepeat.daily);
      expect(
        text(tester, 'wake-title-${alarm.id}'),
        '۴۰ دقیقه قبل از اذان صبح',
      );
      expect(text(tester, 'wake-next-${alarm.id}'), startsWith('بعدی:'));
    });

    wakeTest('invalid input disables Save and says why', (tester) async {
      final harness = await open(tester);
      await tapKey(tester, 'wake-add');
      bool saveEnabled() =>
          tester
              .widget<FilledButton>(find.byKey(const Key('wake-ed-save')))
              .onPressed !=
          null;
      expect(saveEnabled(), isTrue);

      await tapKey(tester, 'wake-ed-repeat-weekdays');
      expect(find.byKey(const Key('wake-ed-days-error')), findsOneWidget);
      expect(saveEnabled(), isFalse);
      await tapKey(tester, 'wake-ed-day-5');
      expect(find.byKey(const Key('wake-ed-days-error')), findsNothing);
      expect(saveEnabled(), isTrue);

      await tapKey(tester, 'wake-ed-trigger-relative');
      await tester.enterText(find.byKey(const Key('wake-ed-minutes')), '999');
      await tester.pumpAndSettle();
      expect(
        text(tester, 'wake-ed-minutes-error'),
        'عددی صحیح بین ۰ تا ۷۲۰ بنویسید.',
      );
      expect(saveEnabled(), isFalse);
      await tester.enterText(find.byKey(const Key('wake-ed-minutes')), '');
      await tester.pumpAndSettle();
      expect(saveEnabled(), isFalse);
      await tester.enterText(find.byKey(const Key('wake-ed-minutes')), '30');
      await tester.pumpAndSettle();
      expect(saveEnabled(), isTrue);
      await tapKey(tester, 'wake-ed-cancel');
      expect(harness.current.wakeAlarms, isEmpty);
    });

    wakeTest('editing keeps the id and the on/off state', (tester) async {
      final harness = await open(tester);
      controllerOf(harness)
        ..addAlarm(fixedAlarm)
        ..setEnabled('wake-four', enabled: false);
      await tester.pumpAndSettle();

      await tapKey(tester, 'wake-edit-wake-four');
      expect(find.text('ویرایش بیدارباش'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('wake-ed-label')))
            .controller!
            .text,
        'کار صبح',
      );
      await tester.enterText(find.byKey(const Key('wake-ed-label')), 'تازه');
      await pick(tester, 'wake-ed-hour', '۰۶');
      await tapKey(tester, 'wake-ed-save');
      final alarm = harness.current.wakeAlarms.single;
      expect(alarm.id, 'wake-four');
      expect(alarm.label, 'تازه');
      expect(alarm.hour, 6);
      expect(alarm.enabled, isFalse);
      expect(alarm.afterSound, AfterSound.sleep);
    });

    wakeTest('the card itself opens the editor; Cancel changes nothing', (
      tester,
    ) async {
      final harness = await open(tester);
      controllerOf(harness).addAlarm(fixedAlarm);
      await tester.pumpAndSettle();
      await tapKey(tester, 'wake-title-wake-four');
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.enterText(find.byKey(const Key('wake-ed-label')), 'x');
      await tapKey(tester, 'wake-ed-cancel');
      expect(find.byType(AlertDialog), findsNothing);
      expect(harness.current.wakeAlarms.single.label, 'کار صبح');
    });

    wakeTest('sound: file picker, preview, stop, default, off', (tester) async {
      final rig = _Rig();
      rig.dialogs.soundPath = r'C:\Users\me\Music\wake up.mp3';
      final harness = await open(tester, rig: rig);
      await tapKey(tester, 'wake-add');
      expect(text(tester, 'wake-ed-sound-name'), 'صدای پیش‌فرض اذان');
      expect(find.byKey(const Key('wake-ed-default')), findsNothing);

      await tapKey(tester, 'wake-ed-pick');
      expect(text(tester, 'wake-ed-sound-name'), 'فایل: wake up.mp3');
      expect(find.byKey(const Key('wake-ed-default')), findsOneWidget);

      // Preview plays the chosen file at the chosen volume.
      await tapKey(tester, 'wake-ed-preview');
      expect(rig.audio.plays, hasLength(1));
      expect(
        rig.audio.plays.single.sound,
        const SoundRef.file(r'C:\Users\me\Music\wake up.mp3'),
      );
      expect(find.text('توقف پیش‌شنود'), findsOneWidget);
      await tapKey(tester, 'wake-ed-preview');
      expect(rig.audio.stopCount, greaterThan(0));
      expect(find.text('پیش‌شنود'), findsOneWidget);

      // Closing while it plays stops it.
      await tapKey(tester, 'wake-ed-preview');
      final stopsBefore = rig.audio.stopCount;
      await tapKey(tester, 'wake-ed-cancel');
      expect(rig.audio.stopCount, greaterThan(stopsBefore));

      // Save with the file; then the default again; then no sound.
      await tapKey(tester, 'wake-add');
      await tapKey(tester, 'wake-ed-pick');
      await tapKey(tester, 'wake-ed-default');
      expect(text(tester, 'wake-ed-sound-name'), 'صدای پیش‌فرض اذان');
      await tapKey(tester, 'wake-ed-sound-switch');
      expect(find.byKey(const Key('wake-ed-sound-name')), findsNothing);
      expect(find.byKey(const Key('wake-ed-volume')), findsNothing);
      await tapKey(tester, 'wake-ed-save');
      expect(harness.current.wakeAlarms.single.playSound, isFalse);
    });

    wakeTest('a cancelled file dialog keeps the sound', (tester) async {
      final rig = _Rig();
      await open(tester, rig: rig);
      await tapKey(tester, 'wake-add');
      await tapKey(tester, 'wake-ed-pick');
      expect(text(tester, 'wake-ed-sound-name'), 'صدای پیش‌فرض اذان');
    });

    wakeTest('the volume is saved', (tester) async {
      final harness = await open(tester);
      await tapKey(tester, 'wake-add');
      expect(text(tester, 'wake-ed-volume-text'), '۱۰۰٪');
      final slider = find.byKey(const Key('wake-ed-volume'));
      // Drag the thumb to the middle of the track.
      final rect = tester.getRect(slider);
      await tester.tapAt(rect.center);
      await tester.pumpAndSettle();
      final shown = text(tester, 'wake-ed-volume-text');
      expect(shown, isNot('۱۰۰٪'));
      await tapKey(tester, 'wake-ed-save');
      final saved = harness.current.wakeAlarms.single.volume;
      expect(saved, inExclusiveRange(0.3, 0.7));
    });
  });

  group('test, sleep and hibernate', () {
    wakeTest('"test in 2 minutes" and cancel', (tester) async {
      final rig = _Rig();
      await open(tester, rig: rig);
      await tapKey(tester, 'wake-test');
      // 15:30 + 2 min = 15:32 in Tehran.
      expect(
        text(tester, 'wake-test-pending-text'),
        contains(Formatter.isolate('۱۵:۳۲')),
      );
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('wake-test')))
            .onPressed,
        isNull,
      );
      // The OS is asked to wake the PC for it.
      expect(rig.wake.scheduled.keys.single, startsWith('wake-test-'));

      await tapKey(tester, 'wake-test-cancel');
      expect(find.byKey(const Key('wake-test-pending')), findsNothing);
      expect(rig.wake.scheduled, isEmpty);
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('wake-test')))
            .onPressed,
        isNotNull,
      );
    });

    wakeTest('sleep now: a 5-second countdown, then it sleeps', (tester) async {
      final rig = _Rig();
      await open(tester, rig: rig);
      expect(find.byKey(const Key('wake-countdown')), findsNothing);
      await tester.tap(find.byKey(const Key('wake-sleep-now')));
      await tester.pump();
      expect(find.byKey(const Key('wake-countdown')), findsOneWidget);
      expect(
        text(tester, 'wake-countdown-text'),
        'رایانه تا ۵ ثانیه دیگر به خواب می‌رود.',
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        text(tester, 'wake-countdown-text'),
        'رایانه تا ۴ ثانیه دیگر به خواب می‌رود.',
      );
      expect(rig.power.calls, isEmpty);
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();
      expect(rig.power.calls, ['sleep']);
      expect(find.byKey(const Key('wake-countdown')), findsNothing);
    });

    wakeTest('hibernate now uses the hibernate wording and action', (
      tester,
    ) async {
      final rig = _Rig();
      await open(tester, rig: rig);
      await tester.tap(find.byKey(const Key('wake-hibernate-now')));
      await tester.pump();
      expect(
        text(tester, 'wake-countdown-text'),
        'رایانه تا ۵ ثانیه دیگر به خواب زمستانی می‌رود.',
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();
      expect(rig.power.calls, ['hibernate']);
    });

    wakeTest('cancelling the countdown keeps the PC awake', (tester) async {
      final rig = _Rig();
      await open(tester, rig: rig);
      await tester.tap(find.byKey(const Key('wake-sleep-now')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('wake-countdown-cancel')));
      await tester.pump();
      expect(find.byKey(const Key('wake-countdown')), findsNothing);
      await tester.pump(const Duration(seconds: 10));
      expect(rig.power.calls, isEmpty);
    });

    wakeTest('Esc cancels the countdown too', (tester) async {
      final rig = _Rig();
      await open(tester, rig: rig);
      await tester.tap(find.byKey(const Key('wake-sleep-now')));
      await tester.pump();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byKey(const Key('wake-countdown')), findsNothing);
      await tester.pump(const Duration(seconds: 10));
      expect(rig.power.calls, isEmpty);
    });

    wakeTest('a refused sleep is explained, then dismissable', (tester) async {
      final rig = _Rig()..power.result = PowerResult.refused;
      await open(tester, rig: rig);
      await tester.tap(find.byKey(const Key('wake-sleep-now')));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();
      expect(text(tester, 'wake-problem-text'), 'ویندوز اجازه‌ی خواب نداد.');
      await tester.tap(find.byKey(const Key('wake-problem-dismiss')));
      await tester.pump();
      expect(find.byKey(const Key('wake-problem')), findsNothing);
    });

    wakeTest('hibernation switched off is explained', (tester) async {
      final rig = _Rig()..power.result = PowerResult.unavailable;
      await open(tester, rig: rig);
      await tester.tap(find.byKey(const Key('wake-hibernate-now')));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();
      expect(
        text(tester, 'wake-problem-text'),
        'خواب زمستانی در این رایانه روشن نیست.',
      );
    });
  });

  group('ringing', () {
    ScheduledEvent event(String id) => ScheduledEvent(
      kind: EventKind.wakeAlarm,
      instantUtc: _now,
      date: CivilDate(2026, 11, 11),
      alarmId: id,
    );

    wakeTest('shows the ringing state and Stop silences it', (tester) async {
      final rig = _Rig();
      final harness = await open(tester, rig: rig);
      controllerOf(harness)
          .addAlarm(fixedAlarm.copyWith(afterSound: AfterSound.nothing));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('wake-ringing')), findsNothing);

      await controllerOf(harness).handleWakeEvent(event('wake-four'));
      await tester.pump();
      await tester.pump();
      expect(rig.player.playing, isTrue);
      expect(find.byKey(const Key('wake-ringing')), findsOneWidget);
      expect(text(tester, 'wake-ringing-text'), 'بیدارباش در حال پخش است');

      await tester.tap(find.byKey(const Key('wake-stop')));
      await tester.pump();
      await tester.pump();
      expect(rig.player.stops, greaterThan(0));
      expect(find.byKey(const Key('wake-ringing')), findsNothing);
    });

    wakeTest('after the sound a cancellable 30-second countdown shows', (
      tester,
    ) async {
      final rig = _Rig();
      final harness = await open(tester, rig: rig);
      controllerOf(harness).addAlarm(fixedAlarm);
      await tester.pumpAndSettle();
      await controllerOf(harness).handleWakeEvent(event('wake-four'));
      await tester.pump();
      rig.player.finish();
      await tester.pump();
      await tester.pump();
      expect(
        text(tester, 'wake-countdown-text'),
        'بیدارباش تمام شد. رایانه تا ۳۰ ثانیه دیگر به خواب می‌رود.',
      );
      await tester.tap(find.byKey(const Key('wake-countdown-cancel')));
      await tester.pump();
      expect(find.byKey(const Key('wake-countdown')), findsNothing);
      await tester.pump(const Duration(seconds: 40));
      expect(rig.power.calls, isEmpty);
    });

    wakeTest('a sound that cannot play is a plain message', (tester) async {
      final rig = _Rig()..player.failPlays = 2;
      final harness = await open(tester, rig: rig);
      controllerOf(harness).addAlarm(fixedAlarm);
      await tester.pumpAndSettle();
      await controllerOf(harness).handleWakeEvent(event('wake-four'));
      await tester.pump();
      await tester.pump();
      expect(
        text(tester, 'wake-problem-text'),
        'صدای بیدارباش پخش نشد. فایل صدا و بلندگو را بررسی کنید.',
      );
      expect(find.textContaining('cannot play'), findsNothing);
      expect(find.textContaining('StateError'), findsNothing);
    });
  });

  group('wake request errors', () {
    wakeTest('a failed OS request shows a plain, dismissable notice', (
      tester,
    ) async {
      final rig = _Rig();
      rig.wake.failScheduleWith = Exception('boom schtasks 0x80070005');
      final harness = await open(tester, rig: rig);
      controllerOf(harness).addAlarm(fixedAlarm);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('wake-sync-error')), findsOneWidget);
      expect(
        text(tester, 'wake-sync-error-text'),
        'درخواست بیدار شدن به ویندوز ثبت نشد؛ بیدارباش ممکن است فقط تا وقتی '
        'برنامه باز است کار کند.',
      );
      expect(find.textContaining('boom'), findsNothing);
      expect(find.textContaining('0x8007'), findsNothing);
      await tapKey(tester, 'wake-sync-dismiss');
      expect(find.byKey(const Key('wake-sync-error')), findsNothing);
    });
  });

  group('home status line', () {
    wakeTest('shows the next wake-up, and a dash when there is none', (
      tester,
    ) async {
      final harness = await open(tester);
      harness.container
          .read(destinationProvider.notifier)
          .select(Destination.home);
      await tester.pumpAndSettle();
      expect(find.text('بیدارباش بعدی: —'), findsOneWidget);

      controllerOf(harness).addAlarm(fixedAlarm);
      await tester.pumpAndSettle();
      expect(
        find.text('بیدارباش بعدی: پنجشنبه ${Formatter.isolate('۰۴:۰۰')}'),
        findsOneWidget,
      );
      // The line is a link to the wake-up screen.
      await tester.tap(find.byKey(const Key('status-wake')));
      await tester.pumpAndSettle();
      expect(harness.container.read(destinationProvider), Destination.wakeUp);
    });
  });

  group('layout', () {
    for (final locale in ['fa', 'en']) {
      for (final dark in [false, true]) {
        for (final size in [const Size(1200, 800), const Size(800, 560)]) {
          for (final scale in [1.0, 2.0]) {
            wakeTest('$locale ${dark ? 'dark' : 'light'} '
                '${size.width.toInt()}x${size.height.toInt()} x$scale '
                'has no overflow', (tester) async {
              final rig = _Rig(
                wake: FakeWakeTimerService(
                  capability: const WakeCapability(
                    taskCreationOk: false,
                    wakeTimersOnAc: WakeTimerPolicy.disabled,
                    wakeTimersOnBattery: WakeTimerPolicy.importantOnly,
                    modernStandby: true,
                  ),
                ),
              )..power.result = PowerResult.refused;
              final harness = await open(
                tester,
                rig: rig,
                settings: locale == 'fa' ? persianSettings : englishSettings,
                size: size,
                textScale: scale,
                brightness: dark ? Brightness.dark : Brightness.light,
              );
              expect(tester.takeException(), isNull);
              controllerOf(harness)
                ..addAlarm(fixedAlarm)
                ..addAlarm(
                  fajrAlarm.copyWith(
                    label: 'یک نام بلند برای بیدارباشی که چند سطر می‌شود',
                    repeat: AlarmRepeat.weekdays,
                    weekdays: {1, 2, 3, 4, 5, 6},
                    afterSound: AfterSound.hibernate,
                  ),
                );
              await tester.pumpAndSettle();
              await tester.ensureVisible(find.byKey(const Key('wake-test')));
              await tester.tap(find.byKey(const Key('wake-test')));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);

              // Ringing + the countdown after it + a problem, all at once.
              await controllerOf(harness).handleWakeEvent(
                ScheduledEvent(
                  kind: EventKind.wakeAlarm,
                  instantUtc: _now,
                  date: CivilDate(2026, 11, 11),
                  alarmId: 'wake-four',
                ),
              );
              await tester.pump();
              expect(find.byKey(const Key('wake-ringing')), findsOneWidget);
              rig.player.finish();
              await tester.pump();
              await tester.pump();
              expect(find.byKey(const Key('wake-countdown')), findsOneWidget);
              expect(tester.takeException(), isNull);
              await tester.tap(find.byKey(const Key('wake-countdown-cancel')));
              await tester.pump();

              // The editor in its fullest form.
              await tapKey(tester, 'wake-add');
              await tapKey(tester, 'wake-ed-trigger-relative');
              await tapKey(tester, 'wake-ed-repeat-weekdays');
              await tapKey(tester, 'wake-ed-after-hibernate');
              expect(tester.takeException(), isNull);
              await tester.tap(find.byKey(const Key('wake-ed-cancel')));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            });
          }
        }
      }
    }
  });
}

/// A wake service whose Power Options cannot be opened.
class _NoOpen extends FakeWakeTimerService {
  _NoOpen()
    : super(
        capability: const WakeCapability(
          taskCreationOk: true,
          wakeTimersOnAc: WakeTimerPolicy.disabled,
          wakeTimersOnBattery: WakeTimerPolicy.disabled,
          inProcessTimerOk: true,
        ),
      );

  @override
  Future<bool> openPowerOptions() async {
    openCalls++;
    return false;
  }
}
