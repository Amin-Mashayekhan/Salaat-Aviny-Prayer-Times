import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// Weekday, month and calendar names in the language of [l10n].
@immutable
class CalendarNames {
  /// Creates the names.
  const CalendarNames(this.l10n);

  /// The localised text.
  final AppLocalizations l10n;

  /// Name of an ISO weekday (Monday = 1 to Sunday = 7).
  String weekday(int isoWeekday) => l10n.calendarWeekday('d$isoWeekday');

  /// Name of a Jalali month (1 to 12).
  String jalaliMonth(int month) => l10n.calendarMonthJalali('m$month');

  /// Name of a Hijri month (1 to 12).
  String hijriMonth(int month) => l10n.calendarMonthHijri('m$month');

  /// Name of a Gregorian month (1 to 12).
  String gregorianMonth(int month) => l10n.calendarMonthGregorian('m$month');

  /// Name of [month] in the calendar [kind].
  String month(CalendarKind kind, int month) => switch (kind) {
    CalendarKind.jalali => jalaliMonth(month),
    CalendarKind.hijri => hijriMonth(month),
    CalendarKind.gregorian => gregorianMonth(month),
  };

  /// Name of the calendar itself (Shamsi, lunar, Gregorian).
  String kind(CalendarKind kind) => switch (kind) {
    CalendarKind.jalali => l10n.calendarKindJalali,
    CalendarKind.hijri => l10n.calendarKindHijri,
    CalendarKind.gregorian => l10n.calendarKindGregorian,
  };
}

/// Provider of [CalendarNames] for the app language.
final calendarNamesProvider = Provider<CalendarNames>(
  (ref) => CalendarNames(ref.watch(appLocalizationsProvider)),
);

/// The strings of the date header of the home screen.
@immutable
class DateHeader {
  /// Creates a header.
  const DateHeader({
    required this.weekday,
    required this.jalali,
    required this.hijri,
    required this.gregorian,
    required this.hijriApproximate,
  });

  /// Weekday name.
  final String weekday;

  /// Jalali date: "20 Aban 1405".
  final String jalali;

  /// Hijri date, or null outside the supported table.
  final String? hijri;

  /// Gregorian date: "11 November 2026".
  final String gregorian;

  /// True while the Hijri adjustment is 0: the date is only approximate.
  final bool hijriApproximate;

  /// The first line: weekday and Jalali date.
  String get primary => '$weekday $jalali';

  /// The second line: Hijri and Gregorian dates.
  String get secondary => hijri == null ? gregorian : '$hijri · $gregorian';

  @override
  bool operator ==(Object other) =>
      other is DateHeader &&
      other.weekday == weekday &&
      other.jalali == jalali &&
      other.hijri == hijri &&
      other.gregorian == gregorian &&
      other.hijriApproximate == hijriApproximate;

  @override
  int get hashCode =>
      Object.hash(weekday, jalali, hijri, gregorian, hijriApproximate);
}

/// Builds the header strings of [date].
DateHeader buildDateHeader({
  required TriDate date,
  required CalendarNames names,
  required Formatter formatter,
}) {
  String line(CalendarKind kind, CalendarDate d) =>
      names.l10n.calendarDayMonthYear(
        formatter.formatNumber(d.day),
        names.month(kind, d.month),
        formatter.formatNumber(d.year),
      );
  final h = date.hijri;
  final g = date.dateIn(CalendarKind.gregorian)!;
  return DateHeader(
    weekday: names.weekday(date.weekday),
    jalali: line(CalendarKind.jalali, date.jalali),
    hijri: h == null ? null : line(CalendarKind.hijri, h),
    gregorian: line(CalendarKind.gregorian, g),
    hijriApproximate: date.hijriAdjustment == 0,
  );
}

/// The header strings of a civil (Gregorian) date, following language, digits and
/// the Hijri adjustment of the settings.
// The family type is not exported under a stable name in Riverpod 3.
// ignore: specify_nonobvious_property_types
final dateHeaderProvider = Provider.family<DateHeader, CivilDate>((ref, date) {
  final adjustment = ref.watch(
    settingsProvider.select((s) => s.hijriAdjustmentDays),
  );
  return buildDateHeader(
    date: TriDate.fromGregorian(date, hijriAdjustment: adjustment),
    names: ref.watch(calendarNamesProvider),
    formatter: ref.watch(formatterProvider),
  );
});
