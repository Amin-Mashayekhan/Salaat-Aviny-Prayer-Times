import 'dart:async';

import 'package:owghat_lib/src/core/platform/device_location.dart';

/// A [DeviceLocationService] for tests: answers with [fix], throws [failure],
/// or waits for [gate] first.
class FakeDeviceLocation implements DeviceLocationService {
  /// Creates the fake; by default it reports a fix in Neyshabur.
  FakeDeviceLocation({
    this.fix = const DeviceFix(
      latitude: 36.2133,
      longitude: 58.7958,
      accuracyMeters: 35,
    ),
  });

  /// The position returned when [failure] is null.
  DeviceFix fix;

  /// When set, `currentPosition` throws it.
  DeviceLocationException? failure;

  /// When set, `currentPosition` waits for it before answering.
  Future<void>? gate;

  /// Number of calls.
  int calls = 0;

  /// The time limit of the last call.
  Duration? lastTimeLimit;

  @override
  Future<DeviceFix> currentPosition({
    Duration timeLimit = const Duration(seconds: 20),
  }) async {
    calls++;
    lastTimeLimit = timeLimit;
    final waiting = gate;
    if (waiting != null) await waiting;
    final error = failure;
    if (error != null) throw error;
    return fix;
  }
}
