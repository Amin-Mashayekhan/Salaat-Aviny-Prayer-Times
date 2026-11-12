import 'dart:math' as math;

import 'package:prayer_core/prayer_core.dart';
import 'package:test/test.dart';

void main() {
  group('isValidCoordinate', () {
    test('accepts the whole range and rejects everything else', () {
      expect(isValidCoordinate(0, 0), isTrue);
      expect(isValidCoordinate(90, 180), isTrue);
      expect(isValidCoordinate(-90, -180), isTrue);
      expect(isValidCoordinate(90.0001, 0), isFalse);
      expect(isValidCoordinate(0, 180.0001), isFalse);
      expect(isValidCoordinate(double.nan, 0), isFalse);
      expect(isValidCoordinate(0, double.infinity), isFalse);
    });
  });

  group('destinationPoint', () {
    test('zero distance stays put', () {
      final p = destinationPoint(36.2, 58.8, 123, 0);
      expect(p.latitude, closeTo(36.2, 1e-9));
      expect(p.longitude, closeTo(58.8, 1e-9));
    });

    test('due north along a meridian changes only the latitude', () {
      final p = destinationPoint(10, 20, 0, 111.195);
      expect(p.latitude, closeTo(11, 0.001));
      expect(p.longitude, closeTo(20, 1e-6));
    });

    test('due east on the equator changes only the longitude', () {
      final p = destinationPoint(0, 0, 90, 111.195);
      expect(p.latitude, closeTo(0, 1e-6));
      expect(p.longitude, closeTo(1, 0.001));
    });

    test('travelling the whole distance towards the Kaaba reaches it', () {
      for (final start in const [
        (latitude: 35.6892, longitude: 51.389),
        (latitude: 36.2133, longitude: 58.7958),
        (latitude: -33.87, longitude: 151.21),
        (latitude: 40.71, longitude: -74.0),
        (latitude: 64.1, longitude: -21.9),
      ]) {
        final end = destinationPoint(
          start.latitude,
          start.longitude,
          qiblaBearing(start.latitude, start.longitude),
          distanceToKaabaKm(start.latitude, start.longitude),
        );
        expect(end.latitude, closeTo(kaabaLatitude, 1e-4), reason: '$start');
        expect(end.longitude, closeTo(kaabaLongitude, 1e-4), reason: '$start');
      }
    });

    test('the result longitude is normalised and the pole is clamped', () {
      final west = destinationPoint(0, 179, 90, 400);
      expect(west.longitude, inInclusiveRange(-180, 180));
      expect(west.longitude, lessThan(0));
      final pole = destinationPoint(89.9, 0, 0, 5000);
      expect(pole.latitude, inInclusiveRange(-90, 90));
    });
  });

  group('greatCircleToKaaba', () {
    test('starts at the point, ends at the Kaaba, has segments + 1 points', () {
      final path = greatCircleToKaaba(36.2133, 58.7958, segments: 10);
      expect(path.length, 11);
      expect(path.first, (latitude: 36.2133, longitude: 58.7958));
      expect(path.last.latitude, closeTo(kaabaLatitude, 1e-9));
      expect(path.last.longitude, closeTo(kaabaLongitude, 1e-9));
    });

    test('the default has 65 points', () {
      expect(greatCircleToKaaba(35.6892, 51.389).length, 65);
    });

    test('every point lies on the shortest path (distances add up)', () {
      final path = greatCircleToKaaba(36.2133, 58.7958, segments: 20);
      final whole = distanceToKaabaKm(36.2133, 58.7958);
      for (final p in path.skip(1).take(path.length - 2)) {
        final first = _haversine(36.2133, 58.7958, p.latitude, p.longitude);
        final rest = distanceToKaabaKm(p.latitude, p.longitude);
        expect(first + rest, closeTo(whole, 0.5));
      }
    });

    test('a path over the antimeridian stays one continuous line', () {
      for (final start in const [
        (latitude: -41.3, longitude: 174.8),
        (latitude: 21.3, longitude: -157.8),
        (latitude: 61.2, longitude: -149.9),
        (latitude: -17.7, longitude: -149.4),
      ]) {
        final path = greatCircleToKaaba(start.latitude, start.longitude);
        for (var i = 1; i < path.length; i++) {
          expect(
            (path[i].longitude - path[i - 1].longitude).abs(),
            lessThan(180),
            reason: '$start step $i',
          );
        }
      }
    });

    test('longitudes are unwrapped past 180 when a path crosses the line', () {
      // From Fiji the shortest path to Mecca heads west across the date line,
      // so unwrapping must push the first points beyond 180 or the last
      // points below it to keep the line continuous.
      final path = greatCircleToKaaba(-17.7, 178.1);
      final longitudes = path.map((p) => p.longitude).toList();
      for (var i = 1; i < longitudes.length; i++) {
        expect((longitudes[i] - longitudes[i - 1]).abs(), lessThan(180));
      }
      final wrapped = greatCircleToKaaba(-41.3, -170);
      expect(
        wrapped.any((p) => p.longitude < -180 || p.longitude > 180),
        isTrue,
        reason: 'the path to Mecca from -170 degrees goes east past 180',
      );
    });

    test('from the Kaaba itself the path collapses to the Kaaba', () {
      final path = greatCircleToKaaba(
        kaabaLatitude,
        kaabaLongitude,
        segments: 4,
      );
      expect(path.length, 5);
      for (final p in path) {
        expect(p.latitude, closeTo(kaabaLatitude, 1e-6));
        expect(p.longitude, closeTo(kaabaLongitude, 1e-6));
      }
    });
  });

  group('parseCoordinates', () {
    test('comma, space, semicolon and Persian comma separators', () {
      const expected = (latitude: 36.2133, longitude: 58.7958);
      expect(parseCoordinates('36.2133, 58.7958'), expected);
      expect(parseCoordinates('36.2133 58.7958'), expected);
      expect(parseCoordinates('  36.2133;58.7958  '), expected);
      expect(parseCoordinates('36.2133،58.7958'), expected);
    });

    test('Persian and Arabic-Indic digits and the Arabic decimal mark', () {
      const expected = (latitude: 36.2133, longitude: 58.7958);
      expect(
        parseCoordinates(
          '۳۶٫۲۱۳۳، '
          '۵۸٫۷۹۵۸',
        ),
        expected,
      );
      expect(
        parseCoordinates(
          '٣٦.٢١٣٣ '
          '٥٨.٧٩٥٨',
        ),
        expected,
      );
    });

    test('negative numbers are fine', () {
      expect(parseCoordinates('-33.87, -151.21'), (
        latitude: -33.87,
        longitude: -151.21,
      ));
    });

    test('rejects text, a wrong count, and out of range values', () {
      expect(parseCoordinates(''), isNull);
      expect(parseCoordinates('36.2'), isNull);
      expect(parseCoordinates('36.2 58.8 12'), isNull);
      expect(parseCoordinates('north east'), isNull);
      expect(parseCoordinates('36.2 east'), isNull);
      expect(parseCoordinates('95, 10'), isNull);
      expect(parseCoordinates('10, 200'), isNull);
    });
  });
}

double _haversine(double lat1, double lon1, double lat2, double lon2) {
  double rad(double d) => d * math.pi / 180;
  final a =
      math.pow(math.sin(rad(lat2 - lat1) / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(rad(lon2 - lon1) / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.sqrt(a));
}
