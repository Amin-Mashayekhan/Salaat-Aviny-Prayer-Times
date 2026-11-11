import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:prayer_core/prayer_core.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// The three calendars the app shows side by side.
enum CalendarKind {
  /// Solar Hijri (Shamsi / Persian), the default.
  jalali,

  /// Lunar Hijri (Umm al-Qura table plus the user adjustment).
  hijri,

  /// Gregorian.
  gregorian,
}

/// A year, month and day in one calendar (the calendar is implied by where
/// the value is used).
@immutable
class CalendarDate {
  /// Creates a date; no validation (see [TriDate] for the checked ones).
  const CalendarDate(this.year, this.month, this.day);

  /// Year.
  final int year;

  /// Month, 1 to 12.
  final int month;

  /// Day of month.
  final int day;

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year/$month/$day';
}

/// One day in the Gregorian, Jalali and Hijri calendars.
///
/// The Gregorian date is the truth. The Jalali date uses `package:shamsi_date`
/// and the Hijri date `package:hijri` (Umm al-Qura, valid 1356 to 1500 AH);
/// the user's Hijri adjustment (-2 to +2 days) is applied by shifting the
/// Gregorian date before the Hijri conversion, and removed again when
/// converting from a Hijri date.
@immutable
class TriDate {
  const TriDate._({
    required this.gregorian,
    required this.jalali,
    required this.hijri,
    required this.hijriAdjustment,
    required this.hijriMonthLength,
  });

  /// The three dates of a Gregorian [date].
  factory TriDate.fromGregorian(CivilDate date, {int hijriAdjustment = 0}) {
    final j = Jalali.fromGregorian(Gregorian(date.year, date.month, date.day));
    CalendarDate? hijri;
    int? hijriLength;
    try {
      final shifted = date.addDays(hijriAdjustment);
      final h = HijriCalendar()
        ..gregorianToHijri(shifted.year, shifted.month, shifted.day);
      hijri = CalendarDate(h.hYear, h.hMonth, h.hDay);
      hijriLength = h.lengthOfMonth;
      // The packages signal an unsupported date with an ArgumentError.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      // Outside the Umm al-Qura table: no Hijri date for this day.
      hijri = null;
    }
    return TriDate._(
      gregorian: date,
      jalali: CalendarDate(j.year, j.month, j.day),
      hijri: hijri,
      hijriAdjustment: hijriAdjustment,
      hijriMonthLength: hijriLength,
    );
  }

  /// The date in [kind] with these fields, or null if it does not exist
  /// (month 13, day 31 of Esfand in a common year, a Hijri year outside the
  /// table, ...).
  static TriDate? tryFrom(
    CalendarKind kind,
    int year,
    int month,
    int day, {
    int hijriAdjustment = 0,
  }) => switch (kind) {
    CalendarKind.gregorian => tryFromGregorian(
      year,
      month,
      day,
      hijriAdjustment: hijriAdjustment,
    ),
    CalendarKind.jalali => tryFromJalali(
      year,
      month,
      day,
      hijriAdjustment: hijriAdjustment,
    ),
    CalendarKind.hijri => tryFromHijri(
      year,
      month,
      day,
      hijriAdjustment: hijriAdjustment,
    ),
  };

  /// A Gregorian date, or null if it does not exist.
  static TriDate? tryFromGregorian(
    int year,
    int month,
    int day, {
    int hijriAdjustment = 0,
  }) {
    if (year < minGregorianYear || year > maxGregorianYear) return null;
    try {
      return TriDate.fromGregorian(
        CivilDate(year, month, day),
        hijriAdjustment: hijriAdjustment,
      );
      // The packages signal an unsupported date with an ArgumentError.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return null;
    }
  }

  /// A Jalali date, or null if it does not exist.
  static TriDate? tryFromJalali(
    int year,
    int month,
    int day, {
    int hijriAdjustment = 0,
  }) {
    if (year < minJalaliYear || year > maxJalaliYear) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > jalaliMonthLength(year, month)) return null;
    final g = Jalali(year, month, day).toGregorian();
    return TriDate.fromGregorian(
      CivilDate(g.year, g.month, g.day),
      hijriAdjustment: hijriAdjustment,
    );
  }

  /// A Hijri date (with the user [hijriAdjustment]), or null if it does not
  /// exist or lies outside the Umm al-Qura table.
  static TriDate? tryFromHijri(
    int year,
    int month,
    int day, {
    int hijriAdjustment = 0,
  }) {
    if (month < 1 || month > 12 || day < 1 || day > 30) return null;
    try {
      final g = HijriCalendar().hijriToGregorian(year, month, day);
      final civil = CivilDate(g.year, g.month, g.day).addDays(-hijriAdjustment);
      final result = TriDate.fromGregorian(
        civil,
        hijriAdjustment: hijriAdjustment,
      );
      // A day that does not exist (30 in a 29-day month) rolls over into the
      // next month; reject it by converting back.
      if (result.hijri != CalendarDate(year, month, day)) return null;
      return result;
      // The packages signal an unsupported date with an ArgumentError.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return null;
    }
  }

  /// Earliest Gregorian year accepted by the checked constructors.
  static const int minGregorianYear = 1700;

  /// Latest Gregorian year accepted by the checked constructors.
  static const int maxGregorianYear = 2400;

  /// Earliest Jalali year accepted by the checked constructors.
  static const int minJalaliYear = 1079;

  /// Latest Jalali year accepted by the checked constructors.
  static const int maxJalaliYear = 1778;

  /// Number of days of a Jalali month (31 for 1-6, 30 for 7-11, 29 or 30
  /// for Esfand).
  static int jalaliMonthLength(int year, int month) =>
      Jalali(year, month).monthLength;

  /// Whether the Jalali [year] is a leap year (Esfand has 30 days).
  static bool isJalaliLeapYear(int year) => Jalali(year).isLeapYear();

  /// Number of days of a Hijri month, or null outside the Umm al-Qura table.
  static int? hijriMonthLengthOf(int year, int month) {
    try {
      return HijriCalendar().getDaysInMonth(year, month);
      // The packages signal an unsupported date with an ArgumentError.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return null;
    }
  }

  /// The Gregorian date (the truth the others derive from).
  final CivilDate gregorian;

  /// The Jalali date.
  final CalendarDate jalali;

  /// The Hijri date with the adjustment applied; null outside the table.
  final CalendarDate? hijri;

  /// The Hijri adjustment in days that was applied.
  final int hijriAdjustment;

  /// Length of the Hijri month of [hijri], if known.
  final int? hijriMonthLength;

  /// ISO weekday, Monday = 1 to Sunday = 7.
  int get weekday => gregorian.weekday;

  /// Weekday in the Persian week: Saturday = 0 to Friday = 6.
  int get jalaliWeekdayIndex => (weekday + 1) % 7;

  /// Whether this day is a Friday.
  bool get isFriday => weekday == DateTime.friday;

  /// Length of the Jalali month of [jalali].
  int get jalaliMonthDays => jalaliMonthLength(jalali.year, jalali.month);

  /// The date in [kind].
  CalendarDate? dateIn(CalendarKind kind) => switch (kind) {
    CalendarKind.jalali => jalali,
    CalendarKind.hijri => hijri,
    CalendarKind.gregorian => CalendarDate(
      gregorian.year,
      gregorian.month,
      gregorian.day,
    ),
  };

  @override
  bool operator ==(Object other) =>
      other is TriDate &&
      other.gregorian == gregorian &&
      other.hijriAdjustment == hijriAdjustment;

  @override
  int get hashCode => Object.hash(gregorian, hijriAdjustment);

  @override
  String toString() => 'TriDate($gregorian = J$jalali = H$hijri)';
}

/// The Gregorian dates of every day of one calendar month, or null when the
/// month does not exist (Hijri month outside the table, month 13, ...).
List<CivilDate>? monthDays(
  CalendarKind kind,
  int year,
  int month, {
  int hijriAdjustment = 0,
}) {
  final length = switch (kind) {
    CalendarKind.jalali =>
      month >= 1 &&
              month <= 12 &&
              year >= TriDate.minJalaliYear &&
              year <= TriDate.maxJalaliYear
          ? TriDate.jalaliMonthLength(year, month)
          : null,
    CalendarKind.hijri =>
      month >= 1 && month <= 12
          ? TriDate.hijriMonthLengthOf(year, month)
          : null,
    CalendarKind.gregorian =>
      month >= 1 &&
              month <= 12 &&
              year >= TriDate.minGregorianYear &&
              year <= TriDate.maxGregorianYear
          ? DateTime.utc(year, month + 1, 0).day
          : null,
  };
  if (length == null) return null;
  final first = TriDate.tryFrom(
    kind,
    year,
    month,
    1,
    hijriAdjustment: hijriAdjustment,
  );
  if (first == null) return null;
  return [for (var i = 0; i < length; i++) first.gregorian.addDays(i)];
}
