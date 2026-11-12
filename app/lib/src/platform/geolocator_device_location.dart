import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// [DeviceLocationService] on `geolocator`, whose Windows backend uses the
/// WinRT geolocator: GPS when the PC has one, otherwise a position estimated
/// from Wi-Fi.
///
/// It reads the position once, only when [currentPosition] is called (the
/// "find my position" button), and keeps nothing.
class GeolocatorDeviceLocation implements DeviceLocationService {
  /// Creates the service.
  const GeolocatorDeviceLocation();

  @override
  Future<DeviceFix> currentPosition({
    Duration timeLimit = const Duration(seconds: 20),
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const DeviceLocationException(
          DeviceLocationFailure.serviceDisabled,
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      switch (permission) {
        case LocationPermission.denied:
          throw const DeviceLocationException(
            DeviceLocationFailure.permissionDenied,
          );
        case LocationPermission.deniedForever:
          throw const DeviceLocationException(
            DeviceLocationFailure.permissionDeniedForever,
          );
        case LocationPermission.whileInUse:
        case LocationPermission.always:
        case LocationPermission.unableToDetermine:
          break;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );
      return DeviceFix(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy > 0 ? position.accuracy : null,
      );
    } on DeviceLocationException {
      rethrow;
    } on TimeoutException {
      throw const DeviceLocationException(DeviceLocationFailure.timeout);
    } on LocationServiceDisabledException {
      throw const DeviceLocationException(
        DeviceLocationFailure.serviceDisabled,
      );
    } on PermissionDeniedException {
      throw const DeviceLocationException(
        DeviceLocationFailure.permissionDenied,
      );
    } on Object catch (error) {
      throw DeviceLocationException(DeviceLocationFailure.failed, '$error');
    }
  }
}
