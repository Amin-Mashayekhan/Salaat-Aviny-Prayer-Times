import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:prayer_core/prayer_core.dart';

/// Regression guard for legacy bug B-01.
///
/// Iran abolished daylight saving time in 2022 (last DST period ended on
/// 21 September 2022). If a time-zone database older than 2022b is ever
/// bundled, or anyone adds DST logic of their own, this test fails.
void main() {
  final resolver = ZoneOffsetResolver();
  const auto = LocationOffset.automatic();
  const iran = Duration(hours: 3, minutes: 30);

  Duration tehran(CivilDate date) =>
      resolver.offsetFor(rule: auto, zoneId: 'Asia/Tehran', date: date);

  test('Asia/Tehran is exactly UTC+03:30 on every day, 2023 to 2040', () {
    for (var year = 2023; year <= 2040; year++) {
      var date = CivilDate(year, 1, 1);
      final end = CivilDate(year, 12, 31);
      while (date.compareTo(end) <= 0) {
        expect(tehran(date), iran, reason: 'offset on $date');
        date = date.addDays(1);
      }
    }
  });

  test('specifically the old DST window, 20 March to 25 September', () {
    for (var year = 2023; year <= 2040; year++) {
      for (final day in [
        CivilDate(year, 3, 20),
        CivilDate(year, 3, 21),
        CivilDate(year, 3, 22),
        CivilDate(year, 6, 21),
        CivilDate(year, 9, 21),
        CivilDate(year, 9, 22),
        CivilDate(year, 9, 25),
      ]) {
        expect(tehran(day), iran, reason: 'offset on $day');
      }
    }
  });

  test('history is still known: 2022 summer was UTC+04:30', () {
    expect(
      tehran(CivilDate(2022, 6, 1)),
      const Duration(hours: 4, minutes: 30),
    );
    expect(tehran(CivilDate(2022, 12, 1)), iran);
  });

  test('the first Farvardin of 1402 (2023-03-21) has no clock change', () {
    expect(tehran(CivilDate(2023, 3, 20)), tehran(CivilDate(2023, 3, 22)));
  });

  test('Tehran prayer times do not jump by an hour at the old DST dates', () {
    const calculator = PrayerCalculator();
    Duration dhuhrOn(CivilDate date) => calculator.compute(
      date: date,
      latitude: 35.6892,
      longitude: 51.389,
      utcOffset: tehran(date),
      params: CalculationMethod.tehran.params,
    )[Prayer.dhuhr]!;
    final before = dhuhrOn(CivilDate(2026, 3, 20));
    final after = dhuhrOn(CivilDate(2026, 3, 22));
    expect((after - before).abs(), lessThan(const Duration(minutes: 2)));
    final autumnBefore = dhuhrOn(CivilDate(2026, 9, 21));
    final autumnAfter = dhuhrOn(CivilDate(2026, 9, 23));
    expect(
      (autumnAfter - autumnBefore).abs(),
      lessThan(const Duration(minutes: 2)),
    );
  });
}
