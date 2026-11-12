// The callbacks keep private fields while the named parameters stay public.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';

/// A cancellable countdown that ticks once per `tick` (one second by
/// default).
///
/// It counts ticks instead of reading a wall clock, so a clock change cannot
/// shorten or lengthen it. It lives in `core/time` because timers are only
/// allowed here and in the scheduler.
class Countdown {
  /// Starts a countdown of [total].
  ///
  /// [onTick] receives the time that remains after every tick (the last call
  /// has `Duration.zero`, right before `onDone`). Neither callback runs after
  /// [cancel].
  Countdown.start({
    required Duration total,
    required void Function(Duration remaining) onTick,
    required void Function() onDone,
    Duration tick = const Duration(seconds: 1),
  }) : assert(total > Duration.zero, 'total must be positive'),
       assert(tick > Duration.zero, 'tick must be positive'),
       _remaining = total,
       _tick = tick,
       _onTick = onTick,
       _onDone = onDone {
    _timer = Timer.periodic(tick, _fire);
  }

  final Duration _tick;
  final void Function(Duration remaining) _onTick;
  final void Function() _onDone;
  Duration _remaining;
  Timer? _timer;

  /// Whether the countdown is still running.
  bool get isActive => _timer != null;

  /// Time left.
  Duration get remaining => _remaining;

  void _fire(Timer timer) {
    _remaining -= _tick;
    if (_remaining <= Duration.zero) {
      _remaining = Duration.zero;
      timer.cancel();
      _timer = null;
      _onTick(Duration.zero);
      _onDone();
      return;
    }
    _onTick(_remaining);
  }

  /// Stops the countdown without calling `onDone`. Safe to call twice.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
