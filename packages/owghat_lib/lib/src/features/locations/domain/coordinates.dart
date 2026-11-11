/// Degrees, minutes and seconds of a latitude or longitude.
class Dms {
  /// Creates a value; [negative] marks south or west.
  const Dms({
    required this.degrees,
    required this.minutes,
    required this.seconds,
    this.negative = false,
  });

  /// Splits a decimal-degree value into degrees, minutes and seconds.
  factory Dms.fromDecimal(double value) {
    final negative = value < 0;
    final abs = value.abs();
    var degrees = abs.floor();
    final minutesFull = (abs - degrees) * 60;
    var minutes = minutesFull.floor();
    var seconds = ((minutesFull - minutes) * 60 * 100).round() / 100;
    if (seconds >= 60) {
      seconds -= 60;
      minutes += 1;
    }
    if (minutes >= 60) {
      minutes -= 60;
      degrees += 1;
    }
    return Dms(
      degrees: degrees,
      minutes: minutes,
      seconds: seconds,
      negative: negative,
    );
  }

  /// Whole degrees (non-negative).
  final int degrees;

  /// Whole minutes, 0 to 59.
  final int minutes;

  /// Seconds, 0 up to but not including 60.
  final double seconds;

  /// True for south or west.
  final bool negative;

  /// Whether minutes and seconds are in range.
  bool get isValid =>
      degrees >= 0 &&
      minutes >= 0 &&
      minutes < 60 &&
      seconds >= 0 &&
      seconds < 60;

  /// The decimal-degree value.
  double get decimal {
    final value = degrees + minutes / 60 + seconds / 3600;
    return negative ? -value : value;
  }
}
