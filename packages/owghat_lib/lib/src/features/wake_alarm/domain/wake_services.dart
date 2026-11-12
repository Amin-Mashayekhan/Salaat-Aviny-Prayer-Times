import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';

/// A wake request that could not be made.
class WakeServiceException implements Exception {
  /// Creates the exception.
  const WakeServiceException(this.message);

  /// What went wrong, for logs and diagnostics (not shown as UI text).
  final String message;

  @override
  String toString() => 'WakeServiceException: $message';
}

/// Asks the OS to wake the PC at a given instant and keeps it awake while
/// an alarm runs. The Windows implementation lives in
/// `app/lib/src/platform/wake/`.
///
/// None of the methods may change a Windows power setting.
abstract interface class WakeTimerService {
  /// Finds out what this PC allows. Read-only apart from creating and
  /// removing one throw-away test task.
  Future<WakeCapability> probe();

  /// Makes the PC wake at [utc]; [id] names the wake request (replaces an
  /// earlier request with the same id).
  ///
  /// Throws [WakeServiceException] when no mechanism could be armed.
  Future<void> scheduleWake(DateTime utc, String id);

  /// Removes the wake request [id]. Not an error when there is none.
  Future<void> cancel(String id);

  /// Removes every wake request of this app.
  Future<void> cancelAll();

  /// Ids of the wake requests that currently exist at OS level (including
  /// ones left by an earlier run).
  Future<Set<String>> pendingIds();

  /// Prevents the system from sleeping and the display from turning off.
  /// [maxDuration] is the longest the caller intends to hold it (null: until
  /// [releaseAwake]). The caller always releases explicitly.
  Future<void> keepAwake(Duration? maxDuration);

  /// Ends the hold started by [keepAwake].
  Future<void> releaseAwake();

  /// Opens the Windows power options so the user can allow wake timers.
  /// Returns false if it could not be opened.
  Future<bool> openPowerOptions();
}

/// How a sleep or hibernate request ended.
enum PowerResult {
  /// The request was accepted (the PC may already have slept and resumed).
  ok,

  /// Windows refused (privilege, policy).
  refused,

  /// The action does not exist on this PC (hibernation is switched off).
  unavailable,
}

/// Puts the PC to sleep or hibernates it.
abstract interface class PowerControl {
  /// Sleep (suspend to RAM).
  Future<PowerResult> sleep();

  /// Hibernate (suspend to disk).
  Future<PowerResult> hibernate();
}

/// Plays the sound of a wake-up alarm.
///
/// The Windows build binds this to the app audio output. [play] completes
/// when the sound has ended or [stop] was called, and throws when the sound
/// cannot be played (missing file, no device).
abstract interface class AlarmSoundPlayer {
  /// Plays [sound] at [volume] (0 to 1).
  Future<void> play(SoundRef sound, {required double volume});

  /// Stops the sound; completes the pending [play].
  Future<void> stop();
}

/// A [WakeTimerService] for platforms without wake support. Probing says so
/// and nothing is scheduled.
class NoWakeTimerService implements WakeTimerService {
  /// Creates the service.
  const NoWakeTimerService();

  @override
  Future<WakeCapability> probe() async => WakeCapability.unsupported;

  @override
  Future<void> scheduleWake(DateTime utc, String id) async {}

  @override
  Future<void> cancel(String id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<Set<String>> pendingIds() async => const {};

  @override
  Future<void> keepAwake(Duration? maxDuration) async {}

  @override
  Future<void> releaseAwake() async {}

  @override
  Future<bool> openPowerOptions() async => false;
}

/// A [PowerControl] that does nothing.
class NoPowerControl implements PowerControl {
  /// Creates the control.
  const NoPowerControl();

  @override
  Future<PowerResult> sleep() async => PowerResult.unavailable;

  @override
  Future<PowerResult> hibernate() async => PowerResult.unavailable;
}

/// An [AlarmSoundPlayer] that plays nothing and ends at once.
class NoAlarmSoundPlayer implements AlarmSoundPlayer {
  /// Creates the player.
  const NoAlarmSoundPlayer();

  @override
  Future<void> play(SoundRef sound, {required double volume}) async {}

  @override
  Future<void> stop() async {}
}
