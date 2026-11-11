import 'dart:math' as math;

import 'package:prayer_core/src/astronomy/julian_day.dart';
import 'package:prayer_core/src/astronomy/solar_position.dart';
import 'package:prayer_core/src/astronomy/trig.dart';
import 'package:prayer_core/src/calculation/calculation_params.dart';
import 'package:prayer_core/src/calculation/civil_date.dart';
import 'package:prayer_core/src/calculation/prayer.dart';
import 'package:prayer_core/src/calculation/prayer_times.dart';

/// Number of refinement passes of the iterative solution. Fixed so that the
/// result is deterministic; three passes converge to well under 0.1 second.
const int _refinePasses = 3;

/// Pure prayer-time calculator.
///
/// It knows nothing about time zones, daylight saving, the system clock or
/// settings: the UTC offset of the civil date is an explicit input.
/// This is a port of `tools/reference/prayer_times_reference.py`.
class PrayerCalculator {
  /// Creates a calculator (stateless).
  const PrayerCalculator();

  /// Prayer times of [date] at the given place.
  ///
  /// [utcOffset] is the offset (east positive) of the civil time in which the
  /// result is expressed. Values are durations after local midnight of [date];
  /// see [PrayerTimes] for values of 24 hours or more and for nulls.
  PrayerTimes compute({
    required CivilDate date,
    required double latitude,
    required double longitude,
    required Duration utcOffset,
    required CalculationParams params,
    double elevationMeters = 0,
  }) {
    final shift =
        utcOffset.inMicroseconds / Duration.microsecondsPerHour -
        longitude / 15;

    final today = _computeDay(
      date,
      latitude,
      longitude,
      elevationMeters,
      params,
    );
    double? shifted(double? hours) => hours == null ? null : hours + shift;

    final fajr = shifted(today.fajr);
    final sunset = shifted(today.sunset);

    double? midnight;
    if (sunset != null) {
      final tomorrow = _computeDay(
        date.addDays(1),
        latitude,
        longitude,
        elevationMeters,
        params,
      );
      final end = params.midnight == MidnightRule.jafari
          ? tomorrow.fajr
          : tomorrow.sunrise;
      if (end != null) {
        midnight = sunset + (end + shift + 24 - sunset) / 2;
      }
    }

    return PrayerTimes({
      Prayer.imsak: _duration(
        fajr == null ? null : fajr - params.imsakMinutes / 60,
      ),
      Prayer.fajr: _duration(fajr),
      Prayer.sunrise: _duration(shifted(today.sunrise)),
      Prayer.dhuhr: _duration(shifted(today.dhuhr)),
      Prayer.asr: _duration(shifted(today.asr)),
      Prayer.sunset: _duration(sunset),
      Prayer.maghrib: _duration(shifted(today.maghrib)),
      Prayer.isha: _duration(shifted(today.isha)),
      Prayer.midnight: _duration(midnight),
    });
  }

  static Duration? _duration(double? hours) => hours == null
      ? null
      : Duration(microseconds: (hours * Duration.microsecondsPerHour).round());
}

/// Times of one day in the "UT + longitude/15" frame, in hours.
class _Day {
  _Day({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
  });

  double? fajr;
  double? sunrise;
  final double? dhuhr;
  final double? asr;
  final double? sunset;
  double? maghrib;
  double? isha;
}

_Day _computeDay(
  CivilDate date,
  double lat,
  double lon,
  double elevationMeters,
  CalculationParams params,
) {
  final jd = julianDay(date.year, date.month, date.day) - lon / (15.0 * 24.0);

  double midDay(double t) => fix(12 - solarPosition(jd + t).equationOfTime, 24);

  double? angleTime(double angle, double t, {required bool beforeNoon}) {
    final decl = solarPosition(jd + t).declination;
    final noon = midDay(t);
    final x =
        (-sinD(angle) - sinD(decl) * sinD(lat)) / (cosD(decl) * cosD(lat));
    if (x < -1 || x > 1) return null;
    final h = acosD(x) / 15;
    return beforeNoon ? noon - h : noon + h;
  }

  double? asrTime(double factor, double t) {
    final decl = solarPosition(jd + t).declination;
    final angle = -acotD(factor + tanD((lat - decl).abs()));
    return angleTime(angle, t, beforeNoon: false);
  }

  final horizon = 0.833 + 0.0347 * math.sqrt(math.max(elevationMeters, 0));
  final t = <String, double>{
    'fajr': 5 / 24,
    'sunrise': 6 / 24,
    'dhuhr': 12 / 24,
    'asr': 13 / 24,
    'sunset': 18 / 24,
    'maghrib': 18 / 24,
    'isha': 18 / 24,
  };

  late _Day day;
  for (var pass = 0; pass < _refinePasses; pass++) {
    final maghribAngle = params.maghribAngle;
    final ishaAngle = params.ishaAngle;
    final fresh = <String, double?>{
      'fajr': angleTime(params.fajrAngle, t['fajr']!, beforeNoon: true),
      'sunrise': angleTime(horizon, t['sunrise']!, beforeNoon: true),
      'dhuhr': midDay(t['dhuhr']!),
      'asr': asrTime(params.asr.shadowFactor, t['asr']!),
      'sunset': angleTime(horizon, t['sunset']!, beforeNoon: false),
      'maghrib': maghribAngle == null
          ? null
          : angleTime(maghribAngle, t['maghrib']!, beforeNoon: false),
      'isha': ishaAngle == null
          ? null
          : angleTime(ishaAngle, t['isha']!, beforeNoon: false),
    };
    day = _Day(
      fajr: fresh['fajr'],
      sunrise: fresh['sunrise'],
      dhuhr: fresh['dhuhr'],
      asr: fresh['asr'],
      sunset: fresh['sunset'],
      maghrib: fresh['maghrib'],
      isha: fresh['isha'],
    );
    for (final entry in fresh.entries) {
      final value = entry.value;
      if (value != null) t[entry.key] = value / 24;
    }
  }

  _applyHighLatitude(day, params);

  if (params.maghribAngle == null) {
    day.maghrib = day.sunset;
  }
  if (params.ishaAngle == null) {
    final maghrib = day.maghrib;
    day.isha = maghrib == null
        ? null
        : maghrib + (params.ishaMinutes ?? 0) / 60;
  }
  return day;
}

void _applyHighLatitude(_Day day, CalculationParams params) {
  final rule = params.highLatitude;
  final sunrise = day.sunrise;
  final sunset = day.sunset;
  if (rule == HighLatitudeRule.none || sunrise == null || sunset == null) {
    return;
  }

  final night = fix(sunrise - sunset, 24);

  double portion(double angle) => switch (rule) {
    HighLatitudeRule.angleBased => angle / 60 * night,
    HighLatitudeRule.oneSeventh => night / 7,
    _ => night / 2,
  };

  double adjust(
    double? value,
    double base,
    double angle, {
    required bool before,
  }) {
    final limit = portion(angle);
    final diff = value == null
        ? null
        : (before ? fix(base - value, 24) : fix(value - base, 24));
    if (value == null || diff == null || diff > limit) {
      return before ? base - limit : base + limit;
    }
    return value;
  }

  day.fajr = adjust(day.fajr, sunrise, params.fajrAngle, before: true);
  final ishaAngle = params.ishaAngle;
  if (ishaAngle != null) {
    day.isha = adjust(day.isha, sunset, ishaAngle, before: false);
  }
  final maghribAngle = params.maghribAngle;
  if (maghribAngle != null) {
    day.maghrib = adjust(day.maghrib, sunset, maghribAngle, before: false);
  }
}
