import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';

/// Why a typed date could not be converted.
enum ConvertProblem {
  /// A field is empty.
  incomplete,

  /// A field holds something other than digits.
  notANumber,

  /// The month is not 1 to 12.
  monthOutOfRange,

  /// The day does not exist in that month (see [ConvertError.maxDay]).
  dayOutOfRange,

  /// The year is outside what the calendar (or its table) supports.
  outOfRange,
}

/// Outcome of [convertDate].
@immutable
sealed class ConvertResult {
  const ConvertResult();
}

/// The date exists; [date] holds it in all three calendars.
final class ConvertOk extends ConvertResult {
  /// Creates the result.
  const ConvertOk(this.date);

  /// The converted day.
  final TriDate date;
}

/// The date cannot be converted.
final class ConvertError extends ConvertResult {
  /// Creates the result.
  const ConvertError(this.problem, {this.maxDay});

  /// What is wrong.
  final ConvertProblem problem;

  /// For [ConvertProblem.dayOutOfRange]: the last day of that month.
  final int? maxDay;
}

/// Replaces Persian and Arabic-Indic digits with Latin ones and trims.
String normalizeDigits(String text) {
  final out = StringBuffer();
  for (final rune in text.trim().runes) {
    if (rune >= 0x06f0 && rune <= 0x06f9) {
      out.writeCharCode(0x30 + rune - 0x06f0);
    } else if (rune >= 0x0660 && rune <= 0x0669) {
      out.writeCharCode(0x30 + rune - 0x0660);
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

/// Converts the typed [year], [month] and [day] of the calendar [kind] into
/// all three calendars, or says what is wrong with them.
///
/// Persian digits are accepted. Impossible dates (month 13, 31 Esfand in a
/// common year, 30 in a 29-day lunar month, years outside the supported
/// range) are errors, never rolled over into the next month.
ConvertResult convertDate(
  CalendarKind kind,
  String year,
  String month,
  String day, {
  int hijriAdjustment = 0,
}) {
  final y = normalizeDigits(year);
  final m = normalizeDigits(month);
  final d = normalizeDigits(day);
  if (y.isEmpty || m.isEmpty || d.isEmpty) {
    return const ConvertError(ConvertProblem.incomplete);
  }
  final digits = RegExp(r'^[0-9]{1,6}$');
  if (!digits.hasMatch(y) || !digits.hasMatch(m) || !digits.hasMatch(d)) {
    return const ConvertError(ConvertProblem.notANumber);
  }
  final yy = int.parse(y);
  final mm = int.parse(m);
  final dd = int.parse(d);
  if (mm < 1 || mm > 12) {
    return const ConvertError(ConvertProblem.monthOutOfRange);
  }
  final length = _monthLength(kind, yy, mm);
  if (length == null) return const ConvertError(ConvertProblem.outOfRange);
  if (dd < 1 || dd > length) {
    return ConvertError(ConvertProblem.dayOutOfRange, maxDay: length);
  }
  final date = TriDate.tryFrom(
    kind,
    yy,
    mm,
    dd,
    hijriAdjustment: hijriAdjustment,
  );
  if (date == null) return const ConvertError(ConvertProblem.outOfRange);
  return ConvertOk(date);
}

int? _monthLength(CalendarKind kind, int year, int month) => switch (kind) {
  CalendarKind.jalali =>
    year < TriDate.minJalaliYear || year > TriDate.maxJalaliYear
        ? null
        : TriDate.jalaliMonthLength(year, month),
  CalendarKind.hijri => TriDate.hijriMonthLengthOf(year, month),
  CalendarKind.gregorian =>
    year < TriDate.minGregorianYear || year > TriDate.maxGregorianYear
        ? null
        : DateTime.utc(year, month + 1, 0).day,
};
