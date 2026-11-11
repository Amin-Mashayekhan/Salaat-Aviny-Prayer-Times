import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/timetable_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/viewed_date_provider.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/app_harness.dart';
import '../../support/test_data.dart';

// 20 Aban 1405, 15:30 in Tehran.
final _now = DateTime.utc(2026, 11, 11, 12);

List<Override> _unitOverrides(LocationRepository repo) => [
  locationRepositoryProvider.overrideWithValue(repo),
  nowProvider.overrideWithValue(_now),
];

class _Fixed extends TimetableController {
  @override
  TimetableSelection build() =>
      const TimetableSelection(CalendarKind.hijri, 1600, 1);
}

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
  }) async {
    final harness = await AppHarness.pump(
      tester,
      repository: repo,
      now: _now,
      settings: settings,
      size: size,
      textScale: textScale,
      brightness: brightness,
      overrides: overrides,
    );
    harness.container
        .read(destinationProvider.notifier)
        .select(Destination.timetable);
    await tester.pumpAndSettle();
    return harness;
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Color? rowColor(WidgetTester tester, String iso) {
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byKey(Key('tt-row-$iso')),
        matching: find.byType(Container),
      ),
    );
    return (container.decoration! as BoxDecoration).color;
  }

  group('month table', () {
    testWidgets('opens on the current Shamsi month', (tester) async {
      await open(tester);
      expect(text(tester, 'tt-title'), 'آبان ۱۴۰۵');
      // 30 days of Aban.
      for (var d = 23; d <= 31; d++) {
        expect(
          find.byKey(Key('tt-row-2026-10-$d')),
          findsOneWidget,
          reason: '2026-10-$d',
        );
      }
      expect(find.byKey(const Key('tt-row-2026-11-21')), findsOneWidget);
      expect(find.byKey(const Key('tt-row-2026-11-22')), findsNothing);
      expect(find.byKey(const Key('tt-row-2026-10-22')), findsNothing);
    });

    testWidgets('shows the day, weekday and the enabled time columns', (
      tester,
    ) async {
      final harness = await open(tester);
      expect(text(tester, 'tt-day-2026-11-11'), contains('۲۰'));
      expect(text(tester, 'tt-2026-11-11-sunrise'), '۰۶:۳۶');
      expect(text(tester, 'tt-2026-11-11-maghrib'), '۱۷:۲۰');
      expect(text(tester, 'tt-2026-11-11-midnight'), '۲۳:۰۶');
      expect(find.byKey(const Key('tt-2026-11-11-imsak')), findsNothing);
      expect(find.text('چهارشنبه'), findsWidgets);

      harness.settings.setDisplay(
        const DisplaySettings(
          showImsak: true,
          showAsr: false,
          showIsha: false,
          showSunset: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(text(tester, 'tt-2026-11-11-imsak'), '۰۵:۰۰');
      expect(find.byKey(const Key('tt-2026-11-11-asr')), findsNothing);
      expect(find.byKey(const Key('tt-2026-11-11-isha')), findsNothing);
      expect(find.byKey(const Key('tt-2026-11-11-sunset')), findsNothing);
      expect(find.text('امساک'), findsOneWidget);
    });

    testWidgets('today is highlighted and marked, Fridays are tinted', (
      tester,
    ) async {
      await open(tester);
      // Today: marker in the day cell, accent tint.
      expect(text(tester, 'tt-day-2026-11-11'), startsWith('▶'));
      expect(text(tester, 'tt-day-2026-11-12'), isNot(startsWith('▶')));
      final today = rowColor(tester, '2026-11-11');
      final friday = rowColor(tester, '2026-11-13'); // a Friday
      final plain = rowColor(tester, '2026-11-12');
      expect(today, isNotNull);
      expect(friday, isNotNull);
      expect(plain, isNull);
      expect(today, isNot(friday));
      expect(rowColor(tester, '2026-11-20'), friday);
      expect(rowColor(tester, '2026-11-14'), isNull);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('tt-day-2026-11-11')))
            .style!
            .fontWeight,
        FontWeight.w700,
      );
    });

    testWidgets('the header stays while the days scroll', (tester) async {
      await open(tester, size: const Size(800, 560));
      final before = tester.getTopLeft(find.byKey(const Key('tt-header')));
      final rowBefore = tester.getTopLeft(
        find.byKey(const Key('tt-row-2026-10-23')),
      );
      await tester.drag(
        find.byKey(const Key('tt-row-2026-11-01')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byKey(const Key('tt-header'))), before);
      expect(
        tester.getTopLeft(find.byKey(const Key('tt-row-2026-10-23'))).dy,
        lessThan(rowBefore.dy),
      );
    });

    testWidgets('the Hijri month follows the adjustment', (tester) async {
      await open(
        tester,
        settings: const AppSettings.defaults().copyWith(hijriAdjustmentDays: 1),
      );
      await tester.tap(find.byKey(const Key('tt-kind-hijri')));
      await tester.pumpAndSettle();
      // With +1 day, 1 Jumada al-Thani 1448 starts on 10 November.
      expect(text(tester, 'tt-title'), 'جمادی‌الثانی ۱۴۴۸');
      expect(find.byKey(const Key('tt-row-2026-11-10')), findsOneWidget);
      expect(find.byKey(const Key('tt-row-2026-11-09')), findsNothing);
      expect(text(tester, 'tt-day-2026-11-10'), '۱');
    });
  });

  group('navigation', () {
    testWidgets('previous and next month, across the year', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const Key('tt-next')));
      await tester.pumpAndSettle();
      expect(text(tester, 'tt-title'), 'آذر ۱۴۰۵');
      expect(find.byKey(const Key('tt-row-2026-11-22')), findsOneWidget);
      for (var i = 0; i < 9; i++) {
        await tester.tap(find.byKey(const Key('tt-previous')));
        await tester.pumpAndSettle();
      }
      expect(text(tester, 'tt-title'), 'اسفند ۱۴۰۴');
      // 1404 is a common year: 29 days ending on 20 March 2026.
      expect(find.byKey(const Key('tt-row-2026-03-20')), findsOneWidget);
      expect(find.byKey(const Key('tt-row-2026-03-21')), findsNothing);
      expect(find.byKey(const Key('tt-row-2026-02-20')), findsOneWidget);
      expect(find.byKey(const Key('tt-row-2026-02-19')), findsNothing);
    });

    testWidgets('switching the calendar keeps today in view', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const Key('tt-kind-gregorian')));
      await tester.pumpAndSettle();
      expect(text(tester, 'tt-title'), 'نوامبر ۲۰۲۶');
      expect(text(tester, 'tt-day-2026-11-11'), '▶ ۱۱');
      expect(find.byKey(const Key('tt-row-2026-11-30')), findsOneWidget);
      expect(find.byKey(const Key('tt-row-2026-12-01')), findsNothing);

      await tester.tap(find.byKey(const Key('tt-kind-hijri')));
      await tester.pumpAndSettle();
      expect(text(tester, 'tt-title'), 'جمادی‌الثانی ۱۴۴۸');
      expect(text(tester, 'tt-day-2026-11-11'), '▶ ۱');

      await tester.tap(find.byKey(const Key('tt-kind-jalali')));
      await tester.pumpAndSettle();
      expect(text(tester, 'tt-title'), 'آبان ۱۴۰۵');
    });

    testWidgets('a month outside the Hijri table explains itself', (
      tester,
    ) async {
      await open(
        tester,
        overrides: [timetableSelectionProvider.overrideWith(_Fixed.new)],
      );
      expect(find.text('این ماه در جدول تقویم قمری نیست.'), findsOneWidget);
      expect(
        tester.widget<IconButton>(find.byKey(const Key('tt-next'))).onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('tt-previous')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('a click on a day opens it on Home', (tester) async {
      final harness = await open(tester);
      await tester.ensureVisible(find.byKey(const Key('tt-row-2026-11-15')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tt-row-2026-11-15')));
      await tester.pumpAndSettle();
      expect(harness.container.read(destinationProvider), Destination.home);
      expect(
        harness.container.read(viewedDateProvider),
        CivilDate(2026, 11, 15),
      );
      expect(find.byKey(const Key('hero-viewing')), findsOneWidget);
      expect(text(tester, 'date-primary'), 'یکشنبه ۲۴ آبان ۱۴۰۵');
    });

    testWidgets('a click on today opens Home with the countdown', (
      tester,
    ) async {
      final harness = await open(tester);
      await tester.ensureVisible(find.byKey(const Key('tt-row-2026-11-11')));
      await tester.tap(find.byKey(const Key('tt-row-2026-11-11')));
      await tester.pumpAndSettle();
      expect(harness.container.read(viewedDateProvider), isNull);
      expect(find.byKey(const Key('hero-countdown')), findsOneWidget);
    });
  });

  group('English', () {
    testWidgets('labels and month title', (tester) async {
      await open(tester, settings: englishSettings);
      expect(text(tester, 'tt-title'), 'Aban 1405');
      expect(find.text('Weekday'), findsOneWidget);
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Sunrise'), findsOneWidget);
      expect(text(tester, 'tt-2026-11-11-sunrise'), '06:36');
      await tester.tap(find.byKey(const Key('tt-kind-gregorian')));
      await tester.pumpAndSettle();
      expect(text(tester, 'tt-title'), 'November 2026');
    });
  });

  group('cache', () {
    test('a month is computed once per selection', () async {
      final container = ProviderContainer(overrides: [..._unitOverrides(repo)]);
      addTearDown(container.dispose);
      const selection = TimetableSelection(CalendarKind.jalali, 1405, 8);
      final first = container.read(timetableMonthProvider(selection));
      final second = container.read(timetableMonthProvider(selection));
      expect(first, isNotNull);
      expect(identical(first, second), isTrue);
      expect(first!.length, 30);
      expect(first.first.date, CivilDate(2026, 10, 23));
      expect(first.first.dayOfMonth, 1);
      expect(first.last.dayOfMonth, 30);
      expect(
        container.read(
          timetableMonthProvider(
            const TimetableSelection(CalendarKind.hijri, 1600, 1),
          ),
        ),
        isNull,
      );
    });

    test('selection arithmetic wraps the year', () {
      const s = TimetableSelection(CalendarKind.jalali, 1405, 1);
      expect(
        s.shifted(-1),
        const TimetableSelection(CalendarKind.jalali, 1404, 12),
      );
      expect(
        s.shifted(12),
        const TimetableSelection(CalendarKind.jalali, 1406, 1),
      );
      expect(s.shifted(0), s);
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
              final harness = await open(
                tester,
                settings: (locale == 'fa' ? persianSettings : englishSettings)
                    .copyWith(display: const DisplaySettings(showImsak: true)),
                size: size,
                textScale: scale,
                brightness: dark ? Brightness.dark : Brightness.light,
              );
              expect(tester.takeException(), isNull);
              expect(
                find.byKey(const Key('tt-row-2026-11-11')),
                findsOneWidget,
              );
              expect(find.byKey(const Key('tt-header')), findsOneWidget);
              for (final kind in ['gregorian', 'hijri']) {
                await tester.tap(find.byKey(Key('tt-kind-$kind')));
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              }
              expect(harness.current.display.showImsak, isTrue);
            });
          }
        }
      }
    }
  });
}
