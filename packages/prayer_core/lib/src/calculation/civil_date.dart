import 'package:meta/meta.dart';

/// A calendar date in the proleptic Gregorian calendar, without time or zone.
@immutable
class CivilDate implements Comparable<CivilDate> {
  /// Creates a date; throws [ArgumentError] if it does not exist.
  CivilDate(this.year, this.month, this.day) {
    final probe = DateTime.utc(year, month, day);
    if (probe.year != year || probe.month != month || probe.day != day) {
      throw ArgumentError('Invalid civil date $year-$month-$day');
    }
  }

  /// Parses an ISO `yyyy-MM-dd` string.
  factory CivilDate.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      throw FormatException('Expected yyyy-MM-dd', iso);
    }
    return CivilDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// The civil date of a `DateTime`, using its own fields (no conversion).
  factory CivilDate.fromDateTime(DateTime value) =>
      CivilDate(value.year, value.month, value.day);

  /// Gregorian year.
  final int year;

  /// Month, 1 to 12.
  final int month;

  /// Day of month, 1 to 31.
  final int day;

  /// The date [days] days later (negative for earlier).
  CivilDate addDays(int days) =>
      CivilDate.fromDateTime(DateTime.utc(year, month, day + days));

  /// Midnight at the start of this date, as a UTC-flagged `DateTime`
  /// carrying the date's fields (not an instant in any zone).
  DateTime get asUtcMidnight => DateTime.utc(year, month, day);

  /// ISO weekday, Monday = 1 to Sunday = 7.
  int get weekday => asUtcMidnight.weekday;

  /// ISO `yyyy-MM-dd`.
  String get iso =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CivilDate other) =>
      asUtcMidnight.compareTo(other.asUtcMidnight);

  @override
  bool operator ==(Object other) =>
      other is CivilDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;
}
