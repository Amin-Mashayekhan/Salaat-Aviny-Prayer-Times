import 'package:prayer_core/prayer_core.dart';

/// Carries out a scheduled event (plays the azan, shows a notification...).
abstract interface class ScheduleDispatcher {
  /// Handles [event]; [decision] is `fire`, `fireLate` or `notifyMissed`.
  ///
  /// Implementations must not throw for ordinary failures (missing audio
  /// file, busy device): they log, show a quiet notice and return, because
  /// a failing dispatcher must never stop the schedule.
  Future<void> dispatch(ScheduledEvent event, CatchUpDecision decision);
}
