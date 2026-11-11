import 'dart:async';

import 'package:owghat_lib/owghat_lib.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

/// [SingleInstance] on `windows_single_instance` (a named pipe).
///
/// A second copy writes its arguments to the pipe of the first one and then
/// reports "not primary", so `bootstrap` returns and the process ends. The
/// first copy gets the arguments on [forwardedArgs]; the window controller
/// shows the window then (the plugin's own bring-to-front is switched off,
/// because the window may be hidden in the tray).
class WindowsSingleInstanceGuard implements SingleInstance {
  /// Creates the guard.
  WindowsSingleInstanceGuard();

  /// Pipe name: unique to this app (letters, digits, `_` and `-` only).
  static const String pipeName = 'owghat-single-instance-6b1f2c0e';

  final StreamController<List<String>> _forwarded =
      StreamController<List<String>>.broadcast();

  @override
  Stream<List<String>> get forwardedArgs => _forwarded.stream;

  @override
  Future<bool> ensure(List<String> args) async {
    var primary = true;
    await WindowsSingleInstance.ensureSingleInstance(
      args,
      pipeName,
      bringWindowToFront: false,
      onSecondWindow: _forwarded.add,
      // The plugin calls this for the second copy, instead of exit(0).
      exitFunction: () async => primary = false,
    );
    return primary;
  }
}
