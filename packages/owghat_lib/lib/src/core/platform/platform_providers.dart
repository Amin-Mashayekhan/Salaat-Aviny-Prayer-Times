import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/platform/app_notifier.dart';
import 'package:owghat_lib/src/core/platform/audio_output.dart';
import 'package:owghat_lib/src/core/platform/autostart_service.dart';
import 'package:owghat_lib/src/core/platform/device_location.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_app_notifier.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_device_location.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_link_opener.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_place_search.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_simple_services.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_tray_host.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_window_host.dart';
import 'package:owghat_lib/src/core/platform/file_dialogs.dart';
import 'package:owghat_lib/src/core/platform/launch_args.dart';
import 'package:owghat_lib/src/core/platform/link_opener.dart';
import 'package:owghat_lib/src/core/platform/notice_scheduler.dart';
import 'package:owghat_lib/src/core/platform/place_search.dart';
import 'package:owghat_lib/src/core/platform/platform_capabilities.dart';
import 'package:owghat_lib/src/core/platform/platform_paths.dart';
import 'package:owghat_lib/src/core/platform/single_instance.dart';
import 'package:owghat_lib/src/core/platform/tray_host.dart';
import 'package:owghat_lib/src/core/platform/window_host.dart';
import 'package:owghat_lib/src/core/storage/state_file.dart';

// The defaults below are in-memory fakes so that widget tests and other
// features can read these providers without any setup; `bootstrap` overrides
// every one of them with the real platform implementation.

/// Audio output. Overridden by `bootstrap`.
final audioOutputProvider = Provider<AudioOutput>((ref) => FakeAudioOutput());

/// Toast notifications. Overridden by `bootstrap`.
final appNotifierProvider = Provider<AppNotifier>((ref) => FakeAppNotifier());

/// The main window. Overridden by `bootstrap`.
final windowHostProvider = Provider<WindowHost>((ref) => FakeWindowHost());

/// The tray icon. Overridden by `bootstrap`.
final trayHostProvider = Provider<TrayHost>((ref) => FakeTrayHost());

/// Start-with-Windows. Overridden by `bootstrap`.
final autostartServiceProvider = Provider<AutostartService>(
  (ref) => FakeAutostartService(),
);

/// Reads the device position on request. Overridden by `bootstrap`.
final deviceLocationProvider = Provider<DeviceLocationService>(
  (ref) => FakeDeviceLocation(),
);

/// Opens web and mail links. Overridden by `bootstrap`.
final linkOpenerProvider = Provider<LinkOpener>((ref) => FakeLinkOpener());

/// Searches places by name. Overridden by `bootstrap`.
final placeSearchProvider = Provider<PlaceSearchService>(
  (ref) => FakePlaceSearch(),
);

/// What the platform can do. Overridden by `bootstrap`; the desktop by
/// default.
final platformCapabilitiesProvider = Provider<PlatformCapabilities>(
  (ref) => PlatformCapabilities.desktop,
);

/// Plans notifications with the operating system. Overridden by `bootstrap`.
final noticeSchedulerProvider = Provider<NoticeScheduler>(
  (ref) => const NoNoticeScheduler(),
);

/// File pickers. Overridden by `bootstrap`.
final fileDialogsProvider = Provider<FileDialogs>((ref) => FakeFileDialogs());

/// The single-instance guard. Overridden by `bootstrap`.
final singleInstanceProvider = Provider<SingleInstance>(
  (ref) => FakeSingleInstance(),
);

/// Application folders. Overridden by `bootstrap`.
final platformPathsProvider = Provider<PlatformPaths>(
  (ref) => throw StateError('platformPathsProvider was not overridden'),
);

/// The non-user state file (`state.json`). Overridden by `bootstrap`.
final stateFileProvider = Provider<StateFile>(
  (ref) => throw StateError('stateFileProvider was not overridden'),
);

/// The command line this process was started with. Overridden by
/// `bootstrap`.
final launchArgsProvider = Provider<LaunchArgs>((ref) => const LaunchArgs());

/// Arguments of later launches that a second copy forwarded to this one
/// (for example `--wake <id>`), parsed.
final forwardedLaunchArgsProvider = StreamProvider<LaunchArgs>(
  (ref) =>
      ref.watch(singleInstanceProvider).forwardedArgs.map(LaunchArgs.parse),
);
