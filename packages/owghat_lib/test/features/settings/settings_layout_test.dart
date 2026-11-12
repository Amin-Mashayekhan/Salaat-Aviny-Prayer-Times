import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/presentation/settings_page.dart';

import '../../support/app_harness.dart';
import '../../support/settings_rig.dart';
import '../../support/test_data.dart';

/// Layout and rendering of the whole settings screen: every section in both
/// languages, both themes, the largest and smallest window and both text
/// scales, with no overflow or other exception.
void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  AppSettings twoLocations(AppSettings base) => base.copyWith(
    locations: [
      ...base.locations,
      const SavedLocation.custom(
        id: 'custom:1',
        name: 'Berlin office',
        latitude: 52.52,
        longitude: 13.405,
        zoneId: 'Europe/Berlin',
        elevationMeters: 34,
      ),
    ],
  );

  const sizes = {'1200x800': Size(1200, 800), '800x560': Size(800, 560)};

  for (final persian in [true, false]) {
    for (final dark in [false, true]) {
      for (final size in sizes.entries) {
        for (final scale in [1.0, 2.0]) {
          final name =
              '${persian ? 'fa' : 'en'} ${dark ? 'dark' : 'light'} '
              '${size.key} x$scale';
          testWidgets('every section renders: $name', (tester) async {
            final rig = await SettingsRig.open(
              tester,
              repository: repo,
              settings: twoLocations(
                persian ? persianSettings : englishSettings,
              ),
              size: size.value,
              textScale: scale,
              brightness: dark ? Brightness.dark : Brightness.light,
            );
            expect(find.byType(SettingsPage), findsOneWidget);
            final l10n = AppLocalizations.of(
              tester.element(find.byType(SettingsPage)),
            );
            for (final section in SettingsSection.values) {
              await rig.show(tester, section);
              expect(
                find.text(section.title(l10n)),
                findsWidgets,
                reason: '${section.name} title',
              );
              expect(
                tester.takeException(),
                isNull,
                reason: '${section.name} in $name',
              );
            }
            expect(tester.takeException(), isNull);
          });

          testWidgets('open panels and dialogs lay out: $name', (tester) async {
            final rig = await SettingsRig.open(
              tester,
              repository: repo,
              settings: twoLocations(
                persian ? persianSettings : englishSettings,
              ),
              size: size.value,
              textScale: scale,
              brightness: dark ? Brightness.dark : Brightness.light,
            );
            // Location: edit panel of both locations, fixed-offset editor,
            // the add forms with their errors, the delete dialog.
            await tapKey(tester, 'set-loc-edit-city:1');
            await tapKey(tester, 'set-loc-city:1-offset-mode-1');
            await tapKey(tester, 'set-loc-edit-custom:1');
            await tapKey(tester, 'set-loc-add-mode-2');
            await tapKey(tester, 'set-loc-submit');
            await tapKey(tester, 'set-loc-format-1');
            await tapKey(tester, 'set-loc-submit');
            await tapKey(tester, 'set-loc-delete-custom:1');
            expect(find.byType(AlertDialog), findsOneWidget);
            await tapKey(tester, 'set-dialog-cancel');
            expect(tester.takeException(), isNull);

            // Database search and province drop-down.
            await tapKey(tester, 'set-loc-add-mode-0');
            await typeKey(tester, 'set-loc-search', 'ma', submit: false);
            await tapKey(tester, 'set-loc-province');
            await tester.tapAt(const Offset(2, 2));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);

            // Azan: the mute menu and a failed preview note.
            await rig.show(tester, SettingsSection.azan);
            await tapKey(tester, 'set-azan-mute');
            await tester.tapAt(const Offset(2, 2));
            await tester.pumpAndSettle();
            rig.audio.failAll = true;
            await tapKey(tester, 'set-azan-preview-fajr');
            expect(k('set-azan-note-fajr'), findsOneWidget);
            expect(tester.takeException(), isNull);

            // Calculation: Isha in minutes, Maghrib at sunset, an error.
            await rig.show(tester, SettingsSection.calculation);
            await tapKey(tester, 'set-calc-isha-mode-1');
            await tapKey(tester, 'set-calc-maghrib');
            await typeKey(tester, 'set-calc-fajr', '99');
            expect(tester.takeException(), isNull);

            // Time: enabled with a failing server.
            await rig.show(tester, SettingsSection.time);
            rig.ntp.error = Exception('boom');
            rig.container
                .read(settingsProvider.notifier)
                .setNetworkTime(
                  rig.settings.networkTime.copyWith(enabled: true),
                );
            await tester.pumpAndSettle();
            expect(k('set-time-status'), findsOneWidget);
            await tapKey(tester, 'set-time-check-now');
            expect(tester.takeException(), isNull);
            await rig.stopNetworkTime(tester);

            // App: both confirmation dialogs.
            await rig.show(tester, SettingsSection.app);
            await tapKey(tester, 'set-reset');
            expect(find.byType(AlertDialog), findsOneWidget);
            await tapKey(tester, 'set-dialog-cancel');
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  testWidgets('a narrow window collapses the section list to a drop-down', (
    tester,
  ) async {
    final rig = await SettingsRig.open(
      tester,
      repository: repo,
      size: const Size(520, 760),
    );
    expect(k('settings-section-dropdown'), findsOneWidget);
    expect(k('settings-section-calculation'), findsNothing);
    await pickOption(
      tester,
      'settings-section-dropdown',
      'settings-section-item',
      SettingsSection.display.index,
    );
    expect(
      rig.container.read(selectedSettingsSectionProvider),
      SettingsSection.display,
    );
    expect(k('set-theme-0'), findsOneWidget);
  });

  testWidgets('a wide window shows the section list beside the content', (
    tester,
  ) async {
    final rig = await SettingsRig.open(tester, repository: repo);
    expect(k('settings-section-dropdown'), findsNothing);
    for (final section in SettingsSection.values) {
      expect(k('settings-section-${section.name}'), findsOneWidget);
    }
    await tapKey(tester, 'settings-section-azan');
    expect(
      rig.container.read(selectedSettingsSectionProvider),
      SettingsSection.azan,
    );
    expect(k('set-azan-card-fajr'), findsOneWidget);
    // The list is on the start side: left in English, right in Persian.
    final listX = tester.getCenter(k('settings-section-azan')).dx;
    expect(listX, lessThan(tester.view.physicalSize.width / 2));
  });

  testWidgets('the list sits on the right in Persian', (tester) async {
    await SettingsRig.open(tester, repository: repo, settings: persianSettings);
    final listX = tester.getCenter(k('settings-section-azan')).dx;
    final contentX = tester.getCenter(k('set-loc-name-city:1')).dx;
    expect(listX, greaterThan(contentX));
  });
}
