import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/core/time/clock_warning.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/clock/application/clock_warning_provider.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_view.dart';
import 'package:owghat_lib/src/features/prayer_times/application/viewed_date_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_reset_notice.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/app_harness.dart';
import '../../support/test_data.dart';

// 2026-11-11 in Tehran (UTC+03:30): asr 14:39, sunset 17:00, maghrib 17:20.
final _afternoon = DateTime.utc(2026, 11, 11, 12); // 15:30 local
final _lateNight = DateTime.utc(2026, 11, 11, 20); // 23:30 local

void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  Text textByKey(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key)));

  group('content in Persian', () {
    testWidgets('hero, header and list show the next prayer', (tester) async {
      await AppHarness.pump(tester, repository: repo, now: _afternoon);

      expect(textByKey(tester, 'hero-label').data, 'تا غروب آفتاب');
      // 17:00 local is 1 h 30 min away.
      expect(textByKey(tester, 'hero-countdown').data, '۰۱:۳۰:۰۰');
      expect(textByKey(tester, 'hero-event').data, contains('۱۷:۰۰'));
      expect(textByKey(tester, 'date-primary').data, 'چهارشنبه ۲۰ آبان ۱۴۰۵');
      expect(textByKey(tester, 'date-hijri').data, contains('جمادی‌الثانی'));
      expect(textByKey(tester, 'list-title').data, 'اوقات امروز');
      expect(textByKey(tester, 'home-location-name').data, 'تهران');
      expect(
        Directionality.of(tester.element(find.byKey(const Key('hero-card')))),
        TextDirection.rtl,
      );
    });

    testWidgets('the time inside the hero sentence is bidi isolated', (
      tester,
    ) async {
      await AppHarness.pump(tester, repository: repo, now: _afternoon);
      final text = textByKey(tester, 'hero-event').data!;
      expect(text, contains('${Formatter.lri}۱۷:۰۰${Formatter.pdi}'));
    });

    testWidgets('the next row is marked, passed rows are dimmed', (
      tester,
    ) async {
      await AppHarness.pump(tester, repository: repo, now: _afternoon);

      expect(find.byKey(const Key('next-marker-sunset')), findsOneWidget);
      expect(find.byKey(const Key('next-marker-maghrib')), findsNothing);
      expect(find.byKey(const Key('next-marker-asr')), findsNothing);
      expect(
        textByKey(tester, 'time-sunset').style!.fontWeight,
        FontWeight.w700,
      );
      expect(
        textByKey(tester, 'time-maghrib').style!.fontWeight,
        FontWeight.w400,
      );
      // Passed (asr) is dimmed compared with upcoming (maghrib).
      final passed = textByKey(tester, 'time-asr').style!.color!;
      final upcoming = textByKey(tester, 'time-maghrib').style!.color!;
      expect(passed.a, lessThan(upcoming.a));
      expect(textByKey(tester, 'time-sunset').data, '۱۷:۰۰');
      expect(textByKey(tester, 'time-maghrib').data, '۱۷:۲۰');
    });

    testWidgets('rows follow the display settings', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      expect(find.byKey(const Key('row-imsak')), findsNothing);
      expect(find.byKey(const Key('row-isha')), findsOneWidget);
      harness.settings.setDisplay(
        const DisplaySettings(
          showImsak: true,
          showAsr: false,
          showIsha: false,
          showSunset: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('row-imsak')), findsOneWidget);
      expect(find.byKey(const Key('row-asr')), findsNothing);
      expect(find.byKey(const Key('row-isha')), findsNothing);
      expect(find.byKey(const Key('row-sunset')), findsNothing);
      // Sunset is hidden, so the next event is Maghrib.
      expect(textByKey(tester, 'hero-label').data, 'تا اذان مغرب');
    });

    testWidgets('after the last event the list shows tomorrow', (tester) async {
      await AppHarness.pump(tester, repository: repo, now: _lateNight);
      expect(textByKey(tester, 'list-title').data, 'اوقات فردا');
      expect(textByKey(tester, 'hero-label').data, 'تا اذان صبح');
      expect(find.byKey(const Key('next-marker-fajr')), findsOneWidget);
      // Nothing of tomorrow has passed.
      expect(
        textByKey(tester, 'time-dhuhr').style!.color!.a,
        textByKey(tester, 'time-fajr').style!.color!.a,
      );
    });
  });

  group('content in English', () {
    testWidgets('labels, digits and list title', (tester) async {
      await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
        settings: englishSettings,
      );
      expect(textByKey(tester, 'hero-label').data, 'Until Sunset');
      expect(textByKey(tester, 'hero-countdown').data, '01:30:00');
      expect(textByKey(tester, 'hero-event').data, contains('17:00'));
      expect(textByKey(tester, 'list-title').data, "Today's times");
      expect(textByKey(tester, 'date-primary').data, 'Wednesday 20 Aban 1405');
      expect(textByKey(tester, 'home-location-name').data, 'Tehran');
      expect(
        Directionality.of(tester.element(find.byKey(const Key('hero-card')))),
        TextDirection.ltr,
      );
    });

    testWidgets('12-hour clock shows AM and PM', (tester) async {
      await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
        settings: englishSettings.copyWith(hourFormat: HourFormat.h12),
      );
      expect(textByKey(tester, 'time-sunset').data, '5:00 PM');
      expect(textByKey(tester, 'time-fajr').data, '5:10 AM');
    });
  });

  group('the countdown follows nowProvider only', () {
    testWidgets('text changes when the clock moves', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      expect(textByKey(tester, 'hero-countdown').data, '۰۱:۳۰:۰۰');
      await harness.setNow(tester, _afternoon.add(const Duration(seconds: 1)));
      expect(textByKey(tester, 'hero-countdown').data, '۰۱:۲۹:۵۹');
      await harness.setNow(tester, _afternoon.add(const Duration(minutes: 30)));
      expect(textByKey(tester, 'hero-countdown').data, '۰۱:۰۰:۰۰');
    });

    testWidgets('when the event passes the next one takes over', (
      tester,
    ) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: DateTime.utc(2026, 11, 11, 13, 29, 59), // 16:59:59 local
      );
      expect(textByKey(tester, 'hero-label').data, 'تا غروب آفتاب');
      expect(textByKey(tester, 'hero-countdown').data, '۰۰:۰۰:۰۱');
      await harness.setNow(tester, DateTime.utc(2026, 11, 11, 13, 30));
      expect(textByKey(tester, 'hero-label').data, 'تا اذان مغرب');
      expect(textByKey(tester, 'hero-countdown').data, '۰۰:۲۰:۰۰');
    });

    testWidgets('the hero sky changes with the period', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      List<Color> colorsOf() {
        final container = tester.widget<AnimatedContainer>(
          find.byKey(const Key('hero-card')),
        );
        final decoration = container.decoration! as BoxDecoration;
        return (decoration.gradient! as LinearGradient).colors;
      }

      final day = colorsOf();
      await harness.setNow(tester, _lateNight);
      await tester.pumpAndSettle();
      expect(colorsOf(), isNot(day));
    });
  });

  group('another day', () {
    testWidgets('arrows show that day without a countdown', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      expect(find.byKey(const Key('day-today-chip')), findsNothing);
      await tester.tap(find.byKey(const Key('day-next')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('hero-countdown')), findsNothing);
      expect(
        textByKey(tester, 'hero-viewing').data,
        'نمایش پنجشنبه ۲۱ آبان ۱۴۰۵',
      );
      expect(textByKey(tester, 'date-primary').data, 'پنجشنبه ۲۱ آبان ۱۴۰۵');
      expect(find.byKey(const Key('day-today-chip')), findsOneWidget);
      expect(find.byKey(const Key('next-marker-sunset')), findsNothing);
      expect(
        harness.container.read(viewedDateProvider),
        CivilDate(2026, 11, 12),
      );

      await tester.tap(find.byKey(const Key('day-previous')));
      await tester.pumpAndSettle();
      expect(harness.container.read(viewedDateProvider), isNull);

      await tester.tap(find.byKey(const Key('day-previous')));
      await tester.pumpAndSettle();
      expect(textByKey(tester, 'list-title').data, contains('۱۹ آبان'));
      await tester.tap(find.byKey(const Key('day-today-chip')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hero-countdown')), findsOneWidget);
      expect(find.byKey(const Key('day-today-chip')), findsNothing);
    });

    testWidgets('the timetable can open a day through viewedDateProvider', (
      tester,
    ) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      harness.container
          .read(viewedDateProvider.notifier)
          .show(CivilDate(2026, 12, 1));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hero-countdown')), findsNothing);
      expect(textByKey(tester, 'date-primary').data, contains('۱۰ آذر'));
    });
  });

  group('actions', () {
    testWidgets('the bell toggles the azan setting', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      expect(harness.current.azan.perPrayer[Prayer.asr]!.enabled, isFalse);
      await tester.tap(find.byKey(const Key('bell-asr')));
      await tester.pumpAndSettle();
      expect(harness.current.azan.perPrayer[Prayer.asr]!.enabled, isTrue);
      await tester.tap(find.byKey(const Key('bell-fajr')));
      await tester.pumpAndSettle();
      expect(harness.current.azan.perPrayer[Prayer.fajr]!.enabled, isFalse);
      // Rows without an azan have no bell.
      expect(find.byKey(const Key('bell-sunrise')), findsNothing);
      expect(find.byKey(const Key('bell-midnight')), findsNothing);
    });

    testWidgets('the location switcher changes the active location', (
      tester,
    ) async {
      final mashhad = repo.search('مشهد').first;
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
        settings: const AppSettings.defaults().copyWith(
          locations: [
            AppSettings.defaultLocation,
            SavedLocation.builtin(id: 'city:${mashhad.id}', cityId: mashhad.id),
          ],
        ),
      );
      await tester.tap(find.byKey(const Key('home-location-switcher')));
      await tester.pumpAndSettle();
      final item = find.widgetWithText(CheckedPopupMenuItem<String>, 'مشهد');
      expect(item, findsOneWidget);
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(harness.current.activeLocationId, 'city:${mashhad.id}');
      expect(textByKey(tester, 'home-location-name').data, 'مشهد');
    });

    testWidgets('mute menu sets, shows and cancels the mute', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      expect(find.byKey(const Key('banner-muted')), findsNothing);
      await tester.tap(find.byKey(const Key('mute-menu')));
      await tester.pumpAndSettle();
      // Cancel is offered only while muted.
      expect(find.text('لغو بی‌صدا'), findsNothing);
      await tester.tap(find.text('۱ ساعت'));
      await tester.pumpAndSettle();
      expect(
        harness.current.azan.mute.until,
        _afternoon.add(const Duration(hours: 1)),
      );
      expect(find.byKey(const Key('banner-muted')), findsOneWidget);
      // 16:30 local.
      expect(find.textContaining('۱۶:۳۰'), findsWidgets);

      await tester.tap(find.byKey(const Key('mute-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('لغو بی‌صدا'));
      await tester.pumpAndSettle();
      expect(harness.current.azan.mute, MuteSetting.none);
      expect(find.byKey(const Key('banner-muted')), findsNothing);
    });

    testWidgets('mute until the next azan ends at that azan', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      await tester.tap(find.byKey(const Key('mute-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تا اذان بعدی'));
      await tester.pumpAndSettle();
      // Asr is off by default, so the next azan is Maghrib at 17:20 local.
      expect(
        harness.current.azan.mute.until,
        DateTime.utc(2026, 11, 11, 13, 50),
      );
    });

    testWidgets('status lines open their screens', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
      );
      Destination current() => harness.container.read(destinationProvider);
      await tester.tap(find.byKey(const Key('status-qibla')));
      await tester.pumpAndSettle();
      expect(current(), Destination.qibla);
    });

    testWidgets('status card summarises azan, reminders, qibla, wake-up', (
      tester,
    ) async {
      await AppHarness.pump(tester, repository: repo, now: _afternoon);
      expect(find.text('اذان: روشن'), findsOneWidget);
      expect(find.text('یادآوری: ۱۰ دقیقه قبل'), findsOneWidget);
      // Tehran qibla is about 217 degrees, south-west.
      expect(find.textContaining('جنوب غربی'), findsOneWidget);
      expect(find.text('بیدارباش بعدی: —'), findsOneWidget);
    });
  });

  group('banners', () {
    testWidgets('one at a time by priority, each dismissible', (tester) async {
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
        overrides: [
          settingsWasResetProvider.overrideWithValue(true),
          clockWarningProvider.overrideWithValue(
            const ClockSkewWarning(Duration(minutes: 2)),
          ),
        ],
      );
      // Clock skew outranks the reset notice.
      expect(find.byKey(const Key('banner-skew')), findsOneWidget);
      expect(find.byKey(const Key('banner-settings-reset')), findsNothing);
      expect(find.textContaining('۲ دقیقه'), findsOneWidget);

      // A mute outranks both.
      harness.settings.setMute(const MuteSetting(indefinite: true));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('banner-muted')), findsOneWidget);
      expect(find.byKey(const Key('banner-skew')), findsNothing);

      await tester.tap(find.byKey(const Key('banner-dismiss')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('banner-skew')), findsOneWidget);
      await tester.tap(find.byKey(const Key('banner-dismiss')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('banner-settings-reset')), findsOneWidget);
      await tester.tap(find.byKey(const Key('banner-dismiss')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('banner-dismiss')), findsNothing);
    });

    testWidgets('stale Windows zone rules show their own banner', (
      tester,
    ) async {
      await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
        overrides: [
          clockWarningProvider.overrideWithValue(
            const StaleZoneRulesWarning(
              windowsOffset: Duration(hours: 4, minutes: 30),
              expectedOffset: Duration(hours: 3, minutes: 30),
            ),
          ),
        ],
      );
      expect(find.byKey(const Key('banner-stale-zone')), findsOneWidget);
    });
  });

  group('now playing', () {
    const playing = AzanPlaybackState(
      playing: true,
      prayer: Prayer.maghrib,
      position: Duration(seconds: 30),
      duration: Duration(minutes: 2),
    );

    testWidgets('bar shows the prayer and Stop stops', (tester) async {
      final fake = FakePlayback(playing);
      await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
        overrides: [azanPlaybackProvider.overrideWith(() => fake)],
      );
      expect(find.byKey(const Key('now-playing-bar')), findsOneWidget);
      expect(find.text('در حال پخش: اذان مغرب'), findsOneWidget);
      await tester.tap(find.byKey(const Key('now-playing-stop')));
      await tester.pumpAndSettle();
      expect(fake.stops, 1);
      expect(find.byKey(const Key('now-playing-bar')), findsNothing);
    });

    testWidgets('Esc stops the audio', (tester) async {
      final fake = FakePlayback(playing);
      await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
        overrides: [azanPlaybackProvider.overrideWith(() => fake)],
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(fake.stops, 1);
    });

    testWidgets('no bar while idle', (tester) async {
      await AppHarness.pump(tester, repository: repo, now: _afternoon);
      expect(find.byKey(const Key('now-playing-bar')), findsNothing);
    });
  });

  group('no times (polar)', () {
    testWidgets('rows show a dash and an info line explains', (tester) async {
      // Longyearbyen in the midnight sun: no sunrise, no sunset.
      const polar = SavedLocation.custom(
        id: 'custom:svalbard',
        name: 'Longyearbyen',
        latitude: 78.22,
        longitude: 15.65,
        zoneId: 'Europe/Berlin',
      );
      final harness = await AppHarness.pump(
        tester,
        repository: repo,
        now: DateTime.utc(2026, 6, 21, 10),
        settings: englishSettings.copyWith(
          locations: [polar],
          activeLocationId: polar.id,
        ),
      );
      final view = harness.container.read(homeViewProvider);
      expect(view.hasMissingTimes, isTrue, reason: 'test premise');
      expect(find.byKey(const Key('no-times-info')), findsOneWidget);
      final missing = view.rows.firstWhere((r) => r.time == null);
      expect(textByKey(tester, 'time-${missing.prayer.name}').data, '—');
      expect(tester.takeException(), isNull);
    });
  });

  group('layout', () {
    for (final locale in ['fa', 'en']) {
      for (final dark in [false, true]) {
        for (final size in [const Size(1200, 800), const Size(800, 560)]) {
          for (final scale in [1.0, 2.0]) {
            testWidgets('$locale ${dark ? 'dark' : 'light'} '
                '${size.width.toInt()}x${size.height.toInt()} x$scale '
                'has no overflow', (tester) async {
              await AppHarness.pump(
                tester,
                repository: repo,
                now: _afternoon,
                settings: locale == 'fa' ? persianSettings : englishSettings,
                size: size,
                textScale: scale,
                brightness: dark ? Brightness.dark : Brightness.light,
                overrides: [
                  settingsWasResetProvider.overrideWithValue(true),
                  azanPlaybackProvider.overrideWith(
                    () => FakePlayback(
                      const AzanPlaybackState(
                        playing: true,
                        prayer: Prayer.maghrib,
                        position: Duration(seconds: 3),
                        duration: Duration(seconds: 100),
                      ),
                    ),
                  ),
                ],
              );
              expect(tester.takeException(), isNull);
              expect(find.byKey(const Key('hero-countdown')), findsOneWidget);
              expect(find.byKey(const Key('row-midnight')), findsOneWidget);
            });
          }
        }
      }
    }

    testWidgets('timeline dots mirror in Persian', (tester) async {
      await AppHarness.pump(tester, repository: repo, now: _afternoon);
      final fajr = tester.getCenter(find.byKey(const Key('timeline-dot-fajr')));
      final midnight = tester.getCenter(
        find.byKey(const Key('timeline-dot-midnight')),
      );
      // Time runs from the start edge: right to left in Persian.
      expect(fajr.dx, greaterThan(midnight.dx));
      final now = tester.getCenter(find.byKey(const Key('timeline-now')));
      expect(now.dx, lessThan(fajr.dx));
      expect(now.dx, greaterThan(midnight.dx));
    });

    testWidgets('timeline dots run left to right in English', (tester) async {
      await AppHarness.pump(
        tester,
        repository: repo,
        now: _afternoon,
        settings: englishSettings,
      );
      final fajr = tester.getCenter(find.byKey(const Key('timeline-dot-fajr')));
      final midnight = tester.getCenter(
        find.byKey(const Key('timeline-dot-midnight')),
      );
      expect(fajr.dx, lessThan(midnight.dx));
    });
  });
}
