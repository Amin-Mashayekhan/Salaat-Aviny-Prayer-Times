import 'package:prayer_core/src/astronomy/julian_day.dart';
import 'package:prayer_core/src/astronomy/solar_position.dart';
import 'package:prayer_core/src/astronomy/trig.dart';
import 'package:test/test.dart';

void main() {
  group('trig', () {
    test('degree functions', () {
      expect(sinD(30), closeTo(0.5, 1e-12));
      expect(cosD(60), closeTo(0.5, 1e-12));
      expect(tanD(45), closeTo(1, 1e-12));
      expect(asinD(0.5), closeTo(30, 1e-10));
      expect(acosD(0.5), closeTo(60, 1e-10));
      expect(atan2D(1, 1), closeTo(45, 1e-10));
      expect(acotD(1), closeTo(45, 1e-10));
    });

    test('fix reduces into [0, modulus)', () {
      expect(fix(370, 360), closeTo(10, 1e-12));
      expect(fix(-10, 360), closeTo(350, 1e-12));
      expect(fix(360, 360), 0);
      expect(fix(0, 24), 0);
      expect(fix(-0.5, 24), closeTo(23.5, 1e-12));
      expect(fix(49, 24), closeTo(1, 1e-12));
    });
  });

  group('julianDay', () {
    test('matches the reference for known dates', () {
      expect(julianDay(2000, 1, 1), 2451544.5);
      expect(julianDay(2026, 11, 11), 2461355.5);
      expect(julianDay(1900, 3, 1), 2415079.5);
      expect(julianDay(2024, 2, 29), 2460369.5);
      expect(julianDay(2030, 7, 1), 2462683.5);
    });

    test('instant version agrees with the date version at midnight', () {
      expect(
        julianDayOfInstant(DateTime.utc(2026, 11, 11)),
        julianDay(2026, 11, 11),
      );
      expect(
        julianDayOfInstant(DateTime.utc(2026, 11, 11, 12)),
        julianDay(2026, 11, 11) + 0.5,
      );
    });
  });

  group('solarPosition', () {
    void check(double jd, double decl, double eqt) {
      final p = solarPosition(jd);
      expect(p.declination, closeTo(decl, 1e-9), reason: 'declination $jd');
      expect(p.equationOfTime, closeTo(eqt, 1e-9), reason: 'eqt $jd');
    }

    test('matches the reference', () {
      check(2451545, -23.033503799852458, -0.05505289567150484);
      check(2461000.5, -19.914602519739894, 0.23682165002850653);
      check(2460000.25, -9.360301567469323, -0.2197527423718384);
      check(2465000, -15.014725574807143, 0.2742892833240482);
      check(2457000.75, -22.808850382306566, 0.1301082915057954);
    });

    test('declination stays within the obliquity', () {
      for (var day = 0; day < 366; day++) {
        final p = solarPosition(2460310.5 + day);
        expect(p.declination.abs(), lessThan(23.5));
      }
    });
  });
}
