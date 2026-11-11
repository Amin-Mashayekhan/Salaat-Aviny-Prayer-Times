import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// Which month of which calendar the timetable shows.
@immutable
class TimetableSelection {
  /// Creates a selection.
  const TimetableSelection(this.kind, this.year, this.month);

  /// The calendar the month belongs to.
  final CalendarKind kind;

  /// Year in that calendar.
  final int year;

  /// Month, 1 to 12.
  final int month;

  /// The month [delta] months later (negative for earlier).
  TimetableSelection shifted(int delta) {
    final index = year * 12 + (month - 1) + delta;
    return TimetableSelection(kind, index ~/ 12, index % 12 + 1);
  }

  @override
  bool operator ==(Object other) =>
      other is TimetableSelection &&
      other.kind == kind &&
      other.year == year &&
      other.month == month;

  @override
  int get hashCode => Object.hash(kind, year, month);

  @override
  String toString() => 'TimetableSelection($kind $year/$month)';
}

/// One day of the timetable.
@immutable
class TimetableRow {
  /// Creates a row.
  const TimetableRow({
    required this.date,
    required this.tri,
    required this.day,
    required this.dayOfMonth,
  });

  /// The civil (Gregorian) date.
  final CivilDate date;

  /// The same day in the three calendars.
  final TriDate tri;

  /// The prayer times of the day.
  final PrayerDay day;

  /// Day number in the calendar of the selection.
  final int dayOfMonth;

  /// Whether the day is a Friday.
  bool get isFriday => tri.isFriday;
}

/// The month and calendar shown by the timetable; starts at the current
/// month in the Shamsi calendar.
class TimetableController extends Notifier<TimetableSelection> {
  @override
  TimetableSelection build() {
    final today = ref.read(todayProvider);
    final adjustment = ref.read(
      settingsProvider.select((s) => s.hijriAdjustmentDays),
    );
    final tri = TriDate.fromGregorian(today, hijriAdjustment: adjustment);
    return TimetableSelection(
      CalendarKind.jalali,
      tri.jalali.year,
      tri.jalali.month,
    );
  }

  int get _adjustment =>
      ref.read(settingsProvider.select((s) => s.hijriAdjustmentDays));

  /// Whether the month [delta] months away exists (the Hijri table ends).
  bool canMove(int delta) =>
      monthDays(
        state.kind,
        state.shifted(delta).year,
        state.shifted(delta).month,
        hijriAdjustment: _adjustment,
      ) !=
      null;

  /// Shows the next month.
  void next() {
    if (canMove(1)) state = state.shifted(1);
  }

  /// Shows the previous month.
  void previous() {
    if (canMove(-1)) state = state.shifted(-1);
  }

  /// Switches to [kind], keeping today's month if it is shown and else the
  /// month that contains the first day of the current one.
  void setKind(CalendarKind kind) {
    if (kind == state.kind) return;
    final days = monthDays(
      state.kind,
      state.year,
      state.month,
      hijriAdjustment: _adjustment,
    );
    final today = ref.read(todayProvider);
    final anchor = days == null
        ? today
        : days.contains(today)
        ? today
        : days.first;
    final tri = TriDate.fromGregorian(anchor, hijriAdjustment: _adjustment);
    final target = tri.dateIn(kind);
    if (target == null) return;
    state = TimetableSelection(kind, target.year, target.month);
  }
}

/// Provider of the timetable selection.
final timetableSelectionProvider =
    NotifierProvider<TimetableController, TimetableSelection>(
      TimetableController.new,
    );

/// The rows of one month, or null when that month does not exist (outside
/// the Hijri table). Cached per selection; every day comes from
/// [prayerDayProvider], so a settings or location change recomputes it.
// The family type is not exported under a stable name in Riverpod 3.
// ignore: specify_nonobvious_property_types
final timetableMonthProvider =
    Provider.family<List<TimetableRow>?, TimetableSelection>((ref, selection) {
      final adjustment = ref.watch(
        settingsProvider.select((s) => s.hijriAdjustmentDays),
      );
      final days = monthDays(
        selection.kind,
        selection.year,
        selection.month,
        hijriAdjustment: adjustment,
      );
      if (days == null) return null;
      final rows = <TimetableRow>[];
      for (var i = 0; i < days.length; i++) {
        final date = days[i];
        rows.add(
          TimetableRow(
            date: date,
            tri: TriDate.fromGregorian(date, hijriAdjustment: adjustment),
            day: ref.watch(prayerDayProvider(date)),
            dayOfMonth: i + 1,
          ),
        );
      }
      return rows;
    });
