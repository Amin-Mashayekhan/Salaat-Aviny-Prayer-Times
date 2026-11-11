import 'package:flutter/widgets.dart';
import 'package:owghat/src/platform/wake/windows_wake_services.dart';
import 'package:owghat/src/platform/windows_platform_services.dart';
import 'package:owghat_lib/owghat_lib.dart';
import 'package:owghat_lib/wake_alarm.dart';

/// Entry point of the Windows app: build the platform services and hand them
/// to the library, which does the whole startup sequence.
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await createWindowsPlatformServices();
  final wake = WindowsWakeServices.create(
    tempDirectory: services.paths.appSupportDir.path,
  );
  await bootstrap(
    args,
    services,
    extraOverrides: [
      wakeTimerServiceProvider.overrideWithValue(wake.timer),
      powerControlProvider.overrideWithValue(wake.power),
    ],
  );
}
