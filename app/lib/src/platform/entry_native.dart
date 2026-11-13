import 'dart:io';

import 'package:owghat/src/platform/desktop/desktop_platform_services.dart';
import 'package:owghat/src/platform/mobile/mobile_platform_services.dart';
import 'package:owghat/src/platform/wake/windows_wake_services.dart';
import 'package:owghat/src/platform/windows_platform_services.dart';
import 'package:owghat_lib/owghat_lib.dart';
import 'package:owghat_lib/wake_alarm.dart';

/// Windows (with wake-up timers), phones, or Linux and macOS.
Future<void> runOnPlatform(List<String> args) async {
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
  if (Platform.isAndroid || Platform.isIOS) {
    await bootstrap(args, await createMobilePlatformServices());
    return;
  }
  await bootstrap(args, await createOtherDesktopPlatformServices());
}
