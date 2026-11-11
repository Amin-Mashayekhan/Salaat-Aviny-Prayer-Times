import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_view.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/viewed_date_provider.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

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
  }) async {
    final harness = await AppHarness.pump(
      tester,
      repository: repo,
      now: _now,
      settings: settings,
      size: size,
      textScale: textScale,
      brightness: brightness,
    );
    harness.container
        .read(destinationProvider.notifier)
        .select(Destination.calendar);
    await tester.pumpAndSettle();
    return harness;
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  String field(WidgetTester tester, String key) =>
      tester.widget<TextField>(find.byKey(Key(key))).controller!.text;

  Future<void> type(WidgetTester tester, String key, String value) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.enterText(find.byKey(Key(key)), value);
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  group('month grid', () {
    testWidgets('opens on the current Shamsi month with three day numbers', (
      tester,
    ) async {
      await open(tester);
      expect(text(tester, 'cal-title'), 'آبان ۱۴۰۵');
      // The Shamsi month straddles two lunar and two Gregorian months.
      expect(
        text(tester, 'cal-span'),
        'جمادی‌الاول – جمادی‌الثانی ۱۴۴۸ · اکتبر – نوامبر ۲۰۲۶',
      );
      for (var d = 23; d <= 31; d++) {
        expect(find.byKey(Key('cal-cell-2026-10-$d')), findsOneWidget);
      }
      expect(find.byKey(const Key('cal-cell-2026-11-21')), findsOneWidget);
      expect(find.byKey(const Key('cal-cell-2026-11-22')), findsNothing);
      expect(find.byKey(const Key('cal-cell-2026-10-22')), findsNothing);
      // 20 Aban 1405 = 1 Jumada al-Thani 1448 = 11 November 2026.
      expect(text(tester, 'cal-day-2026-11-11'), '۲۰');
      expect(text(tester, 'cal-hijri-2026-11-11'), '۱');
      expect(text(tester, 'cal-greg-2026-11-11'), '۱۱');
      expect(text(tester, 'cal-day-2026-10-23'), '۱');
      expect(text(tester, 'cal-greg-2026-10-23'), '۲۳');
    });

    testWidgets('the week starts on Saturday', (tester) async {
      final harness = await open(tester);
      final month = harness.container.read(calendarMonthProvider)!;
      // 23 October 2026 is a Friday: six empty cells before it.
      expect(month.leadingBlanks, 6);
      expect(month.days, hasLength(30));
      // Persian weekday heads, Saturday first.
      final heads = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
      for (final head in heads) {
        expect(find.text(head), findsOneWidget, reason: head);
      }
      final saturday = tester.getCenter(find.text('ش'));
      final friday = tester.getCenter(find.text('ج'));
      // Right to left: Saturday is the rightmost column.
      expect(saturday.dx, greaterThan(friday.dx));
    });

    testWidgets('today is outlined, a click selects a day', (tester) async {
      final harness = await open(tester);
      expect(
        harness.container.read(calendarViewProvider).selected,
        CivilDate(2026, 11, 11),
      );
      await tester.ensureVisible(find.byKey(const Key('cal-cell-2026-11-15')));
      await tester.tap(find.byKey(const Key('cal-cell-2026-11-15')));
      await tester.pumpAndSettle();
      expect(
        harness.container.read(calendarViewProvider).selected,
        CivilDate(2026, 11, 15),
      );
      expect(text(tester, 'cal-panel-weekday'), 'یکشنبه');
      expect(text(tester, 'cal-panel-jalali'), '۲۴ آبان ۱۴۰۵');
      expect(text(tester, 'cal-panel-gregorian'), '۱۵ نوامبر ۲۰۲۶');
      // 5 Jumada al-Thani 1448.
      expect(text(tester, 'cal-panel-hijri'), '۵ جمادی‌الثانی ۱۴۴۸');
    });

    testWidgets('month navigation, across the year, and back to today', (
      tester,
    ) async {
      await open(tester);
      await tapKey(tester, 'cal-next');
      expect(text(tester, 'cal-title'), 'آذر ۱۴۰۵');
      expect(find.byKey(const Key('cal-cell-2026-11-22')), findsOneWidget);
      for (var i = 0; i < 9; i++) {
        await tapKey(tester, 'cal-previous');
      }
      expect(text(tester, 'cal-title'), 'اسفند ۱۴۰۴');
      // 1404 is a common year: 29 days, ending on 20 March 2026.
      expect(find.byKey(const Key('cal-cell-2026-03-20')), findsOneWidget);
      expect(find.byKey(const Key('cal-cell-2026-03-21')), findsNothing);
      await tapKey(tester, 'cal-today');
      expect(text(tester, 'cal-title'), 'آبان ۱۴۰۵');
      expect(text(tester, 'cal-panel-jalali'), '۲۰ آبان ۱۴۰۵');
    });
  });

  group('side panel', () {
    testWidgets('shows the three dates, the weekday and that day times', (
      tester,
    ) async {
      final harness = await open(tester);
      expect(text(tester, 'cal-panel-weekday'), 'چهارشنبه');
      expect(text(tester, 'cal-panel-jalali'), '۲۰ آبان ۱۴۰۵');
      expect(text(tester, 'cal-panel-hijri'), '۱ جمادی‌الثانی ۱۴۴۸');
      expect(text(tester, 'cal-panel-gregorian'), '۱۱ نوامبر ۲۰۲۶');
      // The times are those of the home screen and timetable.
      expect(text(tester, 'cal-time-sunrise'), '۰۶:۳۶');
      expect(text(tester, 'cal-time-maghrib'), '۱۷:۲۰');
      expect(text(tester, 'cal-time-midnight'), '۲۳:۰۶');

      await tapKey(tester, 'cal-cell-2026-11-20');
      final fmt = harness.container.read(formatterProvider);
      final day = harness.container.read(
        prayerDayProvider(CivilDate(2026, 11, 20)),
      );
      expect(
        text(tester, 'cal-time-fajr'),
        fmt.formatTime(day.times[Prayer.fajr]!),
      );
      expect(text(tester, 'cal-panel-weekday'), 'جمعه');
    });

    testWidgets('the button opens that day on Home', (tester) async {
      final harness = await open(tester);
      await tapKey(tester, 'cal-cell-2026-11-15');
      await tapKey(tester, 'cal-open-home');
      expect(harness.container.read(destinationProvider), Destination.home);
      expect(
        harness.container.read(viewedDateProvider),
        CivilDate(2026, 11, 15),
      );
      expect(find.byKey(const Key('hero-viewing')), findsOneWidget);
      expect(text(tester, 'date-primary'), 'یکشنبه ۲۴ آبان ۱۴۰۵');
    });

    testWidgets('today on the button gives the live Home', (tester) async {
      final harness = await open(tester);
      await tapKey(tester, 'cal-open-home');
      expect(harness.container.read(destinationProvider), Destination.home);
      expect(harness.container.read(viewedDateProvider), isNull);
      expect(find.byKey(const Key('hero-countdown')), findsOneWidget);
    });
  });

  group('lunar adjustment', () {
    testWidgets('the stepper writes the setting and moves the lunar days', (
      tester,
    ) async {
      final harness = await open(tester);
      expect(harness.current.hijriAdjustmentDays, 0);
      // While the adjustment is 0 the date carries the "approximate" hint,
      // and the moon-sighting note is always there.
      expect(find.byKey(const Key('cal-panel-approx')), findsOneWidget);
      expect(find.byKey(const Key('cal-moon-note')), findsOneWidget);

      await tapKey(tester, 'cal-adjust-later');
      expect(harness.current.hijriAdjustmentDays, 1);
      expect(text(tester, 'cal-adjust-value'), contains('+۱'));
      // The same Gregorian day is now one lunar day later.
      expect(text(tester, 'cal-hijri-2026-11-11'), '۲');
      expect(text(tester, 'cal-panel-hijri'), '۲ جمادی‌الثانی ۱۴۴۸');
      expect(find.byKey(const Key('cal-panel-approx')), findsNothing);

      await tapKey(tester, 'cal-adjust-later');
      expect(harness.current.hijriAdjustmentDays, 2);
      // The upper end of the range.
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('cal-adjust-later')))
            .onPressed,
        isNull,
      );
      for (var i = 0; i < 4; i++) {
        await tapKey(tester, 'cal-adjust-earlier');
      }
      expect(harness.current.hijriAdjustmentDays, -2);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('cal-adjust-earlier')))
            .onPressed,
        isNull,
      );
      expect(text(tester, 'cal-adjust-value'), contains('−۲'));
      expect(text(tester, 'cal-hijri-2026-11-11'), '۲۹');
    });
  });

  group('date converter', () {
    testWidgets('starts with the selected day in all three calendars', (
      tester,
    ) async {
      await open(tester);
      expect(field(tester, 'conv-jalali-y'), '۱۴۰۵');
      expect(field(tester, 'conv-jalali-m'), '۸');
      expect(field(tester, 'conv-jalali-d'), '۲۰');
      expect(field(tester, 'conv-hijri-y'), '۱۴۴۸');
      expect(field(tester, 'conv-hijri-m'), '۶');
      expect(field(tester, 'conv-hijri-d'), '۱');
      expect(field(tester, 'conv-gregorian-y'), '۲۰۲۶');
      expect(field(tester, 'conv-gregorian-m'), '۱۱');
      expect(field(tester, 'conv-gregorian-d'), '۱۱');
    });

    testWidgets('selecting a grid day fills the fields', (tester) async {
      await open(tester);
      await tapKey(tester, 'cal-cell-2026-11-15');
      expect(field(tester, 'conv-jalali-d'), '۲۴');
      expect(field(tester, 'conv-hijri-d'), '۵');
      expect(field(tester, 'conv-gregorian-d'), '۱۵');
    });

    testWidgets('editing the Shamsi date updates the other two', (
      tester,
    ) async {
      await open(tester);
      // 30 Esfand 1403 (a leap year) = 20 March 2025.
      await type(tester, 'conv-jalali-y', '1403');
      await type(tester, 'conv-jalali-m', '12');
      await type(tester, 'conv-jalali-d', '30');
      expect(field(tester, 'conv-gregorian-y'), '۲۰۲۵');
      expect(field(tester, 'conv-gregorian-m'), '۳');
      expect(field(tester, 'conv-gregorian-d'), '۲۰');
      expect(find.byKey(const Key('conv-error-jalali')), findsNothing);
      expect(text(tester, 'conv-weekday'), 'پنجشنبه');
    });

    testWidgets('editing the Gregorian date, with Persian digits', (
      tester,
    ) async {
      await open(tester);
      await type(tester, 'conv-gregorian-y', '۲۰۲۶');
      await type(tester, 'conv-gregorian-m', '۳');
      await type(tester, 'conv-gregorian-d', '۲۱');
      expect(field(tester, 'conv-jalali-y'), '۱۴۰۵');
      expect(field(tester, 'conv-jalali-m'), '۱');
      expect(field(tester, 'conv-jalali-d'), '۱');
      expect(text(tester, 'conv-weekday'), 'شنبه');
    });

    testWidgets('editing the lunar date', (tester) async {
      await open(tester);
      await type(tester, 'conv-hijri-d', '10');
      expect(field(tester, 'conv-gregorian-d'), '۲۰');
      expect(field(tester, 'conv-jalali-d'), '۲۹');
    });

    testWidgets('an impossible date is explained and changes nothing', (
      tester,
    ) async {
      await open(tester);
      // 30 Esfand 1404 does not exist (common year).
      await type(tester, 'conv-jalali-y', '1404');
      await type(tester, 'conv-jalali-m', '12');
      await type(tester, 'conv-jalali-d', '30');
      expect(text(tester, 'conv-error-jalali'), 'روز باید از ۱ تا ۲۹ باشد.');
      // The other calendars still show the last valid day, 20 Esfand 1404
      // (11 March 2026).
      expect(field(tester, 'conv-gregorian-y'), '۲۰۲۶');
      expect(field(tester, 'conv-gregorian-m'), '۳');
      expect(field(tester, 'conv-gregorian-d'), '۱۱');
      expect(find.byKey(const Key('conv-weekday')), findsNothing);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('conv-show')))
            .onPressed,
        isNull,
      );

      await type(tester, 'conv-jalali-m', '13');
      expect(
        text(tester, 'conv-error-jalali'),
        'ماه باید از یک تا دوازده باشد.',
      );
      await type(tester, 'conv-jalali-m', '');
      expect(text(tester, 'conv-error-jalali'), 'سال، ماه و روز را کامل کنید.');
      await type(tester, 'conv-gregorian-y', '12000');
      // The year field holds four digits at most.
      expect(field(tester, 'conv-gregorian-y').length, lessThanOrEqualTo(4));
      await type(tester, 'conv-gregorian-y', '1200');
      expect(
        text(tester, 'conv-error-gregorian'),
        'این تاریخ بیرون از بازه‌ی پشتیبانی‌شده‌ی تقویم است.',
      );

      // Fixing the date clears the message.
      await type(tester, 'conv-jalali-m', '1');
      expect(find.byKey(const Key('conv-error-jalali')), findsNothing);
    });

    testWidgets('"show in calendar" picks the day in the grid', (tester) async {
      final harness = await open(tester);
      await type(tester, 'conv-hijri-y', '1448');
      await type(tester, 'conv-hijri-m', '9');
      await type(tester, 'conv-hijri-d', '1');
      await tapKey(tester, 'conv-show');
      // 1 Ramadan 1448 in the Umm al-Qura table: February 2027.
      final selected = harness.container.read(calendarViewProvider).selected;
      expect(selected.year, 2027);
      expect(selected.month, 2);
      expect(text(tester, 'cal-title'), contains('۱۴۰۵'));
      expect(text(tester, 'cal-panel-hijri'), '۱ رمضان ۱۴۴۸');
      expect(field(tester, 'conv-hijri-m'), '۹');
      expect(field(tester, 'conv-hijri-d'), '۱');
    });

    testWidgets('the adjustment re-derives what was typed', (tester) async {
      await open(tester);
      await type(tester, 'conv-gregorian-d', '12');
      expect(field(tester, 'conv-hijri-d'), '۲');
      await tapKey(tester, 'cal-adjust-later');
      expect(field(tester, 'conv-hijri-d'), '۳');
      expect(field(tester, 'conv-gregorian-d'), '۱۲');
    });
  });

  group('English', () {
    testWidgets('labels, digits and errors', (tester) async {
      await open(tester, settings: englishSettings);
      expect(text(tester, 'cal-title'), 'Aban 1405');
      expect(
        text(tester, 'cal-span'),
        'Jumada al-Awwal – Jumada al-Thani 1448 · October – November 2026',
      );
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Date converter'), findsOneWidget);
      expect(text(tester, 'cal-panel-weekday'), 'Wednesday');
      expect(text(tester, 'cal-panel-jalali'), '20 Aban 1405');
      expect(text(tester, 'cal-panel-hijri'), '1 Jumada al-Thani 1448');
      expect(text(tester, 'cal-panel-gregorian'), '11 November 2026');
      expect(text(tester, 'cal-time-maghrib'), '17:20');
      expect(field(tester, 'conv-jalali-y'), '1405');
      await type(tester, 'conv-jalali-y', '1404');
      await type(tester, 'conv-jalali-m', '12');
      await type(tester, 'conv-jalali-d', '30');
      expect(
        text(tester, 'conv-error-jalali'),
        'The day must be from 1 to 29.',
      );
      expect(find.text('Show on the home screen'), findsOneWidget);
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
              await open(
                tester,
                settings: locale == 'fa' ? persianSettings : englishSettings,
                size: size,
                textScale: scale,
                brightness: dark ? Brightness.dark : Brightness.light,
              );
              expect(tester.takeException(), isNull);
              expect(find.byKey(const Key('cal-title')), findsOneWidget);
              await tapKey(tester, 'cal-next');
              await tapKey(tester, 'cal-cell-2026-12-05');
              await tapKey(tester, 'cal-adjust-later');
              // An error message must fit too.
              await type(tester, 'conv-jalali-m', '13');
              await type(tester, 'conv-jalali-m', '');
              expect(tester.takeException(), isNull);
              expect(
                find.byKey(const Key('conv-error-jalali')),
                findsOneWidget,
              );
            });
          }
        }
      }
    }
  });
}
