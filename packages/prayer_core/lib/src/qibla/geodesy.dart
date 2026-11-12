import 'dart:math' as math;

import 'package:prayer_core/src/astronomy/trig.dart';
import 'package:prayer_core/src/qibla/qibla.dart';

/// A point on the Earth in degrees.
typedef GeoPoint = ({double latitude, double longitude});

/// Whether [latitude] and [longitude] are real coordinates.
bool isValidCoordinate(double latitude, double longitude) =>
    latitude.isFinite &&
    longitude.isFinite &&
    latitude >= -90 &&
    latitude <= 90 &&
    longitude >= -180 &&
    longitude <= 180;

/// The point reached from ([latitude], [longitude]) after travelling
/// [distanceKm] along the great circle that starts in direction
/// [bearing] (degrees clockwise from true north). Longitude is normalised to
/// `[-180, 180]`.
GeoPoint destinationPoint(
  double latitude,
  double longitude,
  double bearing,
  double distanceKm,
) {
  final delta = distanceKm / earthRadiusKm; // angular distance in radians
  final theta = bearing * math.pi / 180;
  final phi1 = latitude * math.pi / 180;
  final lambda1 = longitude * math.pi / 180;
  final sinPhi2 =
      math.sin(phi1) * math.cos(delta) +
      math.cos(phi1) * math.sin(delta) * math.cos(theta);
  final phi2 = math.asin(sinPhi2.clamp(-1.0, 1.0));
  final lambda2 =
      lambda1 +
      math.atan2(
        math.sin(theta) * math.sin(delta) * math.cos(phi1),
        math.cos(delta) - math.sin(phi1) * sinPhi2,
      );
  return (
    latitude: phi2 * 180 / math.pi,
    longitude: fix(lambda2 * 180 / math.pi + 180, 360) - 180,
  );
}

/// The shortest path from ([latitude], [longitude]) to the Kaaba as
/// [segments] + 1 points, the first being the start and the last the Kaaba.
///
/// Longitudes are *unwrapped*: consecutive points never differ by more than
/// 180 degrees, so a path that crosses the antimeridian stays one continuous
/// line on a flat map (its longitudes then leave `[-180, 180]`).
///
/// The points lie on the great circle that leaves the start in the direction
/// of [qiblaBearing], which is the qibla direction the app reports.
List<GeoPoint> greatCircleToKaaba(
  double latitude,
  double longitude, {
  int segments = 64,
}) {
  final distance = distanceToKaabaKm(latitude, longitude);
  final bearing = qiblaBearing(latitude, longitude);
  final points = <GeoPoint>[(latitude: latitude, longitude: longitude)];
  var previousLongitude = longitude;
  for (var i = 1; i < segments; i++) {
    final point = destinationPoint(
      latitude,
      longitude,
      bearing,
      distance * i / segments,
    );
    final unwrapped = _unwrap(point.longitude, previousLongitude);
    points.add((latitude: point.latitude, longitude: unwrapped));
    previousLongitude = unwrapped;
  }
  points.add((
    latitude: kaabaLatitude,
    longitude: _unwrap(kaabaLongitude, previousLongitude),
  ));
  return points;
}

/// [longitude] shifted by whole turns so it lies within 180 degrees of
/// [reference].
double _unwrap(double longitude, double reference) =>
    reference + fix(longitude - reference + 180, 360) - 180;

/// Reads a coordinate pair typed or pasted by a person: "36.2133, 58.7958",
/// "36.2133 58.7958" or the same with a Persian comma, using Latin, Persian
/// or Arabic-Indic digits and the Arabic decimal mark. Returns null if the
/// text is not a valid pair (latitude first, then longitude).
GeoPoint? parseCoordinates(String text) {
  final normalised = StringBuffer();
  for (final unit in text.runes) {
    if (unit >= 0x06F0 && unit <= 0x06F9) {
      normalised.writeCharCode(unit - 0x06F0 + 0x30); // Persian digits
    } else if (unit >= 0x0660 && unit <= 0x0669) {
      normalised.writeCharCode(unit - 0x0660 + 0x30); // Arabic-Indic digits
    } else if (unit == 0x066B) {
      normalised.write('.'); // Arabic decimal separator
    } else if (unit == 0x060C) {
      normalised.write(','); // Arabic comma
    } else {
      normalised.writeCharCode(unit);
    }
  }
  final parts = normalised
      .toString()
      .trim()
      .split(RegExp(r'[\s,;]+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length != 2) return null;
  final latitude = double.tryParse(parts[0]);
  final longitude = double.tryParse(parts[1]);
  if (latitude == null || longitude == null) return null;
  if (!isValidCoordinate(latitude, longitude)) return null;
  return (latitude: latitude, longitude: longitude);
}
