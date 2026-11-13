import 'dart:io';

import 'package:owghat_lib/src/core/platform/app_notifier.dart';
import 'package:owghat_lib/src/core/platform/audio_output.dart';
import 'package:owghat_lib/src/core/platform/autostart_service.dart';
import 'package:owghat_lib/src/core/platform/device_location.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_app_notifier.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_device_location.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_link_opener.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_notice_scheduler.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_place_search.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_simple_services.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_tray_host.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_window_host.dart';
import 'package:owghat_lib/src/core/platform/file_dialogs.dart';
import 'package:owghat_lib/src/core/platform/link_opener.dart';
import 'package:owghat_lib/src/core/platform/notice_scheduler.dart';
import 'package:owghat_lib/src/core/platform/place_search.dart';
import 'package:owghat_lib/src/core/platform/platform_capabilities.dart';
import 'package:owghat_lib/src/core/platform/platform_paths.dart';
import 'package:owghat_lib/src/core/platform/power_events.dart';
import 'package:owghat_lib/src/core/platform/single_instance.dart';
import 'package:owghat_lib/src/core/platform/tray_host.dart';
import 'package:owghat_lib/src/core/platform/window_host.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';

/// Everything the library needs from the operating system, handed to
/// `bootstrap` by the runner (the Windows implementations live in the app
/// package; tests pass [PlatformServices.fake]).
class PlatformServices {
  /// Creates the bundle.
  const PlatformServices({
    required this.audio,
    required this.notifier,
    required this.window,
    required this.tray,
    required this.autostart,
    required this.fileDialogs,
    required this.paths,
    required this.power,
    required this.singleInstance,
    required this.assetLoader,
    this.deviceLocation = const UnsupportedDeviceLocation(),
    this.linkOpener = const UnsupportedLinkOpener(),
    this.placeSearch = const UnsupportedPlaceSearch(),
    this.capabilities = PlatformCapabilities.desktop,
    this.noticeScheduler = const NoNoticeScheduler(),
  });

  /// A bundle of in-memory fakes. [supportDir] defaults to a new temporary
  /// folder.
  factory PlatformServices.fake({
    Directory? supportDir,
    AssetTextLoader? assetLoader,
    PowerEvents power = const NoPowerEvents(),
    AudioOutput? audio,
    AppNotifier? notifier,
    WindowHost? window,
    TrayHost? tray,
    AutostartService? autostart,
    SingleInstance? singleInstance,
    DeviceLocationService? deviceLocation,
    LinkOpener? linkOpener,
    PlaceSearchService? placeSearch,
    PlatformCapabilities capabilities = PlatformCapabilities.desktop,
    NoticeScheduler? noticeScheduler,
  }) => PlatformServices(
    audio: audio ?? FakeAudioOutput(),
    notifier: notifier ?? FakeAppNotifier(),
    window: window ?? FakeWindowHost(),
    tray: tray ?? FakeTrayHost(),
    autostart: autostart ?? FakeAutostartService(),
    fileDialogs: FakeFileDialogs(),
    paths: PlatformPaths(supportDir ?? Directory.systemTemp.createTempSync()),
    power: power,
    singleInstance: singleInstance ?? FakeSingleInstance(),
    assetLoader: assetLoader ?? _missingAsset,
    deviceLocation: deviceLocation ?? FakeDeviceLocation(),
    linkOpener: linkOpener ?? FakeLinkOpener(),
    placeSearch: placeSearch ?? FakePlaceSearch(),
    capabilities: capabilities,
    noticeScheduler: noticeScheduler ?? FakeNoticeScheduler(),
  );

  static Future<String> _missingAsset(String path) =>
      Future.error(StateError('No asset loader: $path'));

  /// Audio playback.
  final AudioOutput audio;

  /// Toast notifications.
  final AppNotifier notifier;

  /// The main window.
  final WindowHost window;

  /// The tray icon.
  final TrayHost tray;

  /// Start with Windows.
  final AutostartService autostart;

  /// File pickers.
  final FileDialogs fileDialogs;

  /// Application folders.
  final PlatformPaths paths;

  /// Sleep, resume and clock-change events.
  final PowerEvents power;

  /// The single-instance guard.
  final SingleInstance singleInstance;

  /// Loads bundled text assets (the city database).
  final AssetTextLoader assetLoader;

  /// Reads the device position when the user asks (qibla map).
  final DeviceLocationService deviceLocation;

  /// Opens web and mail links (About page).
  final LinkOpener linkOpener;

  /// Searches places by name on the internet (city choice, qibla map).
  final PlaceSearchService placeSearch;

  /// What this platform can do (tray, autostart, wake timers, OS-scheduled
  /// notifications).
  final PlatformCapabilities capabilities;

  /// Plans notifications with the operating system where it schedules them.
  final NoticeScheduler noticeScheduler;
}
