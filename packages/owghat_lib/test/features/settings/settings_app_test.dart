import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/presentation/settings_page.dart';
import 'package:owghat_lib/src/features/window/application/autostart_controller.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/app_harness.dart';
import '../../support/settings_rig.dart';
import '../../support/test_data.dart';

/// Section 7 (app, backup, reset), the saved tick, the About slot, the
/// registration in the shell, and the "no daylight-saving control" rule.
void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  Future<SettingsRig> open(
    WidgetTester tester, {
    SettingsSection section = SettingsSection.app,
    AppSettings? settings,
  }) => SettingsRig.open(
    tester,
    repository: repo,
    section: section,
    settings: settings,
  );

  String message(WidgetTester tester) => textOf(tester, 'set-app-message');

  group('App', () {
    testWidgets('start with Windows follows through the autostart controller', (
      tester,
    ) async {
      final rig = await open(tester);
      // `bootstrap` starts the controller; do the same here.
      await rig.container.read(autostartControllerProvider).start();
      expect(rig.autostart.enabled, isFalse);

      await tapSwitch(tester, 'set-app-autostart');
      expect(rig.settings.window.launchAtStartup, isTrue);
      expect(rig.autostart.enabled, isTrue);
      expect(rig.autostart.enableCalls, greaterThan(0));

      await tapSwitch(tester, 'set-app-autostart');
      expect(rig.settings.window.launchAtStartup, isFalse);
      expect(rig.autostart.enabled, isFalse);
      expect(rig.autostart.disableCalls, greaterThan(0));
    });

    testWidgets('start minimised and close to tray', (tester) async {
      final rig = await open(tester);
      expect(switchValue(tester, 'set-app-minimized'), isTrue);
      await tapSwitch(tester, 'set-app-minimized');
      expect(rig.settings.window.startMinimized, isFalse);
      expect(switchValue(tester, 'set-app-close-to-tray'), isTrue);
      await tapSwitch(tester, 'set-app-close-to-tray');
      expect(rig.settings.window.closeToTray, isFalse);
      // Nothing else moved.
      expect(rig.settings.window.launchAtStartup, isFalse);
    });

    testWidgets('export writes a backup file and reports the path', (
      tester,
    ) async {
      final rig = await open(tester);
      rig.container.read(settingsProvider.notifier).setTheme(ThemeSetting.dark);
      rig.dialogs.savePath = r'C:\Backups\owghat.json';
      await tapKey(tester, 'set-backup-export');
      final written = jsonDecode(
        rig.files.files[r'C:\Backups\owghat.json']!,
      ) as Map<String, Object?>;
      expect(written['theme'], 'dark');
      expect(written['locations'], isNotEmpty);
      expect(message(tester), contains(r'C:\Backups\owghat.json'));
      // Exporting is not a change of the settings.
      expect(rig.settings.theme, ThemeSetting.dark);
    });

    testWidgets('a cancelled or failed export is handled', (tester) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-backup-export');
      expect(rig.files.files, isEmpty);
      expect(k('set-app-message'), findsNothing);

      rig.dialogs.savePath = '/x/backup.json';
      rig.files.failWrite = true;
      await tapKey(tester, 'set-backup-export');
      expect(message(tester), 'The backup could not be saved.');
    });

    testWidgets('import asks first, then replaces the settings', (
      tester,
    ) async {
      final rig = await open(tester);
      final backup = const AppSettings.defaults().copyWith(
        theme: ThemeSetting.dark,
        hourFormat: HourFormat.h12,
        language: AppLanguage.en,
        digits: DigitStyle.latin,
        hijriAdjustmentDays: 1,
      );
      rig.files.files['/in/backup.json'] = jsonEncode(backup.toJson());
      rig.dialogs.openPath = '/in/backup.json';

      // Cancelling the dialog keeps everything.
      await tapKey(tester, 'set-backup-import');
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Restore the settings?'), findsOneWidget);
      expect(rig.settings.theme, ThemeSetting.system);
      await tapKey(tester, 'set-dialog-cancel');
      expect(find.byType(AlertDialog), findsNothing);
      expect(rig.settings.theme, ThemeSetting.system);
      expect(rig.settings.hijriAdjustmentDays, 0);

      await tapKey(tester, 'set-backup-import');
      await tapKey(tester, 'set-import-confirm');
      expect(rig.settings.theme, ThemeSetting.dark);
      expect(rig.settings.hourFormat, HourFormat.h12);
      expect(rig.settings.hijriAdjustmentDays, 1);
      // The first-run flow does not come back.
      expect(rig.settings.onboardingCompleted, isTrue);
      expect(message(tester), 'The settings were restored.');
    });

    testWidgets('an export can be imported again (round trip)', (tester) async {
      final rig = await open(tester);
      rig.container.read(settingsProvider.notifier)
        ..setTheme(ThemeSetting.light)
        ..setPrayerOffset(Prayer.fajr, 7)
        ..addLocation(
          const SavedLocation.custom(
            id: 'custom:1',
            name: 'Round trip',
            latitude: 36.3,
            longitude: 59.6,
            zoneId: 'Asia/Tehran',
          ),
        );
      final saved = rig.settings;
      rig.dialogs
        ..savePath = '/b.json'
        ..openPath = '/b.json';
      await tapKey(tester, 'set-backup-export');
      rig.container.read(settingsProvider.notifier).resetToDefaults();
      await tester.pumpAndSettle();
      expect(rig.settings, isNot(saved));
      await tapKey(tester, 'set-backup-import');
      await tapKey(tester, 'set-import-confirm');
      expect(rig.settings, saved);
    });

    for (final bad in [
      'this is not json',
      '{"hello": "world"}',
      '[1, 2, 3]',
      '',
      // Looks like a backup but names a time zone that does not exist.
      '{"locations": [{"id": "custom:1", "kind": "custom", "name": "X", "latitude": 1, "longitude": 2, "zoneId": "Mars/Olympus"}]}',
    ]) {
      testWidgets('an invalid backup shows an error and changes nothing: '
          '"${bad.length > 18 ? bad.substring(0, 18) : bad}"', (tester) async {
        final rig = await open(tester);
        rig.container
            .read(settingsProvider.notifier)
            .setTheme(ThemeSetting.dark);
        final before = rig.settings;
        rig.files.files['/bad.json'] = bad;
        rig.dialogs.openPath = '/bad.json';
        await tapKey(tester, 'set-backup-import');
        expect(find.byType(AlertDialog), findsNothing);
        expect(message(tester), contains('not a valid settings backup'));
        expect(rig.settings, before);
      });
    }

    testWidgets('an unreadable file or a cancelled dialog changes nothing', (
      tester,
    ) async {
      final rig = await open(tester);
      final before = rig.settings;
      rig.dialogs.openPath = '/missing.json';
      await tapKey(tester, 'set-backup-import');
      expect(message(tester), contains('could not be read'));
      expect(rig.settings, before);
      rig.dialogs.openPath = null;
      await tapKey(tester, 'set-backup-import');
      expect(find.byType(AlertDialog), findsNothing);
      expect(rig.settings, before);
    });

    testWidgets('reset to defaults asks first', (tester) async {
      final rig = await open(tester);
      rig.container.read(settingsProvider.notifier)
        ..setTheme(ThemeSetting.dark)
        ..setAzanEnabled(enabled: false)
        ..addLocation(
          const SavedLocation.custom(
            id: 'custom:1',
            name: 'Elsewhere',
            latitude: 10,
            longitude: 20,
            zoneId: 'Asia/Tehran',
          ),
        );
      final changed = rig.settings;

      await tapKey(tester, 'set-reset');
      expect(find.text('Clear all settings?'), findsOneWidget);
      await tapKey(tester, 'set-dialog-cancel');
      expect(rig.settings, changed);

      await tapKey(tester, 'set-reset');
      await tapKey(tester, 'set-reset-confirm');
      expect(
        rig.settings,
        const AppSettings.defaults().copyWith(onboardingCompleted: true),
      );
      expect(rig.settings.locations, hasLength(1));
      // The language went back to Persian along with everything else.
      expect(
        AppLocalizations.of(tester.element(find.byType(SettingsPage)))
            .localeName,
        'fa',
      );
    });
  });

  group('screen behaviour', () {
    testWidgets('a small tick confirms each change', (tester) async {
      final rig = await open(tester, section: SettingsSection.display);
      expect(k('settings-saved-tick'), findsNothing);
      await tapKey(tester, 'set-theme-2');
      expect(k('settings-saved-tick'), findsOneWidget);
      expect(textOf(tester, 'settings-saved-tick'), 'Saved');
      expect(rig.container.read(settingsSavedCountProvider), 1);
      await tapKey(tester, 'set-theme-1');
      expect(rig.container.read(settingsSavedCountProvider), 2);
    });

    testWidgets('opening a screen never writes a setting', (tester) async {
      final rig = await open(tester, section: SettingsSection.location);
      final before = rig.settings;
      for (final section in SettingsSection.values) {
        await rig.show(tester, section);
      }
      await rig.show(tester, SettingsSection.location);
      await tapKey(tester, 'set-loc-edit-city:1');
      await tapKey(tester, 'set-loc-edit-city:1');
      expect(rig.settings, before);
      expect(rig.container.read(settingsSavedCountProvider), 0);
    });

    testWidgets('the About section is a slot another feature can fill', (
      tester,
    ) async {
      final rig = await open(tester, section: SettingsSection.about);
      expect(find.byKey(const Key('settings-about-slot')), findsOneWidget);
      expect(find.textContaining('diagnostics page appear'), findsOneWidget);
      expect(rig.container.read(aboutSectionBuilderProvider), isNotNull);
    });

    testWidgets('an overridden about builder replaces the placeholder', (
      tester,
    ) async {
      await SettingsRig.open(
        tester,
        repository: repo,
        section: SettingsSection.about,
        overrides: [
          aboutSectionBuilderProvider.overrideWithValue(
            (context) => const Text('About widget from the other feature'),
          ),
        ],
      );
      expect(find.text('About widget from the other feature'), findsOneWidget);
      expect(find.textContaining('diagnostics page appear'), findsNothing);
    });

    testWidgets('the settings destination of the shell shows this page', (
      tester,
    ) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: SettingsRig.now,
        settings: englishSettings,
      );
      expect(find.byType(SettingsPage), findsNothing);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(harness.container.read(destinationProvider), Destination.settings);
    });
  });

  group('no daylight-saving control anywhere', () {
    final forbidden = RegExp(
      'dst|daylight|summer|winter|تابستانی|زمستانی',
      caseSensitive: false,
    );

    test('no settings string of either language mentions it', () {
      // Read the ARB files directly: every settings* key, both languages.
      for (final name in ['app_en.arb', 'app_fa.arb']) {
        final arb = jsonDecode(
          File('lib/l10n/$name').readAsStringSync(),
        ) as Map<String, Object?>;
        for (final entry in arb.entries) {
          if (entry.key.startsWith('settings') && entry.value is String) {
            expect(
              forbidden.hasMatch(entry.value! as String),
              isFalse,
              reason: '$name ${entry.key}',
            );
          }
        }
      }
    });

    for (final persian in [false, true]) {
      testWidgets(
        'no widget of any section shows it (${persian ? 'fa' : 'en'})',
        (tester) async {
          final rig = await open(
            tester,
            section: SettingsSection.location,
            settings: persian ? persianSettings : englishSettings,
          );
          // Everything that shows time-zone information: an automatic zone with
          // a planned change, a fixed offset, the add forms, the time section.
          rig.container
              .read(settingsProvider.notifier)
              .addLocation(
                const SavedLocation.custom(
                  id: 'custom:1',
                  name: 'Berlin',
                  latitude: 52.5,
                  longitude: 13.4,
                  zoneId: 'Europe/Berlin',
                ),
              );
          await tester.pumpAndSettle();
          await tapKey(tester, 'set-loc-edit-custom:1');
          await tapKey(tester, 'set-loc-add-mode-2');
          final seen = <String>[...allStrings(tester)];
          await tapKey(tester, 'set-loc-custom:1-offset-mode-1');
          seen.addAll(allStrings(tester));
          for (final section in SettingsSection.values) {
            await rig.show(tester, section);
            seen.addAll(allStrings(tester));
          }
          expect(seen, isNotEmpty);
          for (final text in seen) {
            expect(forbidden.hasMatch(text), isFalse, reason: text);
          }
        },
      );
    }

    testWidgets('the zone row offers only automatic and fixed offset', (
      tester,
    ) async {
      await open(tester, section: SettingsSection.location);
      await tapKey(tester, 'set-loc-edit-city:1');
      expect(find.text('Automatic (recommended)'), findsOneWidget);
      expect(find.text('Fixed offset'), findsOneWidget);
      expect(
        find.descendant(of: k('set-loc-city:1'), matching: find.byType(Switch)),
        findsNothing,
      );
      expect(
        find.descendant(
          of: k('set-loc-city:1'),
          matching: find.byType(ChoiceChip),
        ),
        findsNWidgets(2),
      );
    });
  });
}
