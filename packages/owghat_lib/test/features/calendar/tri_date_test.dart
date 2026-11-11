import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:prayer_core/prayer_core.dart';

void main() {
  TriDate g(int y, int m, int d, {int adj = 0}) =>
      TriDate.fromGregorian(CivilDate(y, m, d), hijriAdjustment: adj);

  group('required facts', () {
    test('21 March 2025 is 1 Farvardin 1404, a Friday', () {
      final t = g(2025, 3, 21);
      expect(t.jalali, const CalendarDate(1404, 1, 1));
      expect(t.weekday, DateTime.friday);
      expect(t.isFriday, isTrue);
      expect(t.jalaliWeekdayIndex, 6);
    });

    test('21 March 2026 is 1 Farvardin 1405, a Saturday', () {
      final t = g(2026, 3, 21);
      expect(t.jalali, const CalendarDate(1405, 1, 1));
      expect(t.weekday, DateTime.saturday);
      expect(t.jalaliWeekdayIndex, 0);
    });

    test('20 March 2025 is 30 Esfand 1403 and 1403 is a leap year', () {
      expect(g(2025, 3, 20).jalali, const CalendarDate(1403, 12, 30));
      expect(TriDate.isJalaliLeapYear(1403), isTrue);
      expect(TriDate.isJalaliLeapYear(1404), isFalse);
      expect(TriDate.jalaliMonthLength(1403, 12), 30);
      expect(TriDate.jalaliMonthLength(1404, 12), 29);
      expect(TriDate.tryFromJalali(1403, 12, 30), isNotNull);
      expect(TriDate.tryFromJalali(1404, 12, 30), isNull);
    });

    test(
      '11 November 2026 is 20 Aban 1405, Wednesday, 1 Jumada al-Thani 1448',
      () {
        final t = g(2026, 11, 11);
        expect(t.jalali, const CalendarDate(1405, 8, 20));
        expect(t.weekday, DateTime.wednesday);
        expect(t.hijri, const CalendarDate(1448, 6, 1));
        expect(t.hijriAdjustment, 0);
      },
    );
  });

  group('Jalali month lengths', () {
    test('31 for the first six months, 30 for the next five', () {
      expect(
        [for (var m = 1; m <= 12; m++) TriDate.jalaliMonthLength(1405, m)],
        [
          31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29, //
        ],
      );
    });

    test('a month has exactly its days between its first and next first', () {
      final days = monthDays(CalendarKind.jalali, 1405, 8)!;
      expect(days.length, 30);
      expect(days.first, CivilDate(2026, 10, 23));
      expect(days.last, CivilDate(2026, 11, 21));
    });
  });

  group('Hijri adjustment', () {
    test('shifts the Hijri date by the adjustment and nothing else', () {
      expect(g(2026, 11, 11, adj: 1).hijri, const CalendarDate(1448, 6, 2));
      expect(g(2026, 11, 11, adj: -1).hijri, const CalendarDate(1448, 5, 30));
      expect(g(2026, 11, 11, adj: 2).hijri, const CalendarDate(1448, 6, 3));
      expect(g(2026, 11, 11, adj: -2).hijri, const CalendarDate(1448, 5, 29));
      expect(g(2026, 11, 11, adj: 2).jalali, const CalendarDate(1405, 8, 20));
    });

    test('converting from Hijri removes the adjustment again', () {
      for (final adj in [-2, -1, 0, 1, 2]) {
        final t = TriDate.tryFromHijri(1448, 6, 1, hijriAdjustment: adj)!;
        expect(t.hijri, const CalendarDate(1448, 6, 1), reason: 'adj $adj');
        expect(t.gregorian, CivilDate(2026, 11, 11).addDays(-adj));
      }
    });

    test('a month length comes from the table', () {
      final t = g(2026, 11, 11);
      expect(t.hijriMonthLength, anyOf(29, 30));
      expect(TriDate.hijriMonthLengthOf(1448, 6), t.hijriMonthLength);
    });
  });

  group('conversion in any direction', () {
    test('Jalali to Gregorian and Hijri', () {
      final t = TriDate.tryFromJalali(1405, 8, 20)!;
      expect(t.gregorian, CivilDate(2026, 11, 11));
      expect(t.hijri, const CalendarDate(1448, 6, 1));
    });

    test('Hijri to Gregorian and Jalali', () {
      final t = TriDate.tryFromHijri(1448, 6, 1)!;
      expect(t.gregorian, CivilDate(2026, 11, 11));
      expect(t.jalali, const CalendarDate(1405, 8, 20));
    });

    test('tryFrom dispatches on the calendar kind', () {
      expect(
        TriDate.tryFrom(CalendarKind.gregorian, 2026, 11, 11),
        g(2026, 11, 11),
      );
      expect(
        TriDate.tryFrom(CalendarKind.jalali, 1405, 8, 20),
        g(2026, 11, 11),
      );
      expect(TriDate.tryFrom(CalendarKind.hijri, 1448, 6, 1), g(2026, 11, 11));
    });

    test('round trip over four years in all three calendars', () {
      var day = CivilDate(2024, 1, 1);
      for (var i = 0; i < 1500; i++) {
        final t = g(day.year, day.month, day.day);
        expect(
          TriDate.tryFromJalali(
            t.jalali.year,
            t.jalali.month,
            t.jalali.day,
          )!.gregorian,
          day,
        );
        final h = t.hijri!;
        expect(TriDate.tryFromHijri(h.year, h.month, h.day)!.gregorian, day);
        day = day.addDays(1);
      }
    });

    test('impossible dates are null', () {
      expect(TriDate.tryFromGregorian(2026, 2, 30), isNull);
      expect(TriDate.tryFromJalali(1405, 13, 1), isNull);
      expect(TriDate.tryFromJalali(1405, 7, 31), isNull);
      expect(TriDate.tryFromHijri(1448, 13, 1), isNull);
      expect(TriDate.tryFromHijri(1448, 1, 31), isNull);
    });

    test('dates outside the Umm al-Qura table have no Hijri date', () {
      expect(g(1900, 1, 1).hijri, isNull);
      expect(g(2100, 1, 1).hijri, isNull);
      expect(g(2100, 1, 1).jalali.year, greaterThan(1400));
      expect(TriDate.tryFromHijri(1600, 1, 1), isNull);
      expect(monthDays(CalendarKind.hijri, 1600, 1), isNull);
    });
  });

  group('monthDays', () {
    test('Gregorian February respects leap years', () {
      expect(monthDays(CalendarKind.gregorian, 2028, 2)!.length, 29);
      expect(monthDays(CalendarKind.gregorian, 2026, 2)!.length, 28);
    });

    test('consecutive days of a Hijri month', () {
      final days = monthDays(CalendarKind.hijri, 1448, 6)!;
      expect(days.first, CivilDate(2026, 11, 11));
      expect(days.length, TriDate.hijriMonthLengthOf(1448, 6));
    });

    test('a wrong month is null', () {
      expect(monthDays(CalendarKind.jalali, 1405, 13), isNull);
    });
  });

  group('names and date header', () {
    CalendarNames names(String code) =>
        CalendarNames(lookupAppLocalizations(Locale(code)));
    Formatter formatter(String code, {required bool persian}) => Formatter(
      persianDigits: persian,
      twelveHour: false,
      l10n: lookupAppLocalizations(Locale(code)),
    );

    test('weekday names in both languages', () {
      final fa = names('fa');
      final en = names('en');
      expect(
        [for (var d = 1; d <= 7; d++) fa.weekday(d)],
        ['دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه', 'شنبه', 'یکشنبه'],
      );
      expect(en.weekday(1), 'Monday');
      expect(en.weekday(7), 'Sunday');
    });

    test('every month of every calendar has a name in both languages', () {
      for (final code in ['fa', 'en']) {
        final n = names(code);
        for (final kind in CalendarKind.values) {
          for (var m = 1; m <= 12; m++) {
            expect(n.month(kind, m), isNotEmpty, reason: '$code $kind $m');
          }
        }
      }
      expect(names('fa').jalaliMonth(8), 'آبان');
      expect(names('fa').hijriMonth(6), 'جمادی‌الثانی');
      expect(names('en').jalaliMonth(8), 'Aban');
      expect(names('en').hijriMonth(6), 'Jumada al-Thani');
      expect(names('en').gregorianMonth(11), 'November');
    });

    test('the Persian header of 11 November 2026', () {
      final header = buildDateHeader(
        date: g(2026, 11, 11),
        names: names('fa'),
        formatter: formatter('fa', persian: true),
      );
      expect(header.primary, 'چهارشنبه ۲۰ آبان ۱۴۰۵');
      expect(header.hijri, '۱ جمادی‌الثانی ۱۴۴۸');
      expect(header.gregorian, '۱۱ نوامبر ۲۰۲۶');
      expect(header.hijriApproximate, isTrue);
    });

    test('the English header with Latin digits', () {
      final header = buildDateHeader(
        date: g(2026, 11, 11, adj: 1),
        names: names('en'),
        formatter: formatter('en', persian: false),
      );
      expect(header.primary, 'Wednesday 20 Aban 1405');
      expect(header.secondary, '2 Jumada al-Thani 1448 · 11 November 2026');
      expect(header.hijriApproximate, isFalse);
    });
  });
}
