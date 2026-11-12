import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/settings_rig.dart';
import '../../support/test_data.dart';

/// Each setting of sections 2 to 6: the control calls the right
/// `SettingsController` method and the state changes.
void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  Future<SettingsRig> open(
    WidgetTester tester,
    SettingsSection section, {
    AppSettings? settings,
  }) => SettingsRig.open(
    tester,
    repository: repo,
    section: section,
    settings: settings,
  );

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(Scaffold).first));

  group('Display', () {
    testWidgets('theme, digits, clock and language', (tester) async {
      final rig = await open(tester, SettingsSection.display);
      await tapKey(tester, 'set-theme-2');
      expect(rig.settings.theme, ThemeSetting.dark);
      await tapKey(tester, 'set-theme-1');
      expect(rig.settings.theme, ThemeSetting.light);
      await tapKey(tester, 'set-theme-0');
      expect(rig.settings.theme, ThemeSetting.system);

      await tapKey(tester, 'set-digits-0');
      expect(rig.settings.digits, DigitStyle.persian);
      await tapKey(tester, 'set-hour-1');
      expect(rig.settings.hourFormat, HourFormat.h12);
      await tapKey(tester, 'set-hour-0');
      expect(rig.settings.hourFormat, HourFormat.h24);

      await tapKey(tester, 'set-language-0');
      expect(rig.settings.language, AppLanguage.fa);
      // The screen switches language at once, without a restart.
      expect(find.text('نمایش'), findsWidgets);
      expect(l10nOf(tester).localeName, 'fa');
    });

    testWidgets('the Hijri adjustment stays between -2 and +2', (tester) async {
      final rig = await open(tester, SettingsSection.display);
      expect(rig.settings.hijriAdjustmentDays, 0);
      await tapKey(tester, 'set-hijri-inc');
      await tapKey(tester, 'set-hijri-inc');
      expect(rig.settings.hijriAdjustmentDays, 2);
      expect(tester.widget<IconButton>(k('set-hijri-inc')).onPressed, isNull);
      await typeKey(tester, 'set-hijri-field', '-2');
      expect(rig.settings.hijriAdjustmentDays, -2);
      expect(tester.widget<IconButton>(k('set-hijri-dec')).onPressed, isNull);
      // An out-of-range entry is refused and the field shows the old value.
      await typeKey(tester, 'set-hijri-field', '7');
      expect(rig.settings.hijriAdjustmentDays, -2);
      expect(
        tester.widget<TextField>(fieldOf('set-hijri-field')).controller!.text,
        '−2',
      );
    });

    testWidgets('the Hijri note explains that Iran uses moon sighting', (
      tester,
    ) async {
      await open(tester, SettingsSection.display);
      expect(find.textContaining('moon sighting'), findsOneWidget);
    });
  });

  group('Reminders', () {
    testWidgets('minutes per prayer, 0 = off, 1 to 60', (tester) async {
      final rig = await open(tester, SettingsSection.reminders);
      expect(rig.settings.reminders.minutesBefore[Prayer.fajr], 10);
      await tapKey(tester, 'set-reminder-fajr-inc');
      expect(rig.settings.reminders.minutesBefore[Prayer.fajr], 11);
      await typeKey(tester, 'set-reminder-asr-field', '25');
      expect(rig.settings.reminders.minutesBefore[Prayer.asr], 25);
      await typeKey(tester, 'set-reminder-asr-field', '60');
      expect(rig.settings.reminders.minutesBefore[Prayer.asr], 60);
      expect(
        tester.widget<IconButton>(k('set-reminder-asr-inc')).onPressed,
        isNull,
      );
      await typeKey(tester, 'set-reminder-asr-field', '0');
      expect(rig.settings.reminders.minutesBefore[Prayer.asr], 0);
      expect(
        find.descendant(
          of: k('set-reminder-row-asr'),
          matching: find.text('Off'),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<IconButton>(k('set-reminder-asr-dec')).onPressed,
        isNull,
      );
      // Out of range: refused.
      await typeKey(tester, 'set-reminder-isha-field', '61');
      expect(rig.settings.reminders.minutesBefore[Prayer.isha], 0);
      // The azan is not touched by any of it.
      expect(rig.settings.azan.enabledPrayers, {
        Prayer.fajr,
        Prayer.dhuhr,
        Prayer.maghrib,
      });
    });

    testWidgets('the chime switch and sample', (tester) async {
      final rig = await open(tester, SettingsSection.reminders);
      await tapSwitch(tester, 'set-reminder-chime');
      expect(rig.settings.reminders.chime, isFalse);
      await tapSwitch(tester, 'set-reminder-chime');
      expect(rig.settings.reminders.chime, isTrue);
      await tapKey(tester, 'set-reminder-chime-test');
      expect(rig.audio.plays.single.sound, SoundRef.chime);
    });
  });

  group('Azan', () {
    testWidgets('master switch, volume and fade-in', (tester) async {
      final rig = await open(tester, SettingsSection.azan);
      await tapSwitch(tester, 'set-azan-master');
      expect(rig.settings.azan.enabled, isFalse);
      await tapSwitch(tester, 'set-azan-fade');
      expect(rig.settings.azan.fadeIn, isFalse);

      final slider = find.descendant(
        of: k('set-azan-volume'),
        matching: find.byType(Slider),
      );
      expect(rig.settings.azan.masterVolume, 0.6);
      await tester.ensureVisible(slider);
      await tester.pumpAndSettle();
      await tester.drag(slider, const Offset(60, 0));
      await tester.pumpAndSettle();
      expect(rig.settings.azan.masterVolume, greaterThan(0.6));
      expect(rig.settings.azan.masterVolume, lessThanOrEqualTo(1));
      expect(
        find.descendant(
          of: k('set-azan-volume'),
          matching: find.textContaining('%'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('each prayer has its own switch and volume', (tester) async {
      final rig = await open(tester, SettingsSection.azan);
      expect(rig.settings.azan.perPrayer[Prayer.asr]!.enabled, isFalse);
      await tapSwitch(tester, 'set-azan-enabled-asr');
      expect(rig.settings.azan.perPrayer[Prayer.asr]!.enabled, isTrue);
      expect(rig.settings.azan.perPrayer[Prayer.fajr]!.enabled, isTrue);
      await tapSwitch(tester, 'set-azan-enabled-fajr');
      expect(rig.settings.azan.perPrayer[Prayer.fajr]!.enabled, isFalse);

      final slider = find.descendant(
        of: k('set-azan-prayer-volume-dhuhr'),
        matching: find.byType(Slider),
      );
      await tester.ensureVisible(slider);
      await tester.pumpAndSettle();
      await tester.drag(slider, const Offset(-80, 0));
      await tester.pumpAndSettle();
      expect(rig.settings.azan.perPrayer[Prayer.dhuhr]!.volume, lessThan(1));
      expect(rig.settings.azan.perPrayer[Prayer.maghrib]!.volume, 1);
    });

    testWidgets('picking a sound file and preview call the fakes', (
      tester,
    ) async {
      final rig = await open(tester, SettingsSection.azan);
      expect(find.text('Bundled azan'), findsWidgets);
      expect(k('set-azan-default-fajr'), findsNothing);

      rig.dialogs.soundPath = r'C:\Sounds\my azan.mp3';
      await tapKey(tester, 'set-azan-pick-fajr');
      const picked = SoundRef.file(r'C:\Sounds\my azan.mp3');
      expect(rig.settings.azan.perPrayer[Prayer.fajr]!.sound, picked);
      expect(
        rig.settings.azan.perPrayer[Prayer.dhuhr]!.sound,
        SoundRef.defaultAzan,
      );
      expect(find.textContaining('my azan.mp3'), findsOneWidget);

      // Stop is only enabled while something plays.
      expect(
        tester.widget<OutlinedButton>(k('set-azan-stop-fajr')).onPressed,
        isNull,
      );
      await tapKey(tester, 'set-azan-preview-fajr');
      expect(rig.audio.plays.single.sound, picked);
      // Master volume 0.6 times the prayer volume 1.
      expect(rig.audio.plays.single.volume, closeTo(0.6, 1e-9));
      expect(
        tester.widget<OutlinedButton>(k('set-azan-stop-fajr')).onPressed,
        isNotNull,
      );
      await tapKey(tester, 'set-azan-stop-fajr');
      expect(rig.audio.stopCount, greaterThan(0));
      expect(
        tester.widget<OutlinedButton>(k('set-azan-stop-fajr')).onPressed,
        isNull,
      );

      // A cancelled dialog changes nothing.
      rig.dialogs.soundPath = null;
      await tapKey(tester, 'set-azan-pick-fajr');
      expect(rig.settings.azan.perPrayer[Prayer.fajr]!.sound, picked);

      await tapKey(tester, 'set-azan-default-fajr');
      expect(
        rig.settings.azan.perPrayer[Prayer.fajr]!.sound,
        SoundRef.defaultAzan,
      );
    });

    testWidgets('a missing sound file falls back and says so', (tester) async {
      final rig = await open(tester, SettingsSection.azan);
      rig.dialogs.soundPath = '/missing/azan.mp3';
      await tapKey(tester, 'set-azan-pick-isha');
      rig.audio.failing.add(const SoundRef.file('/missing/azan.mp3'));
      await tapKey(tester, 'set-azan-preview-isha');
      expect(rig.audio.plays.last.sound, SoundRef.defaultAzan);
      expect(
        find.descendant(
          of: k('set-azan-note-isha'),
          matching: find.textContaining('default sound'),
        ),
        findsOneWidget,
      );
      rig.audio.failAll = true;
      await tapKey(tester, 'set-azan-preview-isha');
      expect(
        find.descendant(
          of: k('set-azan-note-isha'),
          matching: find.textContaining('could not be played'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('quick mute uses the same actions as the home screen', (
      tester,
    ) async {
      final rig = await open(tester, SettingsSection.azan);
      expect(find.textContaining('Not muted'), findsOneWidget);
      await tapKey(tester, 'set-azan-mute');
      await tester.tap(find.text('Until I turn it back on'));
      await tester.pumpAndSettle();
      expect(rig.settings.azan.mute.indefinite, isTrue);
      expect(find.textContaining('until you turn it back on'), findsWidgets);

      await tapKey(tester, 'set-azan-mute');
      await tester.tap(find.text('For 1 h'));
      await tester.pumpAndSettle();
      expect(rig.settings.azan.mute.indefinite, isFalse);
      expect(
        rig.settings.azan.mute.until,
        SettingsRig.now.add(const Duration(hours: 1)),
      );

      await tapKey(tester, 'set-azan-mute');
      await tester.tap(find.text('Cancel mute'));
      await tester.pumpAndSettle();
      expect(rig.settings.azan.mute.isActiveAt(SettingsRig.now), isFalse);
    });
  });

  group('Calculation', () {
    String previewOf(WidgetTester tester, Prayer prayer) =>
        textOf(tester, 'set-preview-${prayer.name}');

    testWidgets('the method list applies a built-in method', (tester) async {
      final rig = await open(tester, SettingsSection.calculation);
      expect(rig.settings.calculation.method, CalculationMethod.tehran);
      // MWL is the third entry.
      await pickOption(tester, 'set-calc-method', 'set-calc-method-item', 2);
      expect(rig.settings.calculation.method, CalculationMethod.mwl);
      expect(rig.settings.calculation.params.fajrAngle, 18);
      expect(rig.settings.calculation.params.ishaAngle, 17);
      // Makkah has Isha as minutes after Maghrib.
      await pickOption(tester, 'set-calc-method', 'set-calc-method-item', 5);
      expect(rig.settings.calculation.method, CalculationMethod.makkah);
      expect(rig.settings.calculation.params.ishaMinutes, 90);
      expect(k('set-calc-isha-minutes'), findsOneWidget);
      expect(k('set-calc-isha-angle'), findsNothing);
    });

    testWidgets('typing an angle makes the method custom', (tester) async {
      final rig = await open(tester, SettingsSection.calculation);
      final before = previewOf(tester, Prayer.fajr);
      await typeKey(tester, 'set-calc-fajr', '16.5');
      expect(rig.settings.calculation.params.fajrAngle, 16.5);
      expect(rig.settings.calculation.method, CalculationMethod.custom);
      expect(find.text('Custom'), findsWidgets);
      // The live preview recalculated.
      expect(previewOf(tester, Prayer.fajr), isNot(before));

      // Persian digits and separator are understood too.
      await typeKey(tester, 'set-calc-fajr', '۱۸٫۲');
      expect(rig.settings.calculation.params.fajrAngle, 18.2);
    });

    testWidgets('an angle out of range is refused with a message', (
      tester,
    ) async {
      final rig = await open(tester, SettingsSection.calculation);
      await typeKey(tester, 'set-calc-fajr', '40');
      expect(rig.settings.calculation.params.fajrAngle, 17.7);
      expect(find.text('Enter a number between 5 and 30.'), findsOneWidget);
      await typeKey(tester, 'set-calc-fajr', 'abc');
      expect(rig.settings.calculation.params.fajrAngle, 17.7);
      await typeKey(tester, 'set-calc-fajr', '17.9');
      expect(rig.settings.calculation.params.fajrAngle, 17.9);
      expect(find.text('Enter a number between 5 and 30.'), findsNothing);
    });

    testWidgets('Maghrib at sunset, Isha in minutes', (tester) async {
      final rig = await open(tester, SettingsSection.calculation);
      await tapSwitch(tester, 'set-calc-maghrib-sunset');
      expect(rig.settings.calculation.params.maghribAngle, isNull);
      expect(k('set-calc-maghrib'), findsNothing);
      await tapSwitch(tester, 'set-calc-maghrib-sunset');
      expect(rig.settings.calculation.params.maghribAngle, 4.5);
      await typeKey(tester, 'set-calc-maghrib', '3');
      expect(rig.settings.calculation.params.maghribAngle, 3);

      await tapKey(tester, 'set-calc-isha-mode-1');
      expect(rig.settings.calculation.params.ishaAngle, isNull);
      expect(rig.settings.calculation.params.ishaMinutes, 90);
      await typeKey(tester, 'set-calc-isha-minutes', '100');
      expect(rig.settings.calculation.params.ishaMinutes, 100);
      await tapKey(tester, 'set-calc-isha-mode-0');
      expect(rig.settings.calculation.params.ishaAngle, 14);
      expect(rig.settings.calculation.params.ishaMinutes, isNull);
      await typeKey(tester, 'set-calc-isha-angle', '15.5');
      expect(rig.settings.calculation.params.ishaAngle, 15.5);
    });

    testWidgets('midnight, Asr, high-latitude rules and Imsak', (tester) async {
      final rig = await open(tester, SettingsSection.calculation);
      final asrBefore = previewOf(tester, Prayer.asr);
      await pickOption(tester, 'set-calc-asr', 'set-calc-asr-item', 1);
      expect(rig.settings.calculation.params.asr, AsrRule.hanafi);
      expect(previewOf(tester, Prayer.asr), isNot(asrBefore));

      await pickOption(
        tester,
        'set-calc-midnight',
        'set-calc-midnight-item',
        0,
      );
      expect(rig.settings.calculation.params.midnight, MidnightRule.standard);
      await pickOption(tester, 'set-calc-highlat', 'set-calc-highlat-item', 2);
      expect(
        rig.settings.calculation.params.highLatitude,
        HighLatitudeRule.oneSeventh,
      );

      await tapKey(tester, 'set-calc-imsak-inc');
      expect(rig.settings.calculation.params.imsakMinutes, 11);
      await typeKey(tester, 'set-calc-imsak-field', '20');
      expect(rig.settings.calculation.params.imsakMinutes, 20);
      expect(previewOf(tester, Prayer.imsak), '04:50');
    });

    testWidgets('restore defaults brings back the method values', (
      tester,
    ) async {
      final rig = await open(tester, SettingsSection.calculation);
      expect(
        tester.widget<OutlinedButton>(k('set-calc-restore')).onPressed,
        isNull,
        reason: 'nothing to restore yet',
      );
      await pickOption(tester, 'set-calc-method', 'set-calc-method-item', 2);
      await pickOption(tester, 'set-calc-asr', 'set-calc-asr-item', 1);
      await tapKey(tester, 'set-calc-imsak-inc');
      expect(
        rig.settings.calculation.params,
        isNot(CalculationMethod.mwl.params),
      );
      await tapKey(tester, 'set-calc-restore');
      expect(rig.settings.calculation.params, CalculationMethod.mwl.params);
      expect(rig.settings.calculation.method, CalculationMethod.mwl);
    });

    testWidgets('minute offsets per prayer and the reset button', (
      tester,
    ) async {
      final rig = await open(tester, SettingsSection.calculation);
      final before = previewOf(tester, Prayer.dhuhr);
      await tapKey(tester, 'set-offset-dhuhr-inc');
      expect(rig.settings.calculation.offsetsMinutes[Prayer.dhuhr], 1);
      expect(previewOf(tester, Prayer.dhuhr), isNot(before));
      await typeKey(tester, 'set-offset-fajr-field', '-30');
      expect(rig.settings.calculation.offsetsMinutes[Prayer.fajr], -30);
      await typeKey(tester, 'set-offset-isha-field', '+60');
      expect(rig.settings.calculation.offsetsMinutes[Prayer.isha], 60);
      expect(
        tester.widget<IconButton>(k('set-offset-isha-inc')).onPressed,
        isNull,
      );
      await typeKey(tester, 'set-offset-asr-field', '61');
      expect(rig.settings.calculation.offsetsMinutes[Prayer.asr], isNull);

      await tapKey(tester, 'set-offsets-reset');
      expect(rig.settings.calculation.offsetsMinutes, isEmpty);
      expect(previewOf(tester, Prayer.dhuhr), before);
      expect(
        tester.widget<OutlinedButton>(k('set-offsets-reset')).onPressed,
        isNull,
      );
    });

    testWidgets('which rows to show', (tester) async {
      final rig = await open(tester, SettingsSection.calculation);
      expect(rig.settings.display.showImsak, isFalse);
      await tapSwitch(tester, 'set-rows-imsak');
      expect(rig.settings.display.showImsak, isTrue);
      await tapSwitch(tester, 'set-rows-asr');
      await tapSwitch(tester, 'set-rows-isha');
      await tapSwitch(tester, 'set-rows-sunset');
      expect(rig.settings.display.showAsr, isFalse);
      expect(rig.settings.display.showIsha, isFalse);
      expect(rig.settings.display.showSunset, isFalse);
      // The five fixed rows are not offered.
      expect(k('set-rows-fajr'), findsNothing);
      expect(k('set-rows-midnight'), findsNothing);
    });

    testWidgets('the live preview shows the nine times of today', (
      tester,
    ) async {
      await open(tester, SettingsSection.calculation);
      for (final prayer in Prayer.values) {
        expect(k('set-preview-${prayer.name}'), findsOneWidget);
      }
      // 2026-11-11 in Tehran (the golden values of the home screen tests).
      expect(previewOf(tester, Prayer.imsak), '05:00');
      expect(previewOf(tester, Prayer.sunrise), '06:36');
      expect(previewOf(tester, Prayer.asr), '14:39');
      expect(previewOf(tester, Prayer.sunset), '17:00');
      expect(previewOf(tester, Prayer.maghrib), '17:20');
      expect(previewOf(tester, Prayer.midnight), '23:06');
    });

    testWidgets('a time that does not occur shows a dash', (tester) async {
      final rig = await open(tester, SettingsSection.calculation);
      rig.container.read(settingsProvider.notifier)
        ..addLocation(
          const SavedLocation.custom(
            id: 'custom:1',
            name: 'Far north',
            latitude: 80,
            longitude: 15,
            zoneId: 'Europe/Berlin',
          ),
        )
        ..setParams(
          rig.settings.calculation.params.copyWith(
            highLatitude: HighLatitudeRule.none,
          ),
        );
      await tester.pumpAndSettle();
      final dashes = [
        for (final prayer in Prayer.values)
          if (previewOf(tester, prayer) == '—') prayer,
      ];
      expect(dashes, isNotEmpty);
    });
  });

  group('Time', () {
    testWidgets('network check, status and diagnostics', (tester) async {
      final rig = await open(tester, SettingsSection.time);
      expect(rig.settings.networkTime.enabled, isFalse);
      expect(find.text('Not checked yet.'), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(k('set-time-check-now')).onPressed,
        isNull,
      );
      expect(
        tester
            .widget<Switch>(
              find.descendant(
                of: k('set-time-correct'),
                matching: find.byType(Switch),
              ),
            )
            .onChanged,
        isNull,
      );
      expect(find.text('No clock problem found.'), findsOneWidget);

      rig.ntp.offset = const Duration(seconds: 45);
      await tapSwitch(tester, 'set-time-enabled');
      expect(rig.settings.networkTime.enabled, isTrue);
      expect(rig.ntp.hosts, ['pool.ntp.org']);
      expect(textOf(tester, 'set-time-status'), contains('45 s behind'));
      expect(textOf(tester, 'set-time-status'), contains('Checked at 15:30'));
      // A skew of 30 s or more shows the clock warning.
      expect(
        find.descendant(
          of: k('set-time-diagnosis'),
          matching: find.text('The PC clock is off by about 45 s.'),
        ),
        findsOneWidget,
      );

      await tapSwitch(tester, 'set-time-correct');
      expect(rig.settings.networkTime.applyCorrection, isTrue);
      // The correction applies inside the app only.
      expect(
        rig.container.read(effectiveCorrectionProvider),
        const Duration(seconds: 45),
      );

      rig.ntp.offset = const Duration(seconds: -3);
      await tapKey(tester, 'set-time-check-now');
      expect(rig.ntp.hosts, hasLength(2));
      expect(textOf(tester, 'set-time-status'), contains('3 s ahead'));
      await rig.stopNetworkTime(tester);
    });

    testWidgets('a failed check shows a plain message, never the exception', (
      tester,
    ) async {
      final rig = await open(tester, SettingsSection.time);
      rig.ntp.error = Exception('socket 10061 secret detail');
      await tapSwitch(tester, 'set-time-enabled');
      final status = textOf(tester, 'set-time-status');
      expect(status, startsWith('Could not reach the time server'));
      expect(status, isNot(contains('secret')));
      expect(status, isNot(contains('Exception')));
      await rig.stopNetworkTime(tester);
    });

    testWidgets('the server name is validated and stored', (tester) async {
      final rig = await open(tester, SettingsSection.time);
      expect(rig.settings.networkTime.host, 'pool.ntp.org');
      await typeKey(tester, 'set-time-server', 'time.windows.com');
      expect(rig.settings.networkTime.host, 'time.windows.com');
      await typeKey(tester, 'set-time-server', 'not a host!');
      expect(rig.settings.networkTime.host, 'time.windows.com');
      expect(find.text('The server name is not valid.'), findsOneWidget);
      await typeKey(tester, 'set-time-server', '  ntp.example.org ');
      expect(rig.settings.networkTime.host, 'ntp.example.org');
      expect(find.text('The server name is not valid.'), findsNothing);
    });

    testWidgets('stale Windows zone rules are explained', (tester) async {
      final rig = await open(tester, SettingsSection.time);
      // The fake Windows zone is +03:30; Kabul is +04:30 in the database, so
      // Windows disagrees with the database by exactly one hour.
      rig.container
          .read(settingsProvider.notifier)
          .addLocation(
            const SavedLocation.custom(
              id: 'custom:1',
              name: 'Kabul',
              latitude: 34.53,
              longitude: 69.17,
              zoneId: 'Asia/Kabul',
            ),
          );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: k('set-time-diagnosis'),
          matching: find.textContaining('different time for this place'),
        ),
        findsOneWidget,
      );
      expect(textOf(tester, 'set-time-windows-offset'), contains('UTC+03:30'));
      expect(textOf(tester, 'set-time-database-offset'), contains('UTC+04:30'));
    });
  });
}
