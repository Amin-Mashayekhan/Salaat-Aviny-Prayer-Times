import 'package:flutter/foundation.dart';

/// The Windows "Allow wake timers" setting for one power source.
enum WakeTimerPolicy {
  /// Wake timers are switched off: nothing can wake the PC.
  disabled,

  /// Wake timers are allowed.
  enabled,

  /// Only timers Windows marks as important may wake the PC, which usually
  /// excludes ours.
  importantOnly,

  /// The setting could not be read.
  unknown,
}

/// A plain reason why a wake-up alarm may not wake the PC. The UI turns each
/// into a localised sentence; nothing here is user-visible text.
enum WakeIssue {
  /// The Task Scheduler task could not be created, so the alarm only works
  /// while the app is running.
  taskCreationFailed,

  /// Wake timers are off while on mains power.
  wakeTimersDisabledOnAc,

  /// Wake timers are off while on battery.
  wakeTimersDisabledOnBattery,

  /// Wake timers are limited to "important" ones.
  wakeTimersImportantOnly,

  /// The power setting could not be read, so we cannot say.
  powerSettingUnknown,

  /// The in-process timer could not be created.
  inProcessTimerUnavailable,

  /// This PC uses Modern Standby (S0), where waking at a set time is often
  /// unreliable.
  modernStandby,
}

/// What this PC allows, as found by `WakeTimerService.probe`.
@immutable
class WakeCapability {
  /// Creates a result.
  const WakeCapability({
    this.taskCreationOk,
    this.wakeTimersOnAc = WakeTimerPolicy.unknown,
    this.wakeTimersOnBattery = WakeTimerPolicy.unknown,
    this.inProcessTimerOk = false,
    this.modernStandby,
    this.lastError,
  });

  /// A platform without wake support (non-Windows, or not wired yet).
  static const unsupported = WakeCapability(
    taskCreationOk: false,
    lastError: 'Wake timers are not supported on this platform.',
  );

  /// Whether a Task Scheduler task could be created for the current user
  /// without elevation; null if not tested.
  final bool? taskCreationOk;

  /// "Allow wake timers" while plugged in.
  final WakeTimerPolicy wakeTimersOnAc;

  /// "Allow wake timers" while on battery.
  final WakeTimerPolicy wakeTimersOnBattery;

  /// Whether the in-process waitable timer could be created.
  final bool inProcessTimerOk;

  /// Whether this PC uses Modern Standby; null if it could not be told.
  final bool? modernStandby;

  /// Text of the most recent failure, for the diagnostics page and logs.
  final String? lastError;

  /// Everything that may keep an alarm from waking the PC, most important
  /// first. Empty means "should work" (still unverified without a real test).
  List<WakeIssue> get issues {
    final result = <WakeIssue>[];
    if (taskCreationOk == false) result.add(WakeIssue.taskCreationFailed);
    if (!inProcessTimerOk && taskCreationOk != true) {
      result.add(WakeIssue.inProcessTimerUnavailable);
    }
    void policy(WakeTimerPolicy value, WakeIssue disabled) {
      switch (value) {
        case WakeTimerPolicy.disabled:
          result.add(disabled);
        case WakeTimerPolicy.importantOnly:
          if (!result.contains(WakeIssue.wakeTimersImportantOnly)) {
            result.add(WakeIssue.wakeTimersImportantOnly);
          }
        case WakeTimerPolicy.unknown:
          if (!result.contains(WakeIssue.powerSettingUnknown)) {
            result.add(WakeIssue.powerSettingUnknown);
          }
        case WakeTimerPolicy.enabled:
          break;
      }
    }

    policy(wakeTimersOnAc, WakeIssue.wakeTimersDisabledOnAc);
    policy(wakeTimersOnBattery, WakeIssue.wakeTimersDisabledOnBattery);
    if (modernStandby ?? false) result.add(WakeIssue.modernStandby);
    return result;
  }

  /// Whether at least one wake mechanism is available and wake timers are
  /// allowed on at least one power source. [issues] says what is left in the
  /// way (for example battery only).
  bool get canWake {
    final mechanism = taskCreationOk == true || inProcessTimerOk;
    if (!mechanism) return false;
    return wakeTimersOnAc == WakeTimerPolicy.enabled ||
        wakeTimersOnBattery == WakeTimerPolicy.enabled;
  }

  @override
  bool operator ==(Object other) =>
      other is WakeCapability &&
      other.taskCreationOk == taskCreationOk &&
      other.wakeTimersOnAc == wakeTimersOnAc &&
      other.wakeTimersOnBattery == wakeTimersOnBattery &&
      other.inProcessTimerOk == inProcessTimerOk &&
      other.modernStandby == modernStandby &&
      other.lastError == lastError;

  @override
  int get hashCode => Object.hash(
    taskCreationOk,
    wakeTimersOnAc,
    wakeTimersOnBattery,
    inProcessTimerOk,
    modernStandby,
    lastError,
  );

  @override
  String toString() =>
      'WakeCapability(task: $taskCreationOk, ac: $wakeTimersOnAc, '
      'battery: $wakeTimersOnBattery, inProcess: $inProcessTimerOk, '
      'modernStandby: $modernStandby, error: $lastError)';
}
