import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/data/settings_migrations.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:prayer_core/prayer_core.dart';

AppSettings _loadFixture() {
  final text = File('test/fixtures/settings_v1.json').readAsStringSync();
  final json = jsonDecode(text) as Map<String, Object?>;
  return AppSettings.fromJson(SettingsMigrations.migrate(json));
}

void main() {
  group('defaults', () {
    test('match the product spec', () {
      const s = AppSettings.defaults();
      expect(s.language, AppLanguage.fa);
      expect(s.digits, DigitStyle.persian);
      expect(s.activeLocationId, 'city:1');
      expect(s.calculation.method, CalculationMethod.tehran);
      expect(s.azan.enabledPrayers, {
        Prayer.fajr,
        Prayer.dhuhr,
        Prayer.maghrib,
      });
      expect(s.reminders.minutesBefore[Prayer.fajr], 10);
      expect(s.reminders.minutesBefore[Prayer.asr], 0);
      expect(s.hijriAdjustmentDays, 0);
      expect(s.window.closeToTray, isTrue);
      expect(s.networkTime.enabled, isFalse);
      expect(s.onboardingCompleted, isFalse);
      expect(s.activeLocation.offset.mode, OffsetMode.automatic);
    });

    test('round-trip through JSON unchanged', () {
      const s = AppSettings.defaults();
      final again = AppSettings.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, Object?>,
      );
      expect(again, s);
      expect(jsonEncode(again.toJson()), jsonEncode(s.toJson()));
    });

    test('contain no daylight-saving field anywhere', () {
      final text = jsonEncode(const AppSettings.defaults().toJson());
      expect(text.toLowerCase(), isNot(contains('dst')));
      expect(text.toLowerCase(), isNot(contains('daylight')));
    });
  });

  group('the v1 fixture', () {
    test('loads every field', () {
      final s = _loadFixture();
      expect(s.language, AppLanguage.en);
      expect(s.theme, ThemeSetting.dark);
      expect(s.digits, DigitStyle.latin);
      expect(s.hourFormat, HourFormat.h12);
      expect(s.activeLocationId, 'custom:home');
      expect(s.locations.length, 2);
      final home = s.activeLocation;
      expect(home.kind, LocationKind.custom);
      expect(home.latitude, 35.7);
      expect(home.elevationMeters, 1200);
      expect(home.offset.mode, OffsetMode.fixed);
      expect(home.offset.fixedMinutes, 210);
      expect(s.calculation.params.fajrAngle, 18);
      expect(s.calculation.params.asr, AsrRule.hanafi);
      expect(s.calculation.params.highLatitude, HighLatitudeRule.oneSeventh);
      expect(s.calculation.params.imsakMinutes, 12);
      expect(s.calculation.method, CalculationMethod.custom);
      expect(s.calculation.offsetsMinutes, {Prayer.fajr: -3, Prayer.isha: 5});
      expect(s.display.showImsak, isTrue);
      expect(s.display.shows(Prayer.asr), isFalse);
      expect(s.azan.masterVolume, 0.4);
      expect(s.azan.fadeIn, isFalse);
      expect(s.azan.perPrayer[Prayer.fajr]!.sound.kind, SoundKind.file);
      expect(s.azan.perPrayer[Prayer.fajr]!.sound.value, 'C:/sounds/fajr.mp3');
      expect(s.azan.perPrayer[Prayer.asr]!.enabled, isTrue);
      expect(s.azan.perPrayer[Prayer.dhuhr]!.enabled, isTrue); // default
      expect(s.azan.mute.until, DateTime.utc(2026, 11, 11, 10));
      expect(s.reminders.minutesBefore[Prayer.fajr], 15);
      expect(s.reminders.minutesBefore[Prayer.dhuhr], 0);
      expect(s.reminders.minutesBefore[Prayer.maghrib], 10); // default
      expect(s.reminders.chime, isFalse);
      expect(s.hijriAdjustmentDays, -1);
      expect(s.window.closeToTray, isFalse);
      expect(s.window.launchAtStartup, isTrue);
      expect(s.networkTime.host, 'time.google.com');
      expect(s.wakeAlarms.single.weekdays, {1, 3, 5});
      expect(s.wakeAlarms.single.afterSound, AfterSound.hibernate);
      expect(s.onboardingCompleted, isTrue);
    });

    test('is stable when written and read again', () {
      final s = _loadFixture();
      final again = AppSettings.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, Object?>,
      );
      expect(again, s);
    });
  });

  group('lenient reading', () {
    test('garbage becomes defaults', () {
      expect(AppSettings.fromJson(null), const AppSettings.defaults());
      expect(AppSettings.fromJson('nope'), const AppSettings.defaults());
      expect(
        AppSettings.fromJson(<String, Object?>{}),
        const AppSettings.defaults(),
      );
    });

    test('out-of-range values are clamped, unknown enums fall back', () {
      final s = AppSettings.fromJson({
        'locale': 'klingon',
        'hijriAdjustmentDays': 9,
        'azan': {'masterVolume': 7},
        'reminders': {
          'perPrayer': {'fajr': 999},
        },
        'calculation': {'fajrAngle': 99, 'ishaAngle': 14},
      });
      expect(s.language, AppLanguage.fa);
      expect(s.hijriAdjustmentDays, 2);
      expect(s.azan.masterVolume, 1);
      expect(s.reminders.minutesBefore[Prayer.fajr], 60);
      expect(s.calculation.params.fajrAngle, 30);
    });

    test('bad locations are dropped and the active one is repaired', () {
      final s = AppSettings.fromJson({
        'activeLocationId': 'gone',
        'locations': [
          {'id': 'x', 'kind': 'custom', 'latitude': 95, 'longitude': 10},
          {'kind': 'builtin', 'cityId': 1},
          {'id': 'city:8', 'kind': 'builtin', 'cityId': 8},
          {'id': 'city:8', 'kind': 'builtin', 'cityId': 8},
        ],
      });
      expect(s.locations.map((l) => l.id), ['city:8']);
      expect(s.activeLocationId, 'city:8');
    });

    test('an empty location list falls back to Tehran', () {
      final s = AppSettings.fromJson({'locations': <Object?>[]});
      expect(s.locations.single.cityId, 1);
    });

    test('fixed offsets are clamped to the valid range', () {
      final offset = LocationOffset.fromJson({
        'mode': 'fixed',
        'minutes': 5000,
      });
      expect(offset.fixedMinutes, LocationOffset.maxFixedMinutes);
    });
  });

  group('SoundRef', () {
    test('parses and encodes', () {
      expect(SoundRef.parse('asset:chime'), SoundRef.chime);
      expect(SoundRef.parse(r'file:C:\a.mp3').kind, SoundKind.file);
      expect(SoundRef.parse('nonsense'), SoundRef.defaultAzan);
      expect(SoundRef.parse(null), SoundRef.defaultAzan);
      expect(SoundRef.parse('asset:'), SoundRef.defaultAzan);
      expect(const SoundRef.file('/x.mp3').encoded, 'file:/x.mp3');
    });
  });

  group('MuteSetting', () {
    test('expires by reading the clock, not by being rewritten', () {
      final mute = MuteSetting(until: DateTime.utc(2026, 11, 11, 10));
      expect(mute.isActiveAt(DateTime.utc(2026, 11, 11, 9, 59)), isTrue);
      expect(mute.isActiveAt(DateTime.utc(2026, 11, 11, 10)), isFalse);
      expect(
        const MuteSetting(indefinite: true).isActiveAt(DateTime.utc(2100)),
        isTrue,
      );
      expect(MuteSetting.none.isActiveAt(DateTime.utc(2026)), isFalse);
    });
  });

  group('migrations', () {
    test('a file without a version counts as version 1', () {
      expect(SettingsMigrations.versionOf(<String, Object?>{}), 1);
      expect(SettingsMigrations.versionOf({'schemaVersion': 1}), 1);
      expect(SettingsMigrations.versionOf({'schemaVersion': 'x'}), 1);
    });

    test('files from a newer app are returned unchanged', () {
      final json = <String, Object?>{'schemaVersion': 99, 'locale': 'en'};
      expect(SettingsMigrations.migrate(json), same(json));
    });
  });

  group('WakeAlarm', () {
    test('round-trips and rejects entries without an id', () {
      const alarm = WakeAlarm(
        id: 'w',
        label: 'x',
        weekdays: {2, 4},
        repeat: AlarmRepeat.weekdays,
        afterSound: AfterSound.sleep,
      );
      expect(WakeAlarm.fromJson(alarm.toJson()), alarm);
      expect(WakeAlarm.fromJson({'label': 'no id'}), isNull);
      expect(WakeAlarm.fromJson({'id': 'a', 'hour': 99})!.hour, 23);
    });
  });
}
