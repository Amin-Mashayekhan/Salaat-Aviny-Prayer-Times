/// Emits the fraction (0 to 1) of a linear fade over [duration], in [steps]
/// equal steps: `0` immediately, then `1/steps`, `2/steps` ... `1`.
///
/// Audio implementations multiply the target volume by each value to fade a
/// sound in. It lives in `core/time` because it is the one place besides the
/// scheduler allowed to wait; cancelling the subscription stops the fade.
Stream<double> fadeRamp(Duration duration, {int steps = 20}) async* {
  yield 0;
  if (duration <= Duration.zero || steps < 1) {
    yield 1;
    return;
  }
  final stepLength = Duration(microseconds: duration.inMicroseconds ~/ steps);
  for (var i = 1; i <= steps; i++) {
    await Future<void>.delayed(stepLength);
    yield i / steps;
  }
}
