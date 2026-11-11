import 'package:prayer_core/src/astronomy/trig.dart';

/// Low-precision sun position (USNO formulas, about 1 arc-minute accuracy
/// between 1950 and 2050).
typedef SolarPosition = ({
  /// Declination in degrees.
  double declination,

  /// Equation of time in hours.
  double equationOfTime,
});

/// Sun declination and equation of time at Julian Day [jd].
SolarPosition solarPosition(double jd) {
  final d = jd - 2451545.0;
  final g = fix(357.529 + 0.98560028 * d, 360);
  final q = fix(280.459 + 0.98564736 * d, 360);
  final l = fix(q + 1.915 * sinD(g) + 0.020 * sinD(2 * g), 360);
  final e = 23.439 - 0.00000036 * d;
  final ra = fix(atan2D(cosD(e) * sinD(l), cosD(l)) / 15, 24);
  return (declination: asinD(sinD(e) * sinD(l)), equationOfTime: q / 15 - ra);
}
