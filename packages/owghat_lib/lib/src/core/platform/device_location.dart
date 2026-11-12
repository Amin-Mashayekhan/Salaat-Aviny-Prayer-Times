import 'package:flutter/foundation.dart';

/// Why the device position could not be read.
enum DeviceLocationFailure {
  /// Location services are switched off in the operating system.
  serviceDisabled,

  /// The user (or a policy) has not allowed this app to read the position.
  permissionDenied,

  /// The permission was refused for good; it can only be changed in the
  /// operating system settings.
  permissionDeniedForever,

  /// No position arrived in time (typical on a PC without GPS).
  timeout,

  /// This platform cannot provide a position.
  unsupported,

  /// Anything else.
  failed,
}

/// A position reported by the device.
@immutable
class DeviceFix {
  /// Creates a fix.
  const DeviceFix({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  /// Degrees north.
  final double latitude;

  /// Degrees east.
  final double longitude;

  /// How far off the position may be, in metres, when the device says so.
  final double? accuracyMeters;

  @override
  bool operator ==(Object other) =>
      other is DeviceFix &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.accuracyMeters == accuracyMeters;

  @override
  int get hashCode => Object.hash(latitude, longitude, accuracyMeters);

  @override
  String toString() => 'DeviceFix($latitude, $longitude ±$accuracyMeters m)';
}

/// Thrown by [DeviceLocationService.currentPosition].
class DeviceLocationException implements Exception {
  /// Creates the exception.
  const DeviceLocationException(this.failure, [this.message = '']);

  /// What went wrong.
  final DeviceLocationFailure failure;

  /// Detail for the log (never shown to the user).
  final String message;

  @override
  String toString() => 'DeviceLocationException($failure) $message';
}

/// Reads the position of this device, once, when asked.
///
/// The app never reads the position by itself: only when the user presses
/// the "use my location" button, and the result is neither stored nor sent
/// anywhere. The Windows implementation lives in the app package.
abstract interface class DeviceLocationService {
  /// Asks for the current position, waiting at most [timeLimit]. Throws a
  /// [DeviceLocationException] when it cannot be had.
  Future<DeviceFix> currentPosition({
    Duration timeLimit = const Duration(seconds: 20),
  });

  /// Opens the operating system's location settings page, where the person
  /// can switch location on or allow this app. It only shows the page; the
  /// app never changes the setting itself. Returns false when the page could
  /// not be opened.
  Future<bool> openSystemSettings();
}

/// The service of a platform that has no position source.
class UnsupportedDeviceLocation implements DeviceLocationService {
  /// Creates it.
  const UnsupportedDeviceLocation();

  @override
  Future<bool> openSystemSettings() async => false;

  @override
  Future<DeviceFix> currentPosition({
    Duration timeLimit = const Duration(seconds: 20),
  }) => Future.error(
    const DeviceLocationException(DeviceLocationFailure.unsupported),
  );
}
