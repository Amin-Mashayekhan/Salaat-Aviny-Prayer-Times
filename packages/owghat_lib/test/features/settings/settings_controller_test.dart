import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/storage/json_file_store.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/data/settings_repository.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:prayer_core/prayer_core.dart';

void main() {
  late Directory dir;
  late JsonFileStore store;
  late SettingsRepository repo;
  late ProviderContainer container;

  SettingsController controller() => container.read(settingsProvider.notifier);
  AppSettings state() => container.read(settingsProvider);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('owghat_settings_');
    store = JsonFileStore(File('${dir.path}/settings.json'));
    repo = SettingsRepository(store, debounce: const Duration(milliseconds: 5));
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    addTearDown(() => dir.deleteSync(recursive: true));
  });

  group('appearance and simple switches', () {
    test('each setter changes only its own field', () {
      controller()
        ..setLanguage(AppLanguage.en)
        ..setTheme(ThemeSetting.dark)
        ..setDigits(DigitStyle.latin)
        ..setHourFormat(HourFormat.h12)
        ..setCloseToTray(enabled: false)
        ..setStartMinimized(enabled: false)
        ..setLaunchAtStartup(enabled: true)
        ..setAzanEnabled(enabled: false)
        ..setFadeIn(enabled: false)
        ..setReminderChime(enabled: false)
        ..completeOnboarding();
      final s = state();
      expect(s.language, AppLanguage.en);
      expect(s.theme, ThemeSetting.dark);
      expect(s.digits, DigitStyle.latin);
      expect(s.hourFormat, HourFormat.h12);
      expect(s.window.closeToTray, isFalse);
      expect(s.window.startMinimized, isFalse);
      expect(s.window.launchAtStartup, isTrue);
      expect(s.azan.enabled, isFalse);
      expect(s.azan.fadeIn, isFalse);
      expect(s.reminders.chime, isFalse);
      expect(s.onboardingCompleted, isTrue);
      expect(s.activeLocationId, 'city:1');
    });
  });

  group('locations', () {
    const custom = SavedLocation.custom(
      id: 'custom:a',
      name: 'A',
      latitude: 30,
      longitude: 50,
      zoneId: 'Asia/Tehran',
    );

    test('add, activate, update, remove', () {
      expect(controller().addLocation(custom), isNull);
      expect(state().activeLocationId, 'custom:a');
      expect(controller().addLocation(custom), SettingsFailure.duplicate);
      expect(
        controller().setLocationOffset(
          'custom:a',
          const LocationOffset.fixed(210),
        ),
        isNull,
      );
      expect(state().activeLocation.offset.fixedMinutes, 210);
      expect(controller().setActiveLocation('city:1'), isNull);
      expect(controller().removeLocation('custom:a'), isNull);
      expect(state().locations.length, 1);
      expect(
        controller().removeLocation('city:1'),
        SettingsFailure.lastLocation,
      );
      expect(controller().removeLocation('zzz'), SettingsFailure.notFound);
      expect(controller().setActiveLocation('zzz'), SettingsFailure.notFound);
    });

    test('removing the active location activates the first one', () {
      controller().addLocation(custom);
      expect(controller().removeLocation('custom:a'), isNull);
      expect(state().activeLocationId, 'city:1');
    });

    test(
      'offset range is validated and a refused change leaves state alone',
      () {
        final before = state();
        expect(
          controller().setLocationOffset(
            'city:1',
            const LocationOffset.fixed(5000),
          ),
          SettingsFailure.outOfRange,
        );
        expect(
          controller().setLocationOffset(
            'nope',
            const LocationOffset.automatic(),
          ),
          SettingsFailure.notFound,
        );
        expect(state(), same(before));
      },
    );
  });

  group('calculation', () {
    test('applyMethod keeps the user rules', () {
      controller().setParams(
        CalculationMethod.tehran.params.copyWith(
          asr: AsrRule.hanafi,
          imsakMinutes: 15,
          highLatitude: HighLatitudeRule.oneSeventh,
        ),
      );
      controller().applyMethod(CalculationMethod.jafari);
      final p = state().calculation.params;
      expect(p.fajrAngle, 16);
      expect(p.maghribAngle, 4);
      expect(p.asr, AsrRule.hanafi);
      expect(p.imsakMinutes, 15);
      expect(state().calculation.method, isNot(CalculationMethod.tehran));
    });

    test('editing an angle makes the method custom', () {
      controller().setParams(
        CalculationMethod.tehran.params.copyWith(fajrAngle: 18),
      );
      expect(state().calculation.method, CalculationMethod.custom);
    });

    test('invalid parameters are refused', () {
      final before = state();
      expect(
        controller().setParams(
          CalculationMethod.tehran.params.copyWith(fajrAngle: 99),
        ),
        SettingsFailure.outOfRange,
      );
      expect(
        controller().setParams(
          CalculationMethod.tehran.params.copyWith(ishaAngle: () => 1),
        ),
        SettingsFailure.outOfRange,
      );
      expect(
        controller().setParams(
          CalculationMethod.tehran.params.copyWith(maghribAngle: () => 20),
        ),
        SettingsFailure.outOfRange,
      );
      expect(
        controller().setParams(
          CalculationMethod.tehran.params.copyWith(imsakMinutes: 90),
        ),
        SettingsFailure.outOfRange,
      );
      expect(state(), same(before));
    });

    test('per-prayer offsets', () {
      expect(controller().setPrayerOffset(Prayer.fajr, -5), isNull);
      expect(state().calculation.offsetsMinutes, {Prayer.fajr: -5});
      expect(controller().setPrayerOffset(Prayer.fajr, 0), isNull);
      expect(state().calculation.offsetsMinutes, isEmpty);
      expect(
        controller().setPrayerOffset(Prayer.fajr, 61),
        SettingsFailure.outOfRange,
      );
      controller().setPrayerOffset(Prayer.asr, 3);
      controller().resetPrayerOffsets();
      expect(state().calculation.offsetsMinutes, isEmpty);
    });

    test('display rows', () {
      controller().setDisplay(const DisplaySettings(showImsak: true));
      expect(state().display.showImsak, isTrue);
    });
  });

  group('azan, reminders, dates', () {
    test('volume and per-prayer azan are validated', () {
      expect(controller().setMasterVolume(0.3), isNull);
      expect(controller().setMasterVolume(1.5), SettingsFailure.outOfRange);
      expect(state().azan.masterVolume, 0.3);
      expect(
        controller().setPrayerAzan(Prayer.asr, const PrayerAzan(enabled: true)),
        isNull,
      );
      expect(state().azan.enabledPrayers, contains(Prayer.asr));
      expect(
        controller().setPrayerAzan(Prayer.sunrise, const PrayerAzan()),
        SettingsFailure.invalid,
      );
      expect(
        controller().setPrayerAzan(Prayer.asr, const PrayerAzan(volume: 2)),
        SettingsFailure.outOfRange,
      );
    });

    test('a master switch off removes every enabled prayer', () {
      controller().setAzanEnabled(enabled: false);
      expect(state().azan.enabledPrayers, isEmpty);
    });

    test('mute can be set and cleared', () {
      controller().setMute(const MuteSetting(indefinite: true));
      expect(state().azan.mute.indefinite, isTrue);
      controller().setMute(MuteSetting.none);
      expect(state().azan.mute.isActiveAt(DateTime.utc(2026)), isFalse);
    });

    test('reminder minutes', () {
      expect(controller().setReminderMinutes(Prayer.asr, 20), isNull);
      expect(state().reminders.minutesBefore[Prayer.asr], 20);
      expect(
        controller().setReminderMinutes(Prayer.asr, 61),
        SettingsFailure.outOfRange,
      );
      expect(
        controller().setReminderMinutes(Prayer.sunrise, 5),
        SettingsFailure.invalid,
      );
    });

    test('hijri adjustment', () {
      expect(controller().setHijriAdjustment(-2), isNull);
      expect(controller().setHijriAdjustment(3), SettingsFailure.outOfRange);
      expect(state().hijriAdjustmentDays, -2);
    });

    test('network time', () {
      controller().setNetworkTime(
        const NetworkTimeSettings(enabled: true, host: 'time.google.com'),
      );
      expect(state().networkTime.host, 'time.google.com');
    });

    test('the qibla map switch writes only its own field', () {
      expect(state().qibla.mapEnabled, isFalse);
      final before = state().copyWith(
        qibla: const QiblaSettings(mapEnabled: true),
      );
      controller().setQiblaMapEnabled(enabled: true);
      expect(state(), before);
      controller().setQiblaMapEnabled(enabled: false);
      expect(state().qibla.mapEnabled, isFalse);
    });

    test('the qibla map style writes only its own field', () {
      expect(state().qibla.mapStyle, QiblaMapStyle.street);
      final before = state().copyWith(
        qibla: const QiblaSettings(mapStyle: QiblaMapStyle.satellite),
      );
      controller().setQiblaMapStyle(QiblaMapStyle.satellite);
      expect(state(), before);
      controller().setQiblaMapStyle(QiblaMapStyle.street);
      expect(state().qibla.mapStyle, QiblaMapStyle.street);
    });
  });

  group('wake alarms', () {
    test('upsert and remove', () {
      controller().upsertWakeAlarm(const WakeAlarm(id: 'a'));
      controller().upsertWakeAlarm(const WakeAlarm(id: 'b'));
      controller().upsertWakeAlarm(const WakeAlarm(id: 'a', label: 'new'));
      expect(state().wakeAlarms.map((a) => a.label), ['new', '']);
      expect(controller().removeWakeAlarm('a'), isNull);
      expect(controller().removeWakeAlarm('a'), SettingsFailure.notFound);
      expect(state().wakeAlarms.single.id, 'b');
    });
  });

  group('whole-file operations', () {
    test('export, reset and import restore an identical object', () {
      controller()
        ..setLanguage(AppLanguage.en)
        ..setHijriAdjustment(1)
        ..upsertWakeAlarm(const WakeAlarm(id: 'a'))
        ..setPrayerOffset(Prayer.fajr, 4);
      final exported = repo.export(state());
      final snapshot = state();
      controller().resetToDefaults();
      expect(state().language, AppLanguage.fa);
      expect(state().onboardingCompleted, isTrue);
      final imported = repo.tryImport(jsonDecode(jsonEncode(exported)));
      expect(imported, isNotNull);
      controller().replaceAll(imported!);
      expect(state(), snapshot);
    });

    test('tryImport refuses things that are not settings', () {
      expect(repo.tryImport(null), isNull);
      expect(repo.tryImport(<String, Object?>{}), isNull);
      expect(repo.tryImport({'foo': 1}), isNull);
      expect(repo.tryImport([1, 2]), isNull);
    });
  });

  group('persistence', () {
    test('a change is written to disk and loads back identically', () async {
      controller()
        ..setLanguage(AppLanguage.en)
        ..setPrayerOffset(Prayer.dhuhr, 2);
      await repo.flush();
      final loaded = await SettingsRepository(store).load();
      expect(loaded.firstRun, isFalse);
      expect(loaded.settings, state());
    });

    test('no change means no write', () async {
      controller().setLanguage(AppLanguage.fa); // same as default
      await repo.flush();
      expect(File('${dir.path}/settings.json').existsSync(), isFalse);
    });

    test('first run and a corrupt file', () async {
      final first = await repo.load();
      expect(first.firstRun, isTrue);
      expect(first.settings, const AppSettings.defaults());
      File('${dir.path}/settings.json').writeAsStringSync('{broken');
      final broken = await repo.load();
      expect(broken.wasReset, isTrue);
      expect(broken.firstRun, isFalse);
      expect(
        dir.listSync().whereType<File>().map((f) => f.uri.pathSegments.last),
        anyElement(startsWith('settings.corrupt-')),
      );
      expect(File('${dir.path}/settings.json').existsSync(), isFalse);
    });

    test('a JSON file that is not an object counts as reset', () async {
      File('${dir.path}/settings.json').writeAsStringSync('[1,2,3]');
      final result = await repo.load();
      expect(result.wasReset, isTrue);
      expect(result.settings, const AppSettings.defaults());
    });
  });
}
