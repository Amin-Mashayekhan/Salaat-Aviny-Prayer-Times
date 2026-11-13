import 'dart:async';
import 'dart:io' show Directory;

import 'package:flutter/services.dart' show rootBundle;
import 'package:owghat/src/platform/audioplayers_output.dart';
import 'package:owghat/src/platform/file_selector_dialogs.dart';
import 'package:owghat/src/platform/geolocator_device_location.dart';
import 'package:owghat/src/platform/headless_hosts.dart';
import 'package:owghat/src/platform/url_link_opener.dart';
import 'package:owghat/src/platform/web/browser_json_store.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// The browser has no notification area the app can rely on while the tab is
/// in the background; the azan sounds in the page itself.
class PageOnlyNotifier implements AppNotifier {
  /// Creates it.
  const PageOnlyNotifier();

  @override
  Future<void> show(NotificationSpec spec) async {}

  @override
  Stream<NotificationAction> get actions => const Stream.empty();
}

/// Builds the platform services of the browser version. The settings live in
/// the browser's local storage; there is no window, tray, autostart, wake-up
/// timer, file access or network clock check, and the azan sounds only while
/// the page is open.
PlatformServices createWebPlatformServices() => PlatformServices(
  audio: AudioplayersOutput(),
  notifier: const PageOnlyNotifier(),
  window: const SystemManagedWindow(),
  tray: const NoTray(),
  autostart: const NoAutostart(),
  fileDialogs: const FileSelectorDialogs(),
  // Never used for files on the web (storeFor and fileLogging below).
  paths: PlatformPaths(Directory('salaat')),
  power: const NoPowerEvents(),
  singleInstance: const SystemSingleInstance(),
  assetLoader: rootBundle.loadString,
  deviceLocation: const GeolocatorDeviceLocation(),
  linkOpener: const UrlLinkOpener(),
  placeSearch: OnlinePlaceSearch(),
  capabilities: PlatformCapabilities.web,
  storeFor: BrowserJsonStore.new,
  fileLogging: false,
);
