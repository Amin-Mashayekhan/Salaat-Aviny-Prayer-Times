import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/onboarding/application/onboarding_providers.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';

import '../../support/app_harness.dart';
import '../../support/test_data.dart';

// 20 Aban 1405, 15:30 in Tehran.
final _now = DateTime.utc(2026, 11, 11, 12);

void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  Future<AppHarness> open(
    WidgetTester tester, {
    AppSettings? settings,
    Size size = const Size(1200, 800),
    double textScale = 1,
    Brightness brightness = Brightness.light,
    List<Override> overrides = const [],
  }) => AppHarness.pump(
    tester,
    repository: repo,
    now: _now,
    settings: settings,
    size: size,
    textScale: textScale,
    brightness: brightness,
    overrides: overrides,
    onboardingDone: false,
  );

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  group('flow', () {
    testWidgets('is shown instead of the shell and starts at step 1', (
      tester,
    ) async {
      final harness = await open(tester);
      expect(find.byKey(const Key('onboarding-card')), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(text(tester, 'onboarding-progress-text'), 'مرحله ۱ از ۳');
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byKey(const Key('onboarding-progress')),
            )
            .value,
        closeTo(1 / 3, 1e-9),
      );
      expect(find.byKey(const Key('onboarding-language-fa')), findsOneWidget);
      // Showing the flow changes no setting.
      expect(
        harness.current,
        const AppSettings.defaults().copyWith(onboardingCompleted: false),
      );
    });

    testWidgets('three steps, then Home with the countdown running', (
      tester,
    ) async {
      final harness = await open(tester);
      await tapKey(tester, 'onboarding-next');
      expect(text(tester, 'onboarding-progress-text'), 'مرحله ۲ از ۳');
      expect(find.byKey(const Key('onboarding-search')), findsOneWidget);
      expect(find.byKey(const Key('onboarding-back')), findsOneWidget);

      await tapKey(tester, 'onboarding-next');
      expect(text(tester, 'onboarding-progress-text'), 'مرحله ۳ از ۳');
      expect(find.byKey(const Key('onboarding-preview')), findsOneWidget);
      expect(find.text('شروع'), findsOneWidget);
      expect(harness.current.onboardingCompleted, isFalse);

      await tapKey(tester, 'onboarding-next');
      expect(harness.current.onboardingCompleted, isTrue);
      expect(find.byKey(const Key('onboarding-card')), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byKey(const Key('hero-countdown')), findsOneWidget);
      expect(text(tester, 'hero-countdown'), '۰۱:۳۰:۰۰');
    });

    testWidgets('back returns to the previous step', (tester) async {
      await open(tester);
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-back');
      expect(text(tester, 'onboarding-progress-text'), 'مرحله ۱ از ۳');
      expect(find.byKey(const Key('onboarding-back')), findsNothing);
    });

    testWidgets('skip finishes at once and keeps every default', (
      tester,
    ) async {
      final harness = await open(tester);
      await tapKey(tester, 'onboarding-skip');
      expect(
        harness.current,
        const AppSettings.defaults().copyWith(onboardingCompleted: true),
      );
      expect(find.byKey(const Key('hero-countdown')), findsOneWidget);
    });

    testWidgets('skip is available on every step', (tester) async {
      await open(tester);
      await tapKey(tester, 'onboarding-next');
      expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);
      await tapKey(tester, 'onboarding-next');
      expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);
    });
  });

  group('language step', () {
    testWidgets('English switches the UI and the digits at once', (
      tester,
    ) async {
      final harness = await open(tester);
      await tapKey(tester, 'onboarding-language-en');
      expect(harness.current.language, AppLanguage.en);
      expect(harness.current.digits, DigitStyle.latin);
      expect(text(tester, 'onboarding-progress-text'), 'Step 1 of 3');
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.byKey(const Key('onboarding-card'))),
        ),
        TextDirection.ltr,
      );
      await tapKey(tester, 'onboarding-language-fa');
      expect(harness.current.language, AppLanguage.fa);
      expect(harness.current.digits, DigitStyle.persian);
      expect(find.text('بعدی'), findsOneWidget);
    });
  });

  group('city step', () {
    testWidgets('Tehran is preselected and the empty search lists centres', (
      tester,
    ) async {
      await open(tester);
      await tapKey(tester, 'onboarding-next');
      expect(text(tester, 'onboarding-selected'), 'مکان انتخاب‌شده: تهران');
      expect(find.byKey(const Key('onboarding-city-1')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('onboarding-city-1')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('typing searches live and selecting adds and activates', (
      tester,
    ) async {
      final harness = await open(tester);
      await tapKey(tester, 'onboarding-next');
      final mashhad = repo.search('مشهد').first;

      await tester.enterText(
        find.byKey(const Key('onboarding-search')),
        'مشهد',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(Key('onboarding-city-${mashhad.id}')), findsOneWidget);
      // The search ignores letter variants: Arabic yeh/kaf spellings match.
      await tester.enterText(
        find.byKey(const Key('onboarding-search')),
        'مشهد',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('onboarding-city-${mashhad.id}')));
      await tester.pumpAndSettle();
      expect(harness.current.activeLocationId, 'city:${mashhad.id}');
      expect(harness.current.locations.length, 2);
      expect(harness.current.activeLocation.cityId, mashhad.id);
      expect(text(tester, 'onboarding-selected'), 'مکان انتخاب‌شده: مشهد');

      // Choosing an already saved city only activates it.
      await tester.enterText(
        find.byKey(const Key('onboarding-search')),
        'تهران',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-city-1')));
      await tester.pumpAndSettle();
      expect(harness.current.activeLocationId, 'city:1');
      expect(harness.current.locations.length, 2);
    });

    testWidgets('English names are searchable too', (tester) async {
      final harness = await open(tester, settings: englishSettings);
      await tapKey(tester, 'onboarding-next');
      final shiraz = repo.search('shiraz').first;
      await tester.enterText(
        find.byKey(const Key('onboarding-search')),
        'shiraz',
      );
      await tester.pumpAndSettle();
      expect(find.text('Shiraz'), findsWidgets);
      await tester.tap(find.byKey(Key('onboarding-city-${shiraz.id}')));
      await tester.pumpAndSettle();
      expect(harness.current.activeLocation.cityId, shiraz.id);
      expect(text(tester, 'onboarding-selected'), 'Selected: Shiraz');
    });

    testWidgets('province chips narrow the list', (tester) async {
      await open(tester);
      await tapKey(tester, 'onboarding-next');
      final mashhad = repo.search('مشهد').first;
      final province = mashhad.provinceId;
      final inProvince = repo.citiesOf(province);
      expect(inProvince.length, greaterThan(1));

      final chip = find.byKey(Key('onboarding-province-$province'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      // The first cities of the province are listed; Tehran is not.
      expect(
        find.byKey(Key('onboarding-city-${inProvince.first.id}')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('onboarding-city-1')), findsNothing);

      // A search inside the province still filters by province.
      await tester.enterText(
        find.byKey(const Key('onboarding-search')),
        'مشهد',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(Key('onboarding-city-${mashhad.id}')), findsOneWidget);

      // Back to all provinces with an empty search: the province centres.
      await tester.enterText(find.byKey(const Key('onboarding-search')), '');
      await tester.pumpAndSettle();
      final all = find.byKey(const Key('onboarding-province-all'));
      await tester.ensureVisible(all);
      await tester.pumpAndSettle();
      await tester.tap(all);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('onboarding-city-1')), findsOneWidget);
    });

    testWidgets('no result shows a message, the query survives a step trip', (
      tester,
    ) async {
      await open(tester);
      await tapKey(tester, 'onboarding-next');
      await tester.enterText(
        find.byKey(const Key('onboarding-search')),
        'zzzqqq',
      );
      await tester.pumpAndSettle();
      expect(find.text('شهری پیدا نشد.'), findsOneWidget);
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-back');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('onboarding-search')))
            .controller!
            .text,
        'zzzqqq',
      );
    });
  });

  group('azan step', () {
    testWidgets('the preview button calls the injected function', (
      tester,
    ) async {
      var previews = 0;
      await open(
        tester,
        overrides: [
          onboardingPreviewProvider.overrideWithValue(() async {
            previews++;
          }),
        ],
      );
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-preview');
      expect(previews, 1);
    });

    testWidgets('the default preview plays the bundled azan and the button '
        'turns into Stop (it used to do nothing)', (tester) async {
      final audio = FakeAudioOutput();
      final harness = await open(
        tester,
        overrides: [audioOutputProvider.overrideWithValue(audio)],
      );
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-preview');
      expect(tester.takeException(), isNull);
      expect(audio.plays.single.sound, SoundRef.defaultAzan);
      expect(find.byKey(const Key('onboarding-stop')), findsOneWidget);
      expect(harness.current.onboardingCompleted, isFalse);

      await tapKey(tester, 'onboarding-stop');
      expect(audio.stopCount, 1);
      expect(find.byKey(const Key('onboarding-preview')), findsOneWidget);
    });

    testWidgets('a failing preview does not crash the step', (tester) async {
      final audio = FakeAudioOutput()..failAll = true;
      await open(
        tester,
        overrides: [audioOutputProvider.overrideWithValue(audio)],
      );
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-preview');
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('onboarding-preview')), findsOneWidget);
    });

    testWidgets('while playing a Stop button replaces the preview', (
      tester,
    ) async {
      final fake = FakePlayback(const AzanPlaybackState(playing: true));
      await open(
        tester,
        overrides: [azanPlaybackProvider.overrideWith(() => fake)],
      );
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-next');
      expect(find.byKey(const Key('onboarding-preview')), findsNothing);
      await tapKey(tester, 'onboarding-stop');
      expect(fake.stops, 1);
      expect(find.byKey(const Key('onboarding-preview')), findsOneWidget);
    });

    testWidgets('the start-with-Windows switch writes its setting', (
      tester,
    ) async {
      final harness = await open(tester);
      await tapKey(tester, 'onboarding-next');
      await tapKey(tester, 'onboarding-next');
      expect(harness.current.window.launchAtStartup, isFalse);
      await tapKey(tester, 'onboarding-startup');
      expect(harness.current.window.launchAtStartup, isTrue);
      await tapKey(tester, 'onboarding-startup');
      expect(harness.current.window.launchAtStartup, isFalse);
    });
  });

  group('layout', () {
    for (final locale in ['fa', 'en']) {
      for (final dark in [false, true]) {
        for (final size in [const Size(1200, 800), const Size(800, 560)]) {
          for (final scale in [1.0, 2.0]) {
            testWidgets('$locale ${dark ? 'dark' : 'light'} '
                '${size.width.toInt()}x${size.height.toInt()} x$scale '
                'has no overflow on every step', (tester) async {
              await open(
                tester,
                settings: locale == 'fa' ? persianSettings : englishSettings,
                size: size,
                textScale: scale,
                brightness: dark ? Brightness.dark : Brightness.light,
              );
              for (var step = 0; step < 3; step++) {
                final ex = tester.takeException();
                expect(ex, isNull, reason: 'step ${step + 1}: $ex');
                expect(
                  find.byKey(const Key('onboarding-card')),
                  findsOneWidget,
                );
                if (step < 2) await tapKey(tester, 'onboarding-next');
              }
              final ex = tester.takeException();
              expect(ex, isNull, reason: '$ex');
            });
          }
        }
      }
    }
  });
}
