import 'package:prayer_core/prayer_core.dart';
import 'package:test/test.dart';

void main() {
  group('CivilDate', () {
    test('validates, compares and formats', () {
      expect(CivilDate(2026, 11, 11).iso, '2026-11-11');
      expect(CivilDate(2024, 2, 29).iso, '2024-02-29');
      expect(() => CivilDate(2025, 2, 29), throwsArgumentError);
      expect(() => CivilDate(2025, 13, 1), throwsArgumentError);
      expect(CivilDate.parse('2026-03-21'), CivilDate(2026, 3, 21));
      expect(() => CivilDate.parse('2026/03/21'), throwsFormatException);
      expect(
        CivilDate(2026, 1, 1).compareTo(CivilDate(2026, 1, 2)),
        lessThan(0),
      );
    });

    test('addDays crosses month and year boundaries', () {
      expect(CivilDate(2026, 12, 31).addDays(1), CivilDate(2027, 1, 1));
      expect(CivilDate(2024, 2, 28).addDays(1), CivilDate(2024, 2, 29));
      expect(CivilDate(2026, 3, 1).addDays(-1), CivilDate(2026, 2, 28));
    });

    test('weekday is ISO', () {
      expect(CivilDate(2026, 3, 21).weekday, DateTime.saturday);
      expect(CivilDate(2026, 11, 11).weekday, DateTime.wednesday);
    });
  });

  group('CalculationMethod', () {
    test('built-in parameters follow the domain spec', () {
      final t = CalculationMethod.tehran.params;
      expect(t.fajrAngle, 17.7);
      expect(t.ishaAngle, 14);
      expect(t.maghribAngle, 4.5);
      expect(t.midnight, MidnightRule.jafari);
      final j = CalculationMethod.jafari.params;
      expect([j.fajrAngle, j.ishaAngle, j.maghribAngle], [16, 14, 4]);
      expect(CalculationMethod.mwl.params.maghribAngle, isNull);
      expect(CalculationMethod.makkah.params.ishaMinutes, 90);
      expect(CalculationMethod.makkah.params.ishaAngle, isNull);
    });

    test('id lookup and matching', () {
      expect(CalculationMethod.fromId('jafari'), CalculationMethod.jafari);
      expect(CalculationMethod.fromId('nope'), isNull);
      expect(
        CalculationMethod.matching(CalculationMethod.egypt.params),
        CalculationMethod.egypt,
      );
      final edited = CalculationMethod.tehran.params.copyWith(fajrAngle: 18);
      expect(CalculationMethod.matching(edited), CalculationMethod.custom);
    });

    test('copyWith can set nullable fields to null', () {
      final p = CalculationMethod.tehran.params.copyWith(
        maghribAngle: () => null,
      );
      expect(p.maghribAngle, isNull);
      expect(p.fajrAngle, 17.7);
      expect(p, isNot(CalculationMethod.tehran.params));
      expect(
        p.copyWith(maghribAngle: () => 4.5),
        CalculationMethod.tehran.params,
      );
    });
  });

  group('PrayerTimes', () {
    test('missing keys are null and the map is read-only', () {
      final times = PrayerTimes({Prayer.fajr: const Duration(hours: 5)});
      expect(times[Prayer.fajr], const Duration(hours: 5));
      expect(times[Prayer.isha], isNull);
      expect(times.entries.length, Prayer.values.length);
    });

    test('equality compares every prayer', () {
      final a = PrayerTimes({Prayer.fajr: const Duration(hours: 5)});
      final b = PrayerTimes({Prayer.fajr: const Duration(hours: 5)});
      final c = PrayerTimes({Prayer.fajr: const Duration(hours: 6)});
      expect(a, b);
      expect(a, isNot(c));
    });
  });

  test('only the five prayers have an azan', () {
    expect(Prayer.values.where((p) => p.hasAzan), [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ]);
  });
}
