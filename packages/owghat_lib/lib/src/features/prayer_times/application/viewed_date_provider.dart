import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:prayer_core/prayer_core.dart';

/// The day the home screen is showing instead of today, or null for today.
///
/// The timetable and the calendar open a day on Home through this provider.
class ViewedDateController extends Notifier<CivilDate?> {
  @override
  CivilDate? build() => null;

  /// Shows [date]; today's date means "today" (null).
  void show(CivilDate date) {
    state = date == ref.read(todayProvider) ? null : date;
  }

  /// Back to today.
  void reset() => state = null;

  /// Moves the shown day by [days] (negative for earlier).
  void shiftDays(int days) {
    final today = ref.read(todayProvider);
    final shown = state;
    show((shown ?? today).addDays(days));
  }
}

/// Provider of the viewed date (null means today).
final viewedDateProvider = NotifierProvider<ViewedDateController, CivilDate?>(
  ViewedDateController.new,
);
