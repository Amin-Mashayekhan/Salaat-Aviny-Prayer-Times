import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/features/calendar/domain/date_converter.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:prayer_core/prayer_core.dart';

TriDate ok(ConvertResult result) {
  expect(result, isA<ConvertOk>(), reason: '$result');
  return (result as ConvertOk).date;
}

ConvertError error(ConvertResult result) {
  expect(result, isA<ConvertError>());
  return result as ConvertError;
}

void main() {
  group('convertDate', () {
    test('Shamsi to the other two', () {
      final date = ok(convertDate(CalendarKind.jalali, '1405', '8', '20'));
      expect(date.gregorian, CivilDate(2026, 11, 11));
      expect(date.hijri, const CalendarDate(1448, 6, 1));
    });

    test('Gregorian to the other two', () {
      final date = ok(convertDate(CalendarKind.gregorian, '2026', '3', '21'));
      expect(date.jalali, const CalendarDate(1405, 1, 1));
      expect(date.weekday, DateTime.saturday);
    });

    test('lunar to the other two', () {
      final date = ok(convertDate(CalendarKind.hijri, '1448', '6', '1'));
      expect(date.gregorian, CivilDate(2026, 11, 11));
      expect(date.jalali, const CalendarDate(1405, 8, 20));
    });

    test('the lunar adjustment shifts the lunar side both ways', () {
      final shifted = ok(
        convertDate(CalendarKind.hijri, '1448', '6', '1', hijriAdjustment: 1),
      );
      // With +1 day the lunar day 1 is one Gregorian day earlier.
      expect(shifted.gregorian, CivilDate(2026, 11, 10));
      expect(shifted.hijri, const CalendarDate(1448, 6, 1));
      final fromGregorian = ok(
        convertDate(
          CalendarKind.gregorian,
          '2026',
          '11',
          '11',
          hijriAdjustment: 1,
        ),
      );
      expect(fromGregorian.hijri, const CalendarDate(1448, 6, 2));
    });

    test('Persian and Arabic-Indic digits are accepted', () {
      final persian = ok(convertDate(CalendarKind.jalali, '۱۴۰۵', '۸', '۲۰'));
      final arabic = ok(convertDate(CalendarKind.jalali, '١٤٠٥', '٨', '٢٠'));
      expect(persian.gregorian, CivilDate(2026, 11, 11));
      expect(arabic.gregorian, CivilDate(2026, 11, 11));
      expect(normalizeDigits(' ۱۴۰۵ '), '1405');
    });

    test('Esfand 30 exists only in a leap year', () {
      final leap = ok(convertDate(CalendarKind.jalali, '1403', '12', '30'));
      expect(leap.gregorian, CivilDate(2025, 3, 20));
      final common = error(
        convertDate(CalendarKind.jalali, '1404', '12', '30'),
      );
      expect(common.problem, ConvertProblem.dayOutOfRange);
      expect(common.maxDay, 29);
    });

    test('Gregorian month lengths, including 29 February', () {
      expect(
        ok(convertDate(CalendarKind.gregorian, '2028', '2', '29')).jalali,
        const CalendarDate(1406, 12, 10),
      );
      final bad = error(convertDate(CalendarKind.gregorian, '2027', '2', '29'));
      expect(bad.problem, ConvertProblem.dayOutOfRange);
      expect(bad.maxDay, 28);
      expect(
        error(convertDate(CalendarKind.gregorian, '2026', '4', '31')).maxDay,
        30,
      );
    });

    test(
      'a lunar day beyond the month length is rejected, not rolled over',
      () {
        final short = [
          for (var m = 1; m <= 12; m++)
            if (TriDate.hijriMonthLengthOf(1448, m) == 29) m,
        ];
        expect(short, isNotEmpty);
        final result = error(
          convertDate(CalendarKind.hijri, '1448', '${short.first}', '30'),
        );
        expect(result.problem, ConvertProblem.dayOutOfRange);
        expect(result.maxDay, 29);
      },
    );

    test('month and day limits', () {
      expect(
        error(convertDate(CalendarKind.jalali, '1405', '13', '1')).problem,
        ConvertProblem.monthOutOfRange,
      );
      expect(
        error(convertDate(CalendarKind.jalali, '1405', '0', '1')).problem,
        ConvertProblem.monthOutOfRange,
      );
      final day0 = error(convertDate(CalendarKind.jalali, '1405', '1', '0'));
      expect(day0.problem, ConvertProblem.dayOutOfRange);
      expect(day0.maxDay, 31);
      expect(
        error(convertDate(CalendarKind.jalali, '1405', '7', '31')).maxDay,
        30,
      );
    });

    test('years outside the supported range', () {
      for (final kind in CalendarKind.values) {
        expect(
          error(convertDate(kind, '99999', '1', '1')).problem,
          ConvertProblem.outOfRange,
          reason: '$kind',
        );
      }
      expect(
        error(convertDate(CalendarKind.jalali, '500', '1', '1')).problem,
        ConvertProblem.outOfRange,
      );
      expect(
        error(convertDate(CalendarKind.gregorian, '1200', '1', '1')).problem,
        ConvertProblem.outOfRange,
      );
      // The Umm al-Qura table ends before 1600 AH.
      expect(
        error(convertDate(CalendarKind.hijri, '1600', '1', '1')).problem,
        ConvertProblem.outOfRange,
      );
    });

    test('empty and non-numeric fields', () {
      expect(
        error(convertDate(CalendarKind.jalali, '1405', '', '1')).problem,
        ConvertProblem.incomplete,
      );
      expect(
        error(convertDate(CalendarKind.jalali, '', '', '')).problem,
        ConvertProblem.incomplete,
      );
      for (final bad in ['x', '1.5', '-1', '1e3', '١٢a']) {
        expect(
          error(convertDate(CalendarKind.gregorian, bad, '1', '1')).problem,
          ConvertProblem.notANumber,
          reason: bad,
        );
      }
    });

    test('every Shamsi day of 1405 round-trips through the Gregorian date', () {
      for (var m = 1; m <= 12; m++) {
        final length = TriDate.jalaliMonthLength(1405, m);
        for (var d = 1; d <= length; d++) {
          final a = ok(convertDate(CalendarKind.jalali, '1405', '$m', '$d'));
          final g = a.gregorian;
          final b = ok(
            convertDate(
              CalendarKind.gregorian,
              '${g.year}',
              '${g.month}',
              '${g.day}',
            ),
          );
          expect(b.jalali, CalendarDate(1405, m, d));
        }
      }
    });
  });
}
