import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/clock/application/now_minute_provider.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_status.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:prayer_core/prayer_core.dart';

/// The qibla of the active location.
@immutable
class QiblaInfo {
  /// Creates the info.
  const QiblaInfo({
    required this.bearing,
    required this.distanceKm,
    required this.compassIndex,
  });

  /// Degrees clockwise from true north, in `[0, 360)`.
  final double bearing;

  /// Great-circle distance to the Kaaba in kilometres.
  final double distanceKm;

  /// Eight-point compass index of [bearing]: 0 = north, 1 = north-east ...
  final int compassIndex;

  @override
  bool operator ==(Object other) =>
      other is QiblaInfo &&
      other.bearing == bearing &&
      other.distanceKm == distanceKm &&
      other.compassIndex == compassIndex;

  @override
  int get hashCode => Object.hash(bearing, distanceKm, compassIndex);
}

/// Bearing, distance and compass point of the active location.
final qiblaInfoProvider = Provider<QiblaInfo>((ref) {
  final location = ref.watch(activeLocationProvider);
  final bearing = qiblaBearing(location.latitude, location.longitude);
  return QiblaInfo(
    bearing: bearing,
    distanceKm: distanceToKaabaKm(location.latitude, location.longitude),
    compassIndex: compassIndex(bearing),
  );
});

/// Where the sun is, as shown on the compass.
@immutable
class SunNow {
  /// Creates the value.
  const SunNow({required this.azimuth, required this.altitude});

  /// Degrees clockwise from true north.
  final double azimuth;

  /// Degrees above the horizon (negative below).
  final double altitude;

  /// Whether the sun is up (the compass hides its marker at night).
  bool get isUp => altitude > 0;

  @override
  bool operator ==(Object other) =>
      other is SunNow && other.azimuth == azimuth && other.altitude == altitude;

  @override
  int get hashCode => Object.hash(azimuth, altitude);
}

/// The sun's azimuth and altitude at the active location, recomputed once a
/// minute from the app clock.
final sunNowProvider = Provider<SunNow>((ref) {
  final location = ref.watch(activeLocationProvider);
  final direction = sunDirection(
    ref.watch(nowMinuteProvider),
    latitude: location.latitude,
    longitude: location.longitude,
  );
  return SunNow(azimuth: direction.azimuth, altitude: direction.altitude);
});

/// When the sun stands in the qibla direction (and opposite to it) today.
@immutable
class SunOnQiblaToday {
  /// Creates the value.
  const SunOnQiblaToday({
    required this.date,
    required this.utcOffset,
    required this.inDirection,
    required this.opposite,
  });

  /// The civil date it was computed for.
  final CivilDate date;

  /// The UTC offset of [date] at the location (for the clock times).
  final Duration utcOffset;

  /// The sun in the qibla direction, or null.
  final DateTime? inDirection;

  /// The sun opposite the qibla direction, or null.
  final DateTime? opposite;

  @override
  bool operator ==(Object other) =>
      other is SunOnQiblaToday &&
      other.date == date &&
      other.utcOffset == utcOffset &&
      other.inDirection == inDirection &&
      other.opposite == opposite;

  @override
  int get hashCode => Object.hash(date, utcOffset, inDirection, opposite);
}

/// Today's sun-on-qibla instants. Computed once per day and location.
final sunOnQiblaTodayProvider = Provider<SunOnQiblaToday>((ref) {
  final location = ref.watch(activeLocationProvider);
  final date = ref.watch(todayProvider);
  final offset = ref
      .watch(zoneOffsetResolverProvider)
      .offsetFor(rule: location.offset, zoneId: location.zoneId, date: date);
  final found = sunOnQibla(
    date: date,
    latitude: location.latitude,
    longitude: location.longitude,
    utcOffset: offset,
  );
  return SunOnQiblaToday(
    date: date,
    utcOffset: offset,
    inDirection: found.inDirection,
    opposite: found.opposite,
  );
});
