import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/app/app.dart';
import 'package:owghat_lib/src/app/startup_info.dart';
import 'package:owghat_lib/src/core/logging/file_log_sink.dart';
import 'package:owghat_lib/src/core/platform/launch_args.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/platform/platform_services.dart';
import 'package:owghat_lib/src/core/storage/json_file_store.dart';
import 'package:owghat_lib/src/core/storage/state_file.dart';
import 'package:owghat_lib/src/core/time/tz_database.dart';
import 'package:owghat_lib/src/features/diagnostics/presentation/about_diagnostics_section.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/notifications/application/notification_actions.dart';
import 'package:owghat_lib/src/features/scheduler/application/app_schedule_dispatcher.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/scheduler/application/wake_alarm_hook.dart';
import 'package:owghat_lib/src/features/scheduler/data/file_handled_events_store.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_reset_notice.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/data/settings_repository.dart';
import 'package:owghat_lib/src/features/tray/application/tray_controller.dart';
import 'package:owghat_lib/src/features/window/application/autostart_controller.dart';
import 'package:owghat_lib/src/features/window/application/window_controller.dart';
import 'package:owghat_lib/src/features/window/domain/window_policy.dart';
import 'package:owghat_lib/wake_alarm.dart';

final Logger _log = Logger('bootstrap');

/// Everything that is up and running after [prepareApp]: the provider
/// container (holding the running schedule engine) and what start-up found.
class AppRuntime {
  /// Creates the runtime.
  AppRuntime({required this.container, required this.args, required this.info});

  /// The provider container of the whole app.
  final ProviderContainer container;

  /// The command line of this process.
  final LaunchArgs args;

  /// What start-up found (first run, reset settings).
  final StartupInfo info;
}

/// Starts the application.
///
/// [services] holds the platform implementations (Windows plugins in the app
/// package). [extraOverrides] lets the runner add providers of its own, such
/// as the wake-up feature. Startup order follows `docs/03-ARCHITECTURE.md`
/// section 7: single-instance check, load settings and state, build the
/// container, start the schedule engine, then tray and window, and only then
/// the UI.
Future<void> bootstrap(
  List<String> args,
  PlatformServices services, {
  List<Override> extraOverrides = const [],
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  _initLogging(services.paths.logDir);
  FlutterError.onError = (details) {
    _log.severe('Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    _log.severe('Uncaught error', error, stack);
    return true;
  };

  final primary = await services.singleInstance.ensure(args);
  if (!primary) return; // The first copy was told; this process ends.

  final runtime = await prepareApp(
    args: LaunchArgs.parse(args),
    services: services,
    extraOverrides: extraOverrides,
  );
  runApp(
    UncontrolledProviderScope(
      container: runtime.container,
      child: const OwghatApp(),
    ),
  );
}

/// Loads everything, builds the container, starts the schedule engine, the
/// tray, the window and autostart, and returns the running [AppRuntime].
///
/// This is [bootstrap] without `runApp`, so it runs in tests with fake
/// [services].
Future<AppRuntime> prepareApp({
  required LaunchArgs args,
  required PlatformServices services,
  List<Override> extraOverrides = const [],
}) async {
  ensureTimeZonesInitialized();

  // Settings and state: a missing or broken file never stops start-up.
  final settingsRepository = SettingsRepository(
    JsonFileStore(services.paths.settingsFile),
  );
  final loaded = await settingsRepository.load();
  final stateFile = await StateFile.load(
    JsonFileStore(services.paths.stateFile),
  );
  final locations = await LocationRepository.load(services.assetLoader);

  final container = ProviderContainer(
    overrides: [
      initialSettingsProvider.overrideWithValue(loaded.settings),
      settingsRepositoryProvider.overrideWithValue(settingsRepository),
      locationRepositoryProvider.overrideWithValue(locations),
      stateFileProvider.overrideWithValue(stateFile),
      handledEventsStoreProvider.overrideWithValue(
        FileHandledEventsStore(stateFile),
      ),
      eventDispatcherProvider.overrideWith(AppScheduleDispatcher.new),
      powerEventsProvider.overrideWithValue(services.power),
      audioOutputProvider.overrideWithValue(services.audio),
      deviceLocationProvider.overrideWithValue(services.deviceLocation),
      appNotifierProvider.overrideWithValue(services.notifier),
      windowHostProvider.overrideWithValue(services.window),
      trayHostProvider.overrideWithValue(services.tray),
      autostartServiceProvider.overrideWithValue(services.autostart),
      fileDialogsProvider.overrideWithValue(services.fileDialogs),
      singleInstanceProvider.overrideWithValue(services.singleInstance),
      platformPathsProvider.overrideWithValue(services.paths),
      launchArgsProvider.overrideWithValue(args),
      settingsWasResetProvider.overrideWithValue(loaded.wasReset),
      startupInfoProvider.overrideWithValue(
        StartupInfo(
          firstRun: loaded.firstRun,
          settingsWereReset: loaded.wasReset,
        ),
      ),
      aboutSectionBuilderProvider.overrideWithValue(
        (context) => const AboutDiagnosticsSection(),
      ),
      alarmSoundPlayerProvider.overrideWith(
        (ref) => AudioOutputAlarmSoundPlayer(ref.read(audioOutputProvider)),
      ),
      wakeAlarmHandlerProvider.overrideWith(
        (ref) => ref.watch(wakeAlarmEventHandlerProvider),
      ),
      ...extraOverrides,
    ],
  );

  // The schedule engine lives in the container, not in a widget, so it keeps
  // running with the window hidden. It starts before any UI.
  final engine = container.read(scheduleEngineProvider);
  final tray = container.read(trayControllerProvider);
  final window = container.read(windowControllerProvider);
  final autostart = container.read(autostartControllerProvider);

  await tray.start();
  await window.start(
    startHidden: startsHidden(
      minimizedArgument: args.minimized,
      startMinimizedSetting: loaded.settings.window.startMinimized,
    ),
  );
  unawaited(autostart.start());
  container.read(notificationActionRouterProvider);
  // Starting the wake controller syncs the OS wake requests with the saved
  // alarms; a --wake <id> launch tells it which alarm woke the PC.
  final wakeController = container.read(wakeAlarmControllerProvider.notifier);
  final wakeId = args.wakeAlarmId;
  if (wakeId != null) unawaited(wakeController.noteWakeLaunch(wakeId));
  _log.info('Started: ${engine.events.length} events scheduled');

  return AppRuntime(
    container: container,
    args: args,
    info: StartupInfo(
      firstRun: loaded.firstRun,
      settingsWereReset: loaded.wasReset,
    ),
  );
}

void _initLogging(Directory logDirectory) {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  // Until now nothing was written to disk even though the About page shows a
  // log folder, so problems seen on a user's PC could not be investigated.
  final sink = FileLogSink(logDirectory);
  Logger.root.onRecord.listen((record) {
    sink.write(record);
    if (!kDebugMode) return;
    final error = record.error == null ? '' : ' ${record.error}';
    debugPrint(
      '[${record.level.name}] ${record.loggerName}: ${record.message}$error',
    );
  });
}
