import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override, ProviderListenable;
import 'package:owghat_lib/src/core/platform/fakes/fake_app_notifier.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_simple_services.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_tray_host.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_window_host.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/storage/json_file_store.dart';
import 'package:owghat_lib/src/core/storage/state_file.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/scheduler/application/app_schedule_dispatcher.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

/// A provider container wired to fake platform services and a settable
/// clock, for tests of the dispatcher, audio, tray and window logic.
///
/// Default time: 2026-11-11 05:00 in Tehran (UTC+03:30), i.e. 01:30 UTC.
/// Tehran that day: Fajr 05:10, Dhuhr 11:48, Maghrib 17:20.
class PlatformWorld {
  PlatformWorld(
    this.repo, {
    AppSettings? settings,
    DateTime? now,
    List<Override> extra = const [],
  }) : now = now ?? DateTime.utc(2026, 11, 10, 1, 30) {
    tempDir = Directory.systemTemp.createTempSync('owghat_test');
    stateFile = StateFile(
      JsonFileStore(File('${tempDir.path}${Platform.pathSeparator}state.json')),
      const {},
      debounce: const Duration(milliseconds: 1),
    );
    container = ProviderContainer(
      overrides: [
        locationRepositoryProvider.overrideWithValue(repo),
        initialSettingsProvider.overrideWithValue(
          settings ?? const AppSettings.defaults(),
        ),
        systemClockProvider.overrideWithValue(Clock(() => this.now)),
        eventDispatcherProvider.overrideWith(AppScheduleDispatcher.new),
        audioOutputProvider.overrideWithValue(audio),
        appNotifierProvider.overrideWithValue(notifier),
        windowHostProvider.overrideWithValue(window),
        trayHostProvider.overrideWithValue(tray),
        autostartServiceProvider.overrideWithValue(autostart),
        singleInstanceProvider.overrideWithValue(singleInstance),
        stateFileProvider.overrideWithValue(stateFile),
        ...extra,
      ],
    );
  }

  final LocationRepository repo;
  final FakeAudioOutput audio = FakeAudioOutput();
  final FakeAppNotifier notifier = FakeAppNotifier();
  final FakeWindowHost window = FakeWindowHost();
  final FakeTrayHost tray = FakeTrayHost();
  final FakeAutostartService autostart = FakeAutostartService();
  final FakeSingleInstance singleInstance = FakeSingleInstance();
  late final Directory tempDir;
  late final StateFile stateFile;
  late final ProviderContainer container;

  /// The current (UTC) time of the world; assign to move the clock.
  DateTime now;

  /// Tehran local time of day on 2026-11-11 as a UTC instant.
  static DateTime tehran(
    int hour,
    int minute, {
    int second = 0,
    int day = 11,
  }) => DateTime.utc(
    2026,
    11,
    day,
    hour,
    minute,
    second,
  ).subtract(const Duration(hours: 3, minutes: 30));

  T read<T>(ProviderListenable<T> provider) => container.read(provider);

  AppSettings get settings => container.read(settingsProvider);

  /// An azan event for [prayer] on 2026-11-11 at its Tehran time.
  ScheduledEvent azanEvent(
    Prayer prayer, {
    required int hour,
    required int minute,
  }) => ScheduledEvent(
    kind: EventKind.azan,
    instantUtc: tehran(hour, minute),
    date: CivilDate(2026, 11, 11),
    prayer: prayer,
  );

  /// A reminder event for [prayer] whose azan is at [hour]:[minute] Tehran
  /// and which fires [minutesBefore] minutes before it.
  ScheduledEvent reminderEvent(
    Prayer prayer, {
    required int hour,
    required int minute,
    int minutesBefore = 10,
  }) => ScheduledEvent(
    kind: EventKind.reminder,
    instantUtc: tehran(hour, minute).subtract(Duration(minutes: minutesBefore)),
    date: CivilDate(2026, 11, 11),
    prayer: prayer,
    relatedInstantUtc: tehran(hour, minute),
  );

  Future<void> dispose() async {
    container.dispose();
    await audio.dispose();
    await notifier.dispose();
    await window.dispose();
    await tray.close();
    await singleInstance.dispose();
    try {
      tempDir.deleteSync(recursive: true);
    } on Object {
      // Best effort: the temp folder may still be in use on Windows.
    }
  }
}

/// Lets queued microtasks and zero-delay timers run.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 5));

/// Polls until [condition] holds (or about two seconds pass).
Future<void> waitUntil(bool Function() condition) async {
  for (var i = 0; i < 200 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
