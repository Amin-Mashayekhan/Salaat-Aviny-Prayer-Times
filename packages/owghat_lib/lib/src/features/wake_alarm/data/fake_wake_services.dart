import 'dart:async';

import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_services.dart';

/// In-memory [WakeTimerService] that records what it is asked to do. Used by
/// tests and as a stand-in until the Windows service is wired.
class FakeWakeTimerService implements WakeTimerService {
  /// Creates the fake with the capability it will report.
  FakeWakeTimerService({
    this.capability = const WakeCapability(
      taskCreationOk: true,
      wakeTimersOnAc: WakeTimerPolicy.enabled,
      wakeTimersOnBattery: WakeTimerPolicy.enabled,
      inProcessTimerOk: true,
    ),
  });

  /// What [probe] returns.
  WakeCapability capability;

  /// Wake requests currently armed: id to instant.
  final Map<String, DateTime> scheduled = {};

  /// Every call in order, for example `schedule:wake-1`, `cancel:wake-1`.
  final List<String> log = [];

  /// How many times [probe] ran.
  int probeCalls = 0;

  /// Whether the machine is currently held awake.
  bool awakeHeld = false;

  /// The duration passed to the latest [keepAwake].
  Duration? lastAwakeDuration;

  /// How many times [openPowerOptions] was called.
  int openCalls = 0;

  /// If set, [scheduleWake] throws it.
  Exception? failScheduleWith;

  /// If set, [cancel] throws it.
  Exception? failCancelWith;

  /// Wake requests that exist "at OS level" before anything is scheduled
  /// (left over from an earlier run).
  final Set<String> leftOver = {};

  @override
  Future<WakeCapability> probe() async {
    probeCalls++;
    log.add('probe');
    return capability;
  }

  @override
  Future<void> scheduleWake(DateTime utc, String id) async {
    log.add('schedule:$id');
    final failure = failScheduleWith;
    if (failure != null) throw failure;
    scheduled[id] = utc;
  }

  @override
  Future<void> cancel(String id) async {
    log.add('cancel:$id');
    final failure = failCancelWith;
    if (failure != null) throw failure;
    scheduled.remove(id);
    leftOver.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    log.add('cancelAll');
    scheduled.clear();
    leftOver.clear();
  }

  @override
  Future<Set<String>> pendingIds() async => {...scheduled.keys, ...leftOver};

  @override
  Future<void> keepAwake(Duration? maxDuration) async {
    log.add('keepAwake');
    awakeHeld = true;
    lastAwakeDuration = maxDuration;
  }

  @override
  Future<void> releaseAwake() async {
    log.add('releaseAwake');
    awakeHeld = false;
  }

  @override
  Future<bool> openPowerOptions() async {
    openCalls++;
    return true;
  }
}

/// Records sleep and hibernate requests.
class FakePowerControl implements PowerControl {
  /// Requests in order: `sleep` or `hibernate`.
  final List<String> calls = [];

  /// What the next request returns.
  PowerResult result = PowerResult.ok;

  @override
  Future<PowerResult> sleep() async {
    calls.add('sleep');
    return result;
  }

  @override
  Future<PowerResult> hibernate() async {
    calls.add('hibernate');
    return result;
  }
}

/// A sound player the test finishes by hand with [finish].
class FakeAlarmSoundPlayer implements AlarmSoundPlayer {
  /// What was played, in order.
  final List<SoundRef> played = [];

  /// Volumes of the plays.
  final List<double> volumes = [];

  /// How many times [stop] was called.
  int stops = 0;

  /// The next this many plays throw instead of playing.
  int failPlays = 0;

  /// Whether a sound is currently playing.
  bool get playing => _pending != null && !_pending!.isCompleted;

  Completer<void>? _pending;

  @override
  Future<void> play(SoundRef sound, {required double volume}) {
    played.add(sound);
    volumes.add(volume);
    if (failPlays > 0) {
      failPlays--;
      return Future<void>.error(StateError('cannot play $sound'));
    }
    final completer = Completer<void>();
    _pending = completer;
    return completer.future;
  }

  /// Ends the current sound as if it played to the end.
  void finish() {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) pending.complete();
  }

  @override
  Future<void> stop() async {
    stops++;
    finish();
  }
}
