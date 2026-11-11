import 'package:clock/clock.dart';

/// Emits the current time of [clock] (as UTC) at the start of every second.
///
/// The first value is emitted immediately; the following ones are aligned to
/// whole seconds of the clock so a displayed countdown never lags by a
/// fraction of a second.
Stream<DateTime> secondTicks(Clock clock) async* {
  while (true) {
    final now = clock.now().toUtc();
    yield now;
    final intoSecond =
        now.microsecondsSinceEpoch % Duration.microsecondsPerSecond;
    await Future<void>.delayed(
      Duration(microseconds: Duration.microsecondsPerSecond - intoSecond),
    );
  }
}

/// Emits the current time of [clock] (as UTC) at the start of every minute,
/// and immediately once. Used while the window is hidden.
Stream<DateTime> minuteTicks(Clock clock) async* {
  while (true) {
    final now = clock.now().toUtc();
    yield now;
    final intoMinute =
        now.microsecondsSinceEpoch % Duration.microsecondsPerMinute;
    await Future<void>.delayed(
      Duration(microseconds: Duration.microsecondsPerMinute - intoMinute),
    );
  }
}
