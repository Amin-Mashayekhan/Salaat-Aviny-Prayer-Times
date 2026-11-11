import 'package:prayer_core/src/astronomy/trig.dart';
import 'package:prayer_core/src/calculation/civil_date.dart';
import 'package:prayer_core/src/qibla/qibla.dart';

/// The instants of one civil day at which the sun is exactly in the qibla
/// direction, or exactly opposite to it, while above the horizon.
typedef SunOnQibla = ({
  /// The sun stands in the qibla direction ("moqarene"), or null.
  DateTime? inDirection,

  /// The sun stands opposite to the qibla direction ("moqabele"), or null.
  DateTime? opposite,
});

/// Finds [SunOnQibla] for [date] at the given place.
///
/// The day is scanned in one-minute steps and each crossing is refined by
/// bisection to one second.
SunOnQibla sunOnQibla({
  required CivilDate date,
  required double latitude,
  required double longitude,
  required Duration utcOffset,
}) {
  final bearing = qiblaBearing(latitude, longitude);
  final start = date.asUtcMidnight.subtract(utcOffset);
  return (
    inDirection: _findCrossing(start, latitude, longitude, bearing),
    opposite: _findCrossing(
      start,
      latitude,
      longitude,
      fix(bearing + 180, 360),
    ),
  );
}

/// Signed angular difference in `[-180, 180)`.
double _difference(double azimuth, double target) =>
    fix(azimuth - target + 180, 360) - 180;

DateTime? _findCrossing(
  DateTime start,
  double latitude,
  double longitude,
  double target,
) {
  const step = Duration(minutes: 1);

  double diffAt(DateTime at) => _difference(
    sunDirection(at, latitude: latitude, longitude: longitude).azimuth,
    target,
  );

  var previous = start;
  var previousDiff = diffAt(previous);
  for (var i = 1; i <= Duration.minutesPerDay; i++) {
    final current = start.add(step * i);
    final currentDiff = diffAt(current);
    final crosses =
        previousDiff.sign != currentDiff.sign &&
        previousDiff.abs() < 90 &&
        currentDiff.abs() < 90;
    if (crosses) {
      final refined = _bisect(previous, current, previousDiff, diffAt);
      final altitude = sunDirection(
        refined,
        latitude: latitude,
        longitude: longitude,
      ).altitude;
      if (altitude > 0) return refined;
    }
    previous = current;
    previousDiff = currentDiff;
  }
  return null;
}

DateTime _bisect(
  DateTime low,
  DateTime high,
  double lowDiff,
  double Function(DateTime) diffAt,
) {
  var a = low;
  var b = high;
  while (b.difference(a) > const Duration(seconds: 1)) {
    final mid = a.add(b.difference(a) ~/ 2);
    final midDiff = diffAt(mid);
    if (midDiff.sign == lowDiff.sign) {
      a = mid;
    } else {
      b = mid;
    }
  }
  return b;
}
