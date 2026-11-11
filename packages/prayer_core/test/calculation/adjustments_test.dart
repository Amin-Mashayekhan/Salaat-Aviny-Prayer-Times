// Test fixtures build small maps of const values; const is noise here.
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:prayer_core/prayer_core.dart';
import 'package:test/test.dart';

void main() {
  group('roundToMinute', () {
    test('rounds half up', () {
      expect(
        roundToMinute(const Duration(minutes: 5, seconds: 29)),
        const Duration(minutes: 5),
      );
      expect(
        roundToMinute(const Duration(minutes: 5, seconds: 30)),
        const Duration(minutes: 6),
      );
      expect(
        roundToMinute(const Duration(minutes: 5, seconds: 31)),
        const Duration(minutes: 6),
      );
    });

    test('does not wrap past 24 hours', () {
      expect(
        roundToMinute(const Duration(hours: 24, minutes: 30, seconds: 40)),
        const Duration(hours: 24, minutes: 31),
      );
    });
  });

  group('minuteOfDay', () {
    test('23:59:30 becomes 00:00', () {
      expect(
        minuteOfDay(const Duration(hours: 23, minutes: 59, seconds: 30)),
        0,
      );
    });

    test('values past 24 hours wrap for display only', () {
      expect(minuteOfDay(const Duration(hours: 25, minutes: 7)), 67);
    });

    test('negative values wrap into the previous day', () {
      expect(minuteOfDay(const Duration(minutes: -10)), 1430);
    });
  });

  group('applyOffsets', () {
    final base = PrayerTimes({
      Prayer.fajr: const Duration(hours: 5),
      Prayer.dhuhr: const Duration(hours: 12),
      Prayer.midnight: const Duration(hours: 24, minutes: 10),
    });

    test('adds signed minutes and leaves others alone', () {
      final moved = applyOffsets(base, {Prayer.fajr: -7, Prayer.midnight: 20});
      expect(moved[Prayer.fajr], const Duration(hours: 4, minutes: 53));
      expect(moved[Prayer.dhuhr], const Duration(hours: 12));
      expect(moved[Prayer.midnight], const Duration(hours: 24, minutes: 30));
    });

    test('a negative offset may cross midnight', () {
      final early = applyOffsets(
        PrayerTimes({Prayer.fajr: const Duration(minutes: 3)}),
        {Prayer.fajr: -10},
      );
      expect(early[Prayer.fajr], const Duration(minutes: -7));
    });

    test('null times stay null', () {
      final moved = applyOffsets(base, {Prayer.isha: 5});
      expect(moved[Prayer.isha], isNull);
    });
  });

  group('toUtcInstants', () {
    test('subtracts the UTC offset from local midnight', () {
      final instants = toUtcInstants(
        date: CivilDate(2026, 11, 11),
        utcOffset: const Duration(hours: 3, minutes: 30),
        times: PrayerTimes({
          Prayer.fajr: const Duration(hours: 5, minutes: 10),
          Prayer.midnight: const Duration(hours: 24, minutes: 30),
        }),
      );
      expect(instants[Prayer.fajr], DateTime.utc(2026, 11, 11, 1, 40));
      expect(instants[Prayer.midnight], DateTime.utc(2026, 11, 11, 21));
      expect(instants.containsKey(Prayer.isha), isFalse);
    });

    test('a zero or negative offset works too', () {
      final instants = toUtcInstants(
        date: CivilDate(2026, 1, 15),
        utcOffset: const Duration(hours: -5),
        times: PrayerTimes({Prayer.dhuhr: const Duration(hours: 12)}),
      );
      expect(instants[Prayer.dhuhr], DateTime.utc(2026, 1, 15, 17));
    });
  });

  group('rounded times of a real day', () {
    test('Tehran 2026-11-11 reads like the reference', () {
      final times = const PrayerCalculator().compute(
        date: CivilDate(2026, 11, 11),
        latitude: 35.6892,
        longitude: 51.389,
        utcOffset: const Duration(hours: 3, minutes: 30),
        params: CalculationMethod.tehran.params,
      );
      String hm(Prayer p) {
        final m = minuteOfDay(times[p]!);
        return '${(m ~/ 60).toString().padLeft(2, '0')}:'
            '${(m % 60).toString().padLeft(2, '0')}';
      }

      expect(hm(Prayer.imsak), '05:00');
      expect(hm(Prayer.fajr), '05:10');
      expect(hm(Prayer.sunrise), '06:36');
      expect(hm(Prayer.dhuhr), '11:48');
      expect(hm(Prayer.sunset), '17:00');
      expect(hm(Prayer.maghrib), '17:20');
      expect(hm(Prayer.isha), '18:08');
      expect(hm(Prayer.midnight), '23:06');
    });
  });
}
