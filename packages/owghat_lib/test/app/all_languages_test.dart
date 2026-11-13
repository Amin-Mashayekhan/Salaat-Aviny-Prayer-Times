import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/core/platform/platform_capabilities.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/diagnostics/presentation/about_diagnostics_section.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

import '../support/app_harness.dart';
import '../support/test_data.dart';

/// Every language shows every screen and every settings section without a
/// layout error, with the right reading direction, digits and texts.
void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  // Desktop windows, and a phone in portrait with the phone's capabilities
  // (bottom navigation, no tray, no Wake-up screen).
  const layouts = [
    (Size(1200, 800), PlatformCapabilities.desktop, 'desktop'),
    (Size(800, 560), PlatformCapabilities.desktop, 'desktop'),
    (Size(390, 844), PlatformCapabilities.mobile, 'phone'),
    (Size(360, 740), PlatformCapabilities.mobile, 'phone'),
    (Size(1200, 800), PlatformCapabilities.web, 'browser'),
    (Size(390, 844), PlatformCapabilities.web, 'browser'),
  ];

  for (final language in AppLanguage.values) {
    for (final (size, capabilities, kind) in layouts) {
      testWidgets('${language.name} $kind ${size.width.toInt()}px: all screens '
          'and settings sections', (tester) async {
        final harness = await AppHarness.pump(
          tester,
          repository: repo,
          size: size,
          settings: AppSettings(language: language, digits: language.digits),
          overrides: [
            platformCapabilitiesProvider.overrideWithValue(capabilities),
            aboutSectionBuilderProvider.overrideWithValue(
              (context) => const AboutDiagnosticsSection(),
            ),
          ],
        );
        final shell = tester.element(find.byType(Scaffold).first);
        final l10n = AppLocalizations.of(shell);
        expect(l10n.localeName, language.name);
        expect(
          Directionality.of(shell),
          language.rtl ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(find.text(Destination.home.label(l10n)), findsWidgets);

        for (final destination in harness.container.read(
          visibleDestinationsProvider,
        )) {
          harness.container
              .read(destinationProvider.notifier)
              .select(destination);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${language.name} ${destination.name}',
          );
          if (destination == Destination.settings) {
            for (final section in SettingsSection.values) {
              harness.container
                  .read(selectedSettingsSectionProvider.notifier)
                  .select(section);
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: '${language.name} settings ${section.name}',
              );
            }
          }
        }
      });
    }
  }

  testWidgets('the language chips list every language by its own name', (
    tester,
  ) async {
    final harness = await AppHarness.pump(
      tester,
      repository: repo,
      settings: englishSettings,
    );
    harness.container
        .read(destinationProvider.notifier)
        .select(Destination.settings);
    harness.container
        .read(selectedSettingsSectionProvider.notifier)
        .select(SettingsSection.display);
    await tester.pumpAndSettle();
    for (final language in AppLanguage.values) {
      expect(find.text(language.nativeName), findsOneWidget);
    }
  });

  testWidgets('choosing a language in the settings switches the whole app', (
    tester,
  ) async {
    final harness = await AppHarness.pump(
      tester,
      repository: repo,
      settings: englishSettings,
    );
    harness.container
        .read(destinationProvider.notifier)
        .select(Destination.settings);
    harness.container
        .read(selectedSettingsSectionProvider.notifier)
        .select(SettingsSection.display);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        Key('set-language-${AppLanguage.values.indexOf(AppLanguage.ar)}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(harness.current.language, AppLanguage.ar);
    final shell = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(shell), TextDirection.rtl);
    expect(AppLocalizations.of(shell).localeName, 'ar');
  });
}
