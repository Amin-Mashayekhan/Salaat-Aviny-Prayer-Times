import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:prayer_core/prayer_core.dart';

void main() {
  final resolver = ZoneOffsetResolver();
  const auto = LocationOffset.automatic();

  group('automatic zones', () {
    test('London follows its own daylight saving through the database', () {
      Duration london(CivilDate d) =>
          resolver.offsetFor(rule: auto, zoneId: 'Europe/London', date: d);
      expect(london(CivilDate(2026, 1, 15)), Duration.zero);
      expect(london(CivilDate(2026, 7, 15)), const Duration(hours: 1));
    });

    test('a zone with a change at night is resolved by its noon offset', () {
      // UK clocks go forward at 01:00 UTC on 2026-03-29: that civil day uses
      // the summer offset for all of its prayer times (noon is after it).
      Duration london(CivilDate d) =>
          resolver.offsetFor(rule: auto, zoneId: 'Europe/London', date: d);
      expect(london(CivilDate(2026, 3, 28)), Duration.zero);
      expect(london(CivilDate(2026, 3, 29)), const Duration(hours: 1));
      expect(london(CivilDate(2026, 10, 25)), Duration.zero);
    });

    test('a zone far east of UTC works too', () {
      expect(
        resolver.offsetFor(
          rule: auto,
          zoneId: 'Pacific/Kiritimati',
          date: CivilDate(2026, 6, 1),
        ),
        const Duration(hours: 14),
      );
    });

    test('unknown zones are reported', () {
      expect(resolver.knowsZone('Asia/Tehran'), isTrue);
      expect(resolver.knowsZone('Mars/Olympus'), isFalse);
      expect(resolver.zoneIds, contains('Asia/Tehran'));
    });
  });

  group('fixed offsets (rule T-3)', () {
    test('apply on every date of the year, even where the zone has DST', () {
      const fixed = LocationOffset.fixed(60);
      for (final date in [
        CivilDate(2026, 1, 15),
        CivilDate(2026, 3, 29),
        CivilDate(2026, 7, 15),
        CivilDate(2026, 10, 25),
      ]) {
        expect(
          resolver.offsetFor(rule: fixed, zoneId: 'Europe/London', date: date),
          const Duration(hours: 1),
        );
      }
    });

    test('negative and half-hour fixed offsets', () {
      expect(
        resolver.offsetFor(
          rule: const LocationOffset.fixed(-210),
          zoneId: 'UTC',
          date: CivilDate(2026, 1, 1),
        ),
        const Duration(hours: -3, minutes: -30),
      );
    });
  });

  group('offsetAt and civilDateAt', () {
    test('an instant near midnight belongs to different civil days', () {
      const offset = Duration(hours: 3, minutes: 30);
      expect(
        resolver.civilDateAt(DateTime.utc(2026, 11, 11, 20, 29), offset),
        CivilDate(2026, 11, 11),
      );
      expect(
        resolver.civilDateAt(DateTime.utc(2026, 11, 11, 20, 30), offset),
        CivilDate(2026, 11, 12),
      );
    });

    test('offsetAt reads the database at an exact instant', () {
      expect(
        resolver.offsetAt('Europe/London', DateTime.utc(2026, 3, 29, 0, 59)),
        Duration.zero,
      );
      expect(
        resolver.offsetAt('Europe/London', DateTime.utc(2026, 3, 29, 1)),
        const Duration(hours: 1),
      );
    });
  });
}
