import 'package:prayer_core/prayer_core.dart';
import 'package:test/test.dart';

void main() {
  const tehranLat = 35.6892;
  const tehranLon = 51.389;

  test('bearing from Tehran', () {
    expect(qiblaBearing(tehranLat, tehranLon), closeTo(218.4, 0.05));
  });

  test('bearing from the equator and prime meridian', () {
    expect(qiblaBearing(0, 0), closeTo(58.508, 0.001));
  });

  test('bearing is within [0, 360)', () {
    for (var lat = -80.0; lat <= 80; lat += 20) {
      for (var lon = -180.0; lon <= 180; lon += 30) {
        final b = qiblaBearing(lat, lon);
        expect(b, inInclusiveRange(0, 360));
      }
    }
  });

  test('distance from Tehran', () {
    expect(distanceToKaabaKm(tehranLat, tehranLon), closeTo(1943.84, 0.01));
    expect(distanceToKaabaKm(kaabaLatitude, kaabaLongitude), closeTo(0, 1e-6));
  });

  group('sunDirection', () {
    test('local noon in Tehran points south and high', () {
      // Solar noon near 08:18 UTC on 2026-06-21 (about 11:48 +03:30 shifted).
      final noon = DateTime.utc(2026, 6, 21, 8, 36);
      final sun = sunDirection(noon, latitude: tehranLat, longitude: tehranLon);
      expect(sun.azimuth, closeTo(180, 3));
      expect(sun.altitude, greaterThan(70));
    });

    test('the sun is below the horizon at local midnight', () {
      final night = DateTime.utc(2026, 6, 21, 20, 30);
      final sun = sunDirection(
        night,
        latitude: tehranLat,
        longitude: tehranLon,
      );
      expect(sun.altitude, lessThan(0));
    });

    test('azimuth is within [0, 360)', () {
      for (var hour = 0; hour < 24; hour++) {
        final sun = sunDirection(
          DateTime.utc(2026, 3, 21, hour),
          latitude: tehranLat,
          longitude: tehranLon,
        );
        expect(sun.azimuth, inInclusiveRange(0, 360));
      }
    });
  });

  group('sunOnQibla', () {
    test('Tehran, 2026-06-21: the sun crosses the qibla bearing', () {
      const offset = Duration(hours: 3, minutes: 30);
      final result = sunOnQibla(
        date: CivilDate(2026, 6, 21),
        latitude: tehranLat,
        longitude: tehranLon,
        utcOffset: offset,
      );
      final bearing = qiblaBearing(tehranLat, tehranLon);
      expect(result.inDirection, isNotNull);
      final at = result.inDirection!;
      final sun = sunDirection(at, latitude: tehranLat, longitude: tehranLon);
      expect(sun.altitude, greaterThan(0));
      expect((sun.azimuth - bearing).abs(), lessThan(0.05));
      final local = at.add(offset);
      expect(local.hour, inInclusiveRange(12, 13));
    });

    test('the opposite direction is above the horizon when reported', () {
      final result = sunOnQibla(
        date: CivilDate(2026, 3, 21),
        latitude: tehranLat,
        longitude: tehranLon,
        utcOffset: const Duration(hours: 3, minutes: 30),
      );
      final opposite = result.opposite;
      if (opposite != null) {
        final sun = sunDirection(
          opposite,
          latitude: tehranLat,
          longitude: tehranLon,
        );
        final target = (qiblaBearing(tehranLat, tehranLon) + 180) % 360;
        expect((sun.azimuth - target).abs(), lessThan(0.05));
        expect(sun.altitude, greaterThan(0));
      }
    });
  });
}
