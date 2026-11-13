import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:owghat/src/platform/audioplayers_output.dart';
import 'package:owghat/src/platform/file_selector_dialogs.dart';
import 'package:owghat/src/platform/flutter_local_notifier.dart';
import 'package:owghat/src/platform/geolocator_device_location.dart';
import 'package:owghat/src/platform/headless_hosts.dart';
import 'package:owghat/src/platform/path_provider_paths.dart';
import 'package:owghat/src/platform/tray_manager_host.dart';
import 'package:owghat/src/platform/url_link_opener.dart';
import 'package:owghat/src/platform/window_manager_host.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// What Linux and macOS can do: a window and a tray icon like Windows, but
/// no start-with-the-system and no waking from sleep yet (those use Windows
/// facilities); the app sounds the azan itself while it runs.
const PlatformCapabilities otherDesktopCapabilities = PlatformCapabilities(
  autostart: false,
  wakeTimers: false,
);

/// Builds the platform services of Linux and macOS.
Future<PlatformServices> createOtherDesktopPlatformServices() async {
  return PlatformServices(
    audio: AudioplayersOutput(),
    notifier: FlutterLocalNotifier(),
    window: WindowManagerHost(),
    tray: TrayManagerHost(),
    autostart: const NoAutostart(),
    fileDialogs: const FileSelectorDialogs(),
    paths: await PathProviderPaths.resolve(),
    power: const NoPowerEvents(),
    singleInstance: const SystemSingleInstance(),
    assetLoader: rootBundle.loadString,
    // geolocator has no Linux backend; macOS asks through CoreLocation.
    deviceLocation: Platform.isMacOS
        ? const GeolocatorDeviceLocation()
        : const UnsupportedDeviceLocation(),
    linkOpener: const UrlLinkOpener(),
    placeSearch: OnlinePlaceSearch(),
    capabilities: otherDesktopCapabilities,
  );
}
