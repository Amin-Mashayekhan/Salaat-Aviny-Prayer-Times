import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/core/platform/app_notifier.dart';

/// What a planned notification is for.
enum PlannedNoticeKind {
  /// The azan of a prayer.
  azan,

  /// A reminder some minutes before the azan.
  reminder,
}

/// A notification the operating system should show at [instantUtc].
@immutable
class PlannedNotice {
  /// Creates the notice.
  const PlannedNotice({
    required this.kind,
    required this.instantUtc,
    required this.spec,
    required this.sound,
  });

  /// Azan or reminder.
  final PlannedNoticeKind kind;

  /// When to show it.
  final DateTime instantUtc;

  /// The texts.
  final NotificationSpec spec;

  /// Whether it sounds (the azan, or the reminder chime); false while the
  /// azan is muted or the chime is off.
  final bool sound;

  @override
  bool operator ==(Object other) =>
      other is PlannedNotice &&
      other.kind == kind &&
      other.instantUtc == instantUtc &&
      other.spec == spec &&
      other.sound == sound;

  @override
  int get hashCode => Object.hash(kind, instantUtc, spec, sound);

  @override
  String toString() =>
      'PlannedNotice(${kind.name} at $instantUtc, sound: $sound)';
}

/// Hands the coming azan and reminder notifications to the operating system,
/// which shows them on time even when the app is not running (Android, iOS).
abstract interface class NoticeScheduler {
  /// Replaces everything planned before with [notices].
  Future<void> replaceAll(List<PlannedNotice> notices);

  /// Asks the person, where the platform needs it, for permission to show
  /// notifications. Returns whether notifications may be shown.
  Future<bool> requestPermissions();

  /// Whether planned notifications come at their exact minute. On Android
  /// 12 and later this needs the "Alarms & reminders" permission; without it
  /// the system may deliver them some minutes late.
  Future<bool> exactTimingAllowed();

  /// Opens the system page where the person can allow exact timing.
  Future<void> requestExactTiming();
}

/// The scheduler of a platform where the app does the timing itself.
class NoNoticeScheduler implements NoticeScheduler {
  /// Creates it.
  const NoNoticeScheduler();

  @override
  Future<void> replaceAll(List<PlannedNotice> notices) async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> exactTimingAllowed() async => true;

  @override
  Future<void> requestExactTiming() async {}
}
