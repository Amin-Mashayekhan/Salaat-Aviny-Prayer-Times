import 'dart:async';

import 'package:flutter/services.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// [PowerEvents] fed by the Windows runner.
///
/// `windows/runner/flutter_window.cpp` watches `WM_POWERBROADCAST`
/// (suspend, resume) and `WM_TIMECHANGE` / `WM_SETTINGCHANGE` and calls the
/// method `event` of the channel `owghat/power` with one of the strings
/// `suspending`, `resumed` or `timeChanged`.
class WindowsPowerEvents implements PowerEvents {
  /// Creates the source and starts listening on the channel.
  WindowsPowerEvents({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName) {
    _channel.setMethodCallHandler(_onCall);
  }

  /// Name of the channel shared with the runner.
  static const String channelName = 'owghat/power';

  final MethodChannel _channel;
  final StreamController<PowerEvent> _events =
      StreamController<PowerEvent>.broadcast();

  @override
  Stream<PowerEvent> get events => _events.stream;

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method != 'event') return null;
    final name = call.arguments;
    for (final event in PowerEvent.values) {
      if (event.name == name) {
        _events.add(event);
        break;
      }
    }
    return null;
  }
}
