import 'dart:math' as math;

/// Degree-based trigonometry helpers used by the astronomy code.
///
/// All angles are in degrees unless stated otherwise.

/// Sine of [degrees].
double sinD(double degrees) => math.sin(_toRadians(degrees));

/// Cosine of [degrees].
double cosD(double degrees) => math.cos(_toRadians(degrees));

/// Tangent of [degrees].
double tanD(double degrees) => math.tan(_toRadians(degrees));

/// Arc sine, result in degrees.
double asinD(double x) => _toDegrees(math.asin(x));

/// Arc cosine, result in degrees.
double acosD(double x) => _toDegrees(math.acos(x));

/// Two-argument arc tangent, result in degrees.
double atan2D(double y, double x) => _toDegrees(math.atan2(y, x));

/// Arc cotangent, result in degrees.
double acotD(double x) => _toDegrees(math.atan(1 / x));

/// Reduces [value] into the half-open range `[0, modulus)`.
double fix(double value, double modulus) {
  final reduced = value - modulus * (value / modulus).floorToDouble();
  return reduced < 0 ? reduced + modulus : reduced;
}

double _toRadians(double degrees) => degrees * math.pi / 180;

double _toDegrees(double radians) => radians * 180 / math.pi;
