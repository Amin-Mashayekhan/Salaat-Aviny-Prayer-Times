import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';

/// Why a suspend countdown is running.
enum WakeCountdownKind {
  /// The user pressed "Sleep now" (5 seconds).
  sleepNow,

  /// The user pressed "Hibernate now" (5 seconds).
  hibernateNow,

  /// An alarm finished and its `afterSound` action is pending (30 seconds).
  afterAlarm,
}

/// The on-screen, cancellable countdown before the PC is put to sleep or
/// hibernated. The UI shows it whenever [active] is true and offers "Cancel",
/// which calls `WakeAlarmController.cancelCountdown`.
@immutable
class WakeCountdownState {
  /// Creates a state.
  const WakeCountdownState({
    required this.kind,
    required this.action,
    required this.total,
    required this.remaining,
    this.alarmId,
  });

  /// No countdown is running.
  static const idle = WakeCountdownState(
    kind: WakeCountdownKind.sleepNow,
    action: AfterSound.nothing,
    total: Duration.zero,
    remaining: Duration.zero,
  );

  /// Why it runs.
  final WakeCountdownKind kind;

  /// What happens when it reaches zero: `sleep` or `hibernate`.
  final AfterSound action;

  /// Full length.
  final Duration total;

  /// Time left.
  final Duration remaining;

  /// The alarm that started it, for [WakeCountdownKind.afterAlarm].
  final String? alarmId;

  /// Whether a countdown is running.
  bool get active => action != AfterSound.nothing;

  /// Whether the action is hibernation.
  bool get isHibernate => action == AfterSound.hibernate;

  /// Copy with a new remaining time.
  WakeCountdownState withRemaining(Duration value) => WakeCountdownState(
    kind: kind,
    action: action,
    total: total,
    remaining: value,
    alarmId: alarmId,
  );

  @override
  bool operator ==(Object other) =>
      other is WakeCountdownState &&
      other.kind == kind &&
      other.action == action &&
      other.total == total &&
      other.remaining == remaining &&
      other.alarmId == alarmId;

  @override
  int get hashCode => Object.hash(kind, action, total, remaining, alarmId);
}
