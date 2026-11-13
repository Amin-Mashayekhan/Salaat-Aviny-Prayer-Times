import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:owghat/src/platform/mobile/mobile_platform_services.dart';
import 'package:owghat/src/platform/wake/windows_wake_services.dart';
import 'package:owghat/src/platform/windows_platform_services.dart';
import 'package:owghat_lib/owghat_lib.dart';
import 'package:owghat_lib/wake_alarm.dart';

/// Entry point: build the services of this platform and hand them to the
/// library, which does the whole startup sequence.
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
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
    return;
  }
  await bootstrap(args, await createMobilePlatformServices());
}
