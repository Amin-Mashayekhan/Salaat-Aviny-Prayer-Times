import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/device_location.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_status.dart';
import 'package:owghat_lib/src/features/qibla/application/qibla_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

final Logger _log = Logger('QiblaPoint');

/// Where the qibla map measures from.
enum QiblaSourceKind {
  /// The city chosen for the prayer times.
  city,

  /// The position the device reported when the user asked for it.
  device,

  /// A point picked on the map or typed as coordinates.
  custom,
}

/// What the user chose on the qibla map page. Lives only as long as the app
/// runs: it is never written to the settings, and no position is stored.
@immutable
class QiblaPointState {
  /// Creates the state.
  const QiblaPointState({
    this.kind = QiblaSourceKind.city,
    this.deviceFix,
    this.customPoint,
    this.locating = false,
    this.failure,
  });

  /// Which source is in use.
  final QiblaSourceKind kind;

  /// The last position the device reported, if any.
  final DeviceFix? deviceFix;

  /// The last point picked by hand, if any.
  final GeoPoint? customPoint;

  /// Whether a position request is in flight.
  final bool locating;

  /// Why the last position request failed, or null.
  final DeviceLocationFailure? failure;

  /// Copy with changes ([clearFailure] removes [failure]).
  QiblaPointState copyWith({
    QiblaSourceKind? kind,
    DeviceFix? deviceFix,
    GeoPoint? customPoint,
    bool? locating,
    DeviceLocationFailure? failure,
    bool clearFailure = false,
  }) => QiblaPointState(
    kind: kind ?? this.kind,
    deviceFix: deviceFix ?? this.deviceFix,
    customPoint: customPoint ?? this.customPoint,
    locating: locating ?? this.locating,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  bool operator ==(Object other) =>
      other is QiblaPointState &&
      other.kind == kind &&
      other.deviceFix == deviceFix &&
      other.customPoint == customPoint &&
      other.locating == locating &&
      other.failure == failure;

  @override
  int get hashCode =>
      Object.hash(kind, deviceFix, customPoint, locating, failure);
}

/// Controls where the qibla map measures from.
class QiblaPointController extends Notifier<QiblaPointState> {
  /// Bumped by every choice, so the answer to an older request is dropped.
  int _request = 0;

  @override
  QiblaPointState build() => const QiblaPointState();

  /// Measures from the prayer-times city.
  void useCity() {
    _request++;
    state = state.copyWith(
      kind: QiblaSourceKind.city,
      locating: false,
      clearFailure: true,
    );
  }

  /// Measures from the device position: shows the last fix if there is one,
  /// otherwise asks the device.
  Future<void> useDevice() {
    if (state.deviceFix != null && state.failure == null) {
      _request++;
      state = state.copyWith(
        kind: QiblaSourceKind.device,
        locating: false,
        clearFailure: true,
      );
      return Future.value();
    }
    return locateDevice();
  }

  /// Asks the device for its position (again). On failure the source stays
  /// where it was and [QiblaPointState.failure] says why, so the page can fall
  /// back to the city and explain.
  Future<void> locateDevice() async {
    final request = ++_request;
    state = state.copyWith(locating: true, clearFailure: true);
    try {
      final fix = await ref.read(deviceLocationProvider).currentPosition();
      if (request != _request) return;
      if (!isValidCoordinate(fix.latitude, fix.longitude)) {
        throw const DeviceLocationException(
          DeviceLocationFailure.failed,
          'invalid coordinates',
        );
      }
      // The coordinates are deliberately not logged.
      _log.info('Device position found (accuracy ${fix.accuracyMeters} m)');
      state = state.copyWith(
        kind: QiblaSourceKind.device,
        deviceFix: fix,
        locating: false,
        clearFailure: true,
      );
    } on DeviceLocationException catch (error) {
      _log.info('Device position unavailable: ${error.failure}');
      if (request != _request) return;
      state = state.copyWith(locating: false, failure: error.failure);
    } on Object catch (error, stack) {
      _log.warning('Reading the device position failed', error, stack);
      if (request != _request) return;
      state = state.copyWith(
        locating: false,
        failure: DeviceLocationFailure.failed,
      );
    }
  }

  /// Measures from a point picked on the map or typed in.
  void setCustom(double latitude, double longitude) {
    if (!isValidCoordinate(latitude, longitude)) return;
    _request++;
    state = state.copyWith(
      kind: QiblaSourceKind.custom,
      customPoint: (latitude: latitude, longitude: longitude),
      locating: false,
      clearFailure: true,
    );
  }

  /// Measures from the coordinates in [text]; returns false (and changes
  /// nothing) if the text is not a valid pair.
  bool setCustomFromText(String text) {
    final point = parseCoordinates(text);
    if (point == null) return false;
    setCustom(point.latitude, point.longitude);
    return true;
  }
}

/// The qibla map source chosen by the user.
final qiblaPointProvider =
    NotifierProvider<QiblaPointController, QiblaPointState>(
      QiblaPointController.new,
    );

/// Everything the qibla map shows for the chosen source.
@immutable
class QiblaView {
  /// Creates the view.
  const QiblaView({
    required this.kind,
    required this.latitude,
    required this.longitude,
    required this.info,
    this.placeName,
    this.accuracyMeters,
  });

  /// Which source this is.
  final QiblaSourceKind kind;

  /// Degrees north of the start point.
  final double latitude;

  /// Degrees east of the start point.
  final double longitude;

  /// Bearing, distance and compass point.
  final QiblaInfo info;

  /// The city name for [QiblaSourceKind.city], otherwise null.
  final String? placeName;

  /// Accuracy of a device fix in metres, when known.
  final double? accuracyMeters;

  @override
  bool operator ==(Object other) =>
      other is QiblaView &&
      other.kind == kind &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.info == info &&
      other.placeName == placeName &&
      other.accuracyMeters == accuracyMeters;

  @override
  int get hashCode =>
      Object.hash(kind, latitude, longitude, info, placeName, accuracyMeters);
}

QiblaInfo _infoFor(double latitude, double longitude) {
  final bearing = qiblaBearing(latitude, longitude);
  return QiblaInfo(
    bearing: bearing,
    distanceKm: distanceToKaabaKm(latitude, longitude),
    compassIndex: compassIndex(bearing),
  );
}

/// The start point, bearing and distance for the chosen source. While the
/// device position is not available (not asked yet, failed, or the user picked
/// another source) the prayer-times city is used.
final qiblaViewProvider = Provider<QiblaView>((ref) {
  final choice = ref.watch(qiblaPointProvider);
  final language = ref.watch(settingsProvider.select((s) => s.language));
  switch (choice.kind) {
    case QiblaSourceKind.device:
      final fix = choice.deviceFix;
      if (fix != null) {
        return QiblaView(
          kind: QiblaSourceKind.device,
          latitude: fix.latitude,
          longitude: fix.longitude,
          info: _infoFor(fix.latitude, fix.longitude),
          accuracyMeters: fix.accuracyMeters,
        );
      }
    case QiblaSourceKind.custom:
      final point = choice.customPoint;
      if (point != null) {
        return QiblaView(
          kind: QiblaSourceKind.custom,
          latitude: point.latitude,
          longitude: point.longitude,
          info: _infoFor(point.latitude, point.longitude),
        );
      }
    case QiblaSourceKind.city:
      break;
  }
  final city = ref.watch(activeLocationProvider);
  return QiblaView(
    kind: QiblaSourceKind.city,
    latitude: city.latitude,
    longitude: city.longitude,
    info: _infoFor(city.latitude, city.longitude),
    placeName: city.nameIn(language),
  );
});

/// The great-circle path from the chosen point to the Kaaba, for the map.
final qiblaPathProvider = Provider<List<GeoPoint>>((ref) {
  final view = ref.watch(qiblaViewProvider);
  return greatCircleToKaaba(view.latitude, view.longitude);
});
