import 'dart:math' as math;

import 'package:prayer_core/src/astronomy/julian_day.dart';
import 'package:prayer_core/src/astronomy/solar_position.dart';
import 'package:prayer_core/src/astronomy/trig.dart';

/// Latitude of the Kaaba in degrees.
const double kaabaLatitude = 21.422487;

/// Longitude of the Kaaba in degrees.
const double kaabaLongitude = 39.826206;

/// Mean Earth radius in kilometres.
const double earthRadiusKm = 6371.0088;

/// Initial great-circle bearing to the Kaaba in degrees clockwise from true
/// north, in `[0, 360)`.
double qiblaBearing(double latitude, double longitude) {
  final dLon = kaabaLongitude - longitude;
  final y = sinD(dLon);
  final x = cosD(latitude) * tanD(kaabaLatitude) - sinD(latitude) * cosD(dLon);
  return fix(atan2D(y, x), 360);
}

/// Great-circle distance to the Kaaba in kilometres (haversine).
double distanceToKaabaKm(double latitude, double longitude) {
  final dLat = (kaabaLatitude - latitude) * math.pi / 180;
  final dLon = (kaabaLongitude - longitude) * math.pi / 180;
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      cosD(latitude) * cosD(kaabaLatitude) * math.pow(math.sin(dLon / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.sqrt(a));
}

/// Sun direction at an instant.
typedef SunDirection = ({
  /// Azimuth in degrees clockwise from true north, in `[0, 360)`.
  double azimuth,

  /// Altitude above the horizon in degrees (negative when below).
  double altitude,
});

/// Azimuth and altitude of the sun at [utc] for a place.
SunDirection sunDirection(
  DateTime utc, {
  required double latitude,
  required double longitude,
}) {
  final instant = utc.toUtc();
  final position = solarPosition(julianDayOfInstant(instant));
  final utcHours =
      (instant.microsecondsSinceEpoch % Duration.microsecondsPerDay) /
      Duration.microsecondsPerHour;
  final hourAngle =
      15 * (utcHours + longitude / 15 + position.equationOfTime - 12);
  final decl = position.declination;
  final altitude = asinD(
    sinD(latitude) * sinD(decl) + cosD(latitude) * cosD(decl) * cosD(hourAngle),
  );
  final azimuth = fix(
    atan2D(
      -sinD(hourAngle),
      tanD(decl) * cosD(latitude) - sinD(latitude) * cosD(hourAngle),
    ),
    360,
  );
  return (azimuth: azimuth, altitude: altitude);
}
