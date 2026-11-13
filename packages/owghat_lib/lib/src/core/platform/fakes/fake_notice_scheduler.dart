import 'package:owghat_lib/src/core/platform/notice_scheduler.dart';

/// A [NoticeScheduler] for tests: keeps what it was given.
class FakeNoticeScheduler implements NoticeScheduler {
  /// The last list handed over.
  List<PlannedNotice> planned = const [];

  /// Number of `replaceAll` calls.
  int replaceCalls = 0;

  /// What `requestPermissions` answers.
  bool permitted = true;

  /// Number of `requestPermissions` calls.
  int permissionRequests = 0;

  @override
  Future<void> replaceAll(List<PlannedNotice> notices) async {
    replaceCalls++;
    planned = List.unmodifiable(notices);
  }

  @override
  Future<bool> requestPermissions() async {
    permissionRequests++;
    return permitted;
  }

  /// What `exactTimingAllowed` answers.
  bool exact = true;

  /// Number of `requestExactTiming` calls.
  int exactRequests = 0;

  @override
  Future<bool> exactTimingAllowed() async => exact;

  @override
  Future<void> requestExactTiming() async {
    exactRequests++;
  }
}
