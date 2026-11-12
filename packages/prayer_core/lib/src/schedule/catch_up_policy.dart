import 'package:prayer_core/src/schedule/scheduled_event.dart';

/// What the engine must do with an event it is looking at.
enum CatchUpDecision {
  /// Its time has not come yet.
  notYetDue,

  /// It was already handled (exactly-once guard).
  alreadyHandled,

  /// Due now: run it normally.
  fire,

  /// Late but still useful: run it, adjusting any "remaining time" text.
  fireLate,

  /// Too late to play, but the user should be told it was missed.
  notifyMissed,

  /// Too late and not worth mentioning: mark it handled silently.
  drop,
}

/// Rules for events whose time has passed (start, resume, clock change).
///
/// See `docs/prayer-times.md`.
class CatchUpPolicy {
  /// Creates a policy.
  const CatchUpPolicy({
    this.azanGrace = const Duration(minutes: 3),
    this.alarmGrace = const Duration(minutes: 10),
    this.onTimeTolerance = const Duration(seconds: 5),
  });

  /// How late an azan may still be played.
  final Duration azanGrace;

  /// How late a wake-up alarm may still be run.
  final Duration alarmGrace;

  /// Lateness up to this is treated as on time.
  final Duration onTimeTolerance;

  /// Decision for a single [event] at [now].
  ///
  /// This does not know about other events; use [decideAll] to apply the
  /// "never play two azans back to back" rule.
  CatchUpDecision decide(
    ScheduledEvent event,
    DateTime now,
    Set<String> handledIds,
  ) {
    if (handledIds.contains(event.id)) return CatchUpDecision.alreadyHandled;
    if (event.instantUtc.isAfter(now)) return CatchUpDecision.notYetDue;
    final lateness = now.difference(event.instantUtc);
    final onTime = lateness <= onTimeTolerance;
    switch (event.kind) {
      case EventKind.azan:
        if (onTime) return CatchUpDecision.fire;
        return lateness <= azanGrace
            ? CatchUpDecision.fireLate
            : CatchUpDecision.notifyMissed;
      case EventKind.reminder:
        final azanAt = event.relatedInstantUtc;
        if (azanAt == null || !azanAt.isAfter(now)) {
          return CatchUpDecision.drop;
        }
        return onTime ? CatchUpDecision.fire : CatchUpDecision.fireLate;
      case EventKind.wakeAlarm:
        if (onTime) return CatchUpDecision.fire;
        return lateness <= alarmGrace
            ? CatchUpDecision.fireLate
            : CatchUpDecision.drop;
      case EventKind.dayRollover:
        return CatchUpDecision.fire;
    }
  }

  /// Decisions for every event in [events] at [now].
  ///
  /// Applies [decide] to each, then enforces: of all azans that would play
  /// (`fire` or `fireLate`) only the most recent one plays; earlier ones
  /// become `notifyMissed`.
  Map<String, CatchUpDecision> decideAll(
    Iterable<ScheduledEvent> events,
    DateTime now,
    Set<String> handledIds,
  ) {
    final decisions = <String, CatchUpDecision>{};
    ScheduledEvent? latestPlayable;
    for (final event in events) {
      final decision = decide(event, now, handledIds);
      decisions[event.id] = decision;
      final plays =
          event.kind == EventKind.azan &&
          (decision == CatchUpDecision.fire ||
              decision == CatchUpDecision.fireLate);
      if (plays &&
          (latestPlayable == null ||
              event.instantUtc.isAfter(latestPlayable.instantUtc))) {
        latestPlayable = event;
      }
    }
    if (latestPlayable != null) {
      for (final event in events) {
        final decision = decisions[event.id];
        final plays =
            event.kind == EventKind.azan &&
            (decision == CatchUpDecision.fire ||
                decision == CatchUpDecision.fireLate);
        if (plays && event.id != latestPlayable.id) {
          decisions[event.id] = CatchUpDecision.notifyMissed;
        }
      }
    }
    return decisions;
  }
}
