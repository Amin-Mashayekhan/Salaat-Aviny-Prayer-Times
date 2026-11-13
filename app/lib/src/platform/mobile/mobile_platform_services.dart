import 'package:flutter/services.dart' show rootBundle;
import 'package:owghat/src/platform/audioplayers_output.dart';
import 'package:owghat/src/platform/file_selector_dialogs.dart';
import 'package:owghat/src/platform/geolocator_device_location.dart';
import 'package:owghat/src/platform/headless_hosts.dart';
import 'package:owghat/src/platform/mobile/mobile_notifications.dart';
import 'package:owghat/src/platform/path_provider_paths.dart';
import 'package:owghat/src/platform/url_link_opener.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// Builds the platform services of a phone (Android; iOS later). There is
/// no window, tray, autostart or wake timer; the system schedules the azan
/// and reminder notifications.
Future<PlatformServices> createMobilePlatformServices() async {
  final notifications = MobileNotifications();
  return PlatformServices(
    audio: AudioplayersOutput(),
    notifier: notifications,
    window: const SystemManagedWindow(),
    tray: const NoTray(),
    autostart: const NoAutostart(),
    fileDialogs: const FileSelectorDialogs(),
    paths: await PathProviderPaths.resolve(),
    power: const NoPowerEvents(),
    singleInstance: const SystemSingleInstance(),
    assetLoader: rootBundle.loadString,
    deviceLocation: const GeolocatorDeviceLocation(),
    linkOpener: const UrlLinkOpener(),
    placeSearch: OnlinePlaceSearch(),
    capabilities: PlatformCapabilities.mobile,
    noticeScheduler: notifications,
  );
}
