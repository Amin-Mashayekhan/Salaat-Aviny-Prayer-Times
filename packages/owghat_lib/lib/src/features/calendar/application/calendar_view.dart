import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// Which Shamsi month the calendar grid shows and which day is selected.
@immutable
class CalendarViewState {
  /// Creates a state.
  const CalendarViewState({
    required this.year,
    required this.month,
    required this.selected,
  });

  /// Shamsi year of the shown month.
  final int year;

  /// Shamsi month, 1 to 12.
  final int month;

  /// The selected day (the side panel shows it).
  final CivilDate selected;

  /// The month [delta] months later (negative for earlier).
  CalendarViewState shifted(int delta) {
    final index = year * 12 + (month - 1) + delta;
    return CalendarViewState(
      year: index ~/ 12,
      month: index % 12 + 1,
      selected: selected,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarViewState &&
      other.year == year &&
      other.month == month &&
      other.selected == selected;

  @override
  int get hashCode => Object.hash(year, month, selected);
}

/// The month and selected day of the Calendar screen. Starts on today.
class CalendarViewController extends Notifier<CalendarViewState> {
  @override
  CalendarViewState build() {
    final today = ref.read(todayProvider);
    final tri = TriDate.fromGregorian(today, hijriAdjustment: _adjustment);
    return CalendarViewState(
      year: tri.jalali.year,
      month: tri.jalali.month,
      selected: today,
    );
  }

  int get _adjustment =>
      ref.read(settingsProvider.select((s) => s.hijriAdjustmentDays));

  /// Whether the month [delta] months away exists in the supported range.
  bool canMove(int delta) {
    final target = state.shifted(delta);
    return monthDays(CalendarKind.jalali, target.year, target.month) != null;
  }

  /// Shows the next month.
  void next() {
    if (canMove(1)) state = state.shifted(1);
  }

  /// Shows the previous month.
  void previous() {
    if (canMove(-1)) state = state.shifted(-1);
  }

  /// Selects [date] and shows its Shamsi month.
  void select(CivilDate date) {
    final tri = TriDate.tryFromGregorian(
      date.year,
      date.month,
      date.day,
      hijriAdjustment: _adjustment,
    );
    if (tri == null) return;
    state = CalendarViewState(
      year: tri.jalali.year,
      month: tri.jalali.month,
      selected: date,
    );
  }

  /// Back to today's month with today selected.
  void goToToday() => select(ref.read(todayProvider));
}

/// Provider of the calendar view state.
final calendarViewProvider =
    NotifierProvider<CalendarViewController, CalendarViewState>(
      CalendarViewController.new,
    );

/// The days of the shown month.
@immutable
class CalendarMonth {
  /// Creates a month.
  const CalendarMonth({required this.days, required this.leadingBlanks});

  /// Every day of the month in order, with its three dates.
  final List<TriDate> days;

  /// Empty cells before the first day (the week starts on Saturday).
  final int leadingBlanks;
}

/// The shown month, or null when it lies outside the supported years.
final calendarMonthProvider = Provider<CalendarMonth?>((ref) {
  final view = ref.watch(
    calendarViewProvider.select((s) => (year: s.year, month: s.month)),
  );
  final adjustment = ref.watch(
    settingsProvider.select((s) => s.hijriAdjustmentDays),
  );
  final dates = monthDays(CalendarKind.jalali, view.year, view.month);
  if (dates == null) return null;
  final days = [
    for (final date in dates)
      TriDate.fromGregorian(date, hijriAdjustment: adjustment),
  ];
  return CalendarMonth(
    days: days,
    leadingBlanks: days.first.jalaliWeekdayIndex,
  );
});

/// The selected day in the three calendars.
final calendarSelectedProvider = Provider<TriDate>((ref) {
  final selected = ref.watch(calendarViewProvider.select((s) => s.selected));
  final adjustment = ref.watch(
    settingsProvider.select((s) => s.hijriAdjustmentDays),
  );
  return TriDate.fromGregorian(selected, hijriAdjustment: adjustment);
});
