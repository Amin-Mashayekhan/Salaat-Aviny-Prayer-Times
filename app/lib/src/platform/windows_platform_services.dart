import 'package:flutter/services.dart' show rootBundle;
import 'package:owghat/src/platform/audioplayers_output.dart';
import 'package:owghat/src/platform/file_selector_dialogs.dart';
import 'package:owghat/src/platform/flutter_local_notifier.dart';
import 'package:owghat/src/platform/geolocator_device_location.dart';
import 'package:owghat/src/platform/path_provider_paths.dart';
import 'package:owghat/src/platform/registry_autostart.dart';
import 'package:owghat/src/platform/shell_link_opener.dart';
import 'package:owghat/src/platform/tray_manager_host.dart';
import 'package:owghat/src/platform/window_manager_host.dart';
import 'package:owghat/src/platform/windows_power_events.dart';
import 'package:owghat/src/platform/windows_single_instance_guard.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// Builds the bundle of Windows implementations handed to `bootstrap`.
///
/// Everything here is cheap and lazy: the toast plugin initialises on the
/// first toast and the tray and window are only touched by `bootstrap`, so a
/// second copy of the app that exits straight away does no real work.
Future<PlatformServices> createWindowsPlatformServices() async {
  return PlatformServices(
    audio: AudioplayersOutput(),
    notifier: FlutterLocalNotifier(),
    window: WindowManagerHost(),
    tray: TrayManagerHost(),
    autostart: RegistryAutostart(),
    fileDialogs: const FileSelectorDialogs(),
    paths: await PathProviderPaths.resolve(),
    power: WindowsPowerEvents(),
    singleInstance: WindowsSingleInstanceGuard(),
    assetLoader: rootBundle.loadString,
    deviceLocation: const GeolocatorDeviceLocation(),
    linkOpener: const ShellLinkOpener(),
    placeSearch: OnlinePlaceSearch(),
  );
}
