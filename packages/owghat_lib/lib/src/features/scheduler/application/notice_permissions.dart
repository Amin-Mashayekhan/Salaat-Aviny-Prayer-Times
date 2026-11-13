import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/scheduler/application/notice_planner.dart';

/// Whether the system lets the planned azan and reminder notifications
/// through, where the system plans them (phones). Null while unknown.
@immutable
class NoticePermissions {
  /// Creates the state.
  const NoticePermissions({this.notifications, this.exactTiming});

  /// Notifications may be shown.
  final bool? notifications;

  /// They come at their exact minute ("Alarms & reminders" on Android).
  final bool? exactTiming;

  @override
  bool operator ==(Object other) =>
      other is NoticePermissions &&
      other.notifications == notifications &&
      other.exactTiming == exactTiming;

  @override
  int get hashCode => Object.hash(notifications, exactTiming);
}

/// Asks for and follows the notification permissions. The questions are
/// asked once at start (the system itself asks only the first times) and again
/// only when the person presses "Allow" on a home banner; the answers are read
/// again whenever the app comes back to the front, because the person may
/// have changed them in the system settings.
class NoticePermissionsController extends Notifier<NoticePermissions> {
  AppLifecycleListener? _lifecycle;

  @override
  NoticePermissions build() {
    if (ref.watch(platformCapabilitiesProvider).osScheduledNotices) {
      _lifecycle = AppLifecycleListener(onResume: () => unawaited(refresh()));
      ref.onDispose(() => _lifecycle?.dispose());
    }
    return const NoticePermissions();
  }

  /// Asks for notifications (start of the app), then reads exact timing.
  Future<void> requestAtStart() async {
    if (!ref.read(platformCapabilitiesProvider).osScheduledNotices) return;
    final allowed = await ref
        .read(noticeSchedulerProvider)
        .requestPermissions();
    final exact = await ref.read(noticeSchedulerProvider).exactTimingAllowed();
    _set(NoticePermissions(notifications: allowed, exactTiming: exact));
  }

  /// "Allow" on the notifications banner.
  Future<void> askNotifications() => requestAtStart();

  /// "Allow" on the exact-timing banner: opens the system page; the answer is
  /// read when the app comes back.
  Future<void> askExactTiming() async {
    await ref.read(noticeSchedulerProvider).requestExactTiming();
    await refresh();
  }

  /// Reads the exact-timing answer again (notifications are re-read only by
  /// asking, which the system answers without a prompt once decided).
  Future<void> refresh() async {
    if (!ref.read(platformCapabilitiesProvider).osScheduledNotices) return;
    final exact = await ref.read(noticeSchedulerProvider).exactTimingAllowed();
    _set(
      NoticePermissions(notifications: state.notifications, exactTiming: exact),
    );
  }

  void _set(NoticePermissions next) {
    final gainedExact = state.exactTiming == false && next.exactTiming == true;
    state = next;
    // Planned without exact timing, the notifications are planned again.
    if (gainedExact) unawaited(ref.read(noticePlannerProvider)?.replan());
  }
}

/// Provider of [NoticePermissionsController].
final noticePermissionsProvider =
    NotifierProvider<NoticePermissionsController, NoticePermissions>(
      NoticePermissionsController.new,
    );
