import 'dart:async';

/// Runs an action once after calls stop arriving for [delay].
class Debouncer {
  /// Creates a debouncer.
  Debouncer(this.delay);

  /// Quiet period before the action runs.
  final Duration delay;

  Timer? _timer;

  /// Schedules [action], replacing any pending one.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Runs the pending action now, if there is one.
  void flush(void Function() action) {
    _timer?.cancel();
    _timer = null;
    action();
  }

  /// Cancels the pending action.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
