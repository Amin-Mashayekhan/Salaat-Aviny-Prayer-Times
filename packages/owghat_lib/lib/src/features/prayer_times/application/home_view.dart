import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/viewed_date_provider.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/next_prayer.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

/// Which day the list of the home screen shows, relative to today.
enum HomeDayKind {
  /// Today, with the live countdown.
  today,

  /// Tomorrow, after the last event of today has passed.
  tomorrow,

  /// A day the user navigated to; no countdown.
  other,

  /// A day before today that still owns the next event (a midnight that
  /// falls after 00:00).
  earlier,
}

/// One row of the list of times.
@immutable
class HomeRow {
  /// Creates a row.
  const HomeRow({
    required this.prayer,
    required this.time,
    required this.instant,
    required this.passed,
    required this.isNext,
  });

  /// Which time.
  final Prayer prayer;

  /// Time after local midnight, or null if it does not occur.
  final Duration? time;

  /// The same time as a UTC instant, or null.
  final DateTime? instant;

  /// Already over (always false when browsing another day).
  final bool passed;

  /// The event the countdown waits for.
  final bool isNext;

  @override
  bool operator ==(Object other) =>
      other is HomeRow &&
      other.prayer == prayer &&
      other.time == time &&
      other.instant == instant &&
      other.passed == passed &&
      other.isNext == isNext;

  @override
  int get hashCode => Object.hash(prayer, time, instant, passed, isNext);
}

/// A dot of the day timeline.
@immutable
class TimelineDot {
  /// Creates a dot.
  const TimelineDot({
    required this.prayer,
    required this.fraction,
    required this.passed,
    required this.isNext,
  });

  /// Which event.
  final Prayer prayer;

  /// Position from the first shown event (0) to the last (1).
  final double fraction;

  /// Already over.
  final bool passed;

  /// The event the countdown waits for.
  final bool isNext;
}

/// Everything the home screen needs, derived from the clock, the settings
/// and the calculation.
@immutable
class HomeView {
  /// Creates a view.
  const HomeView({
    required this.date,
    required this.kind,
    required this.utcOffset,
    required this.rows,
    required this.dots,
    required this.nowFraction,
    required this.next,
    required this.current,
    required this.remaining,
  });

  /// The civil date whose times are listed.
  final CivilDate date;

  /// Today, tomorrow or another day.
  final HomeDayKind kind;

  /// UTC offset of [date] at the active location.
  final Duration utcOffset;

  /// The rows, in clock order.
  final List<HomeRow> rows;

  /// Timeline dots for the rows that occur.
  final List<TimelineDot> dots;

  /// Position of "now" on the timeline (0 to 1), null when browsing another
  /// day.
  final double? nowFraction;

  /// The event the countdown waits for; null when browsing another day or
  /// when no event exists.
  final PrayerMoment? next;

  /// The latest event already passed (drives the sky colour), if any.
  final PrayerMoment? current;

  /// Time until [next]; zero if none.
  final Duration remaining;

  /// Whether the countdown is live (today or the continuation after the
  /// last event).
  bool get isLive => kind != HomeDayKind.other;

  /// Whether at least one listed time does not occur (polar summer or
  /// winter).
  bool get hasMissingTimes => rows.any((r) => r.time == null);

  /// Whether no listed time occurs at all.
  bool get hasNoTimes => rows.every((r) => r.time == null);
}

/// The date the list shows.
///
/// A viewed date other than today wins. Otherwise it is the date of the
/// next event, so that after the last event of today the list switches to
/// tomorrow.
({CivilDate date, HomeDayKind kind}) homeTargetDate({
  required CivilDate today,
  required CivilDate? viewed,
  required PrayerMoment? next,
}) {
  if (viewed != null && viewed != today) {
    return (date: viewed, kind: HomeDayKind.other);
  }
  if (next == null || next.date == today) {
    return (date: today, kind: HomeDayKind.today);
  }
  return (
    date: next.date,
    kind: next.date.compareTo(today) > 0
        ? HomeDayKind.tomorrow
        : HomeDayKind.earlier,
  );
}

/// Builds the [HomeView] of [day].
HomeView buildHomeView({
  required PrayerDay day,
  required HomeDayKind kind,
  required NextPrayerState state,
  required DisplaySettings display,
  required DateTime now,
}) {
  final live = kind != HomeDayKind.other;
  final next = live ? state.next : null;
  final rows = <HomeRow>[];
  for (final prayer in Prayer.values) {
    if (!display.shows(prayer)) continue;
    final instant = day.instants[prayer];
    rows.add(
      HomeRow(
        prayer: prayer,
        time: day.times[prayer],
        instant: instant,
        passed: live && instant != null && !instant.isAfter(now),
        isNext:
            next != null &&
            next.prayer == prayer &&
            next.date == day.date &&
            next.instant == instant,
      ),
    );
  }

  final withInstant = [
    for (final row in rows)
      if (row.instant != null) row,
  ]..sort((a, b) => a.instant!.compareTo(b.instant!));
  final dots = <TimelineDot>[];
  double? nowFraction;
  if (withInstant.isNotEmpty) {
    final start = withInstant.first.instant!;
    final end = withInstant.last.instant!;
    final span = end.difference(start).inMicroseconds;
    double fractionOf(DateTime t) =>
        span <= 0 ? 0 : t.difference(start).inMicroseconds / span;
    for (final row in withInstant) {
      dots.add(
        TimelineDot(
          prayer: row.prayer,
          fraction: fractionOf(row.instant!),
          passed: row.passed,
          isNext: row.isNext,
        ),
      );
    }
    if (live) nowFraction = fractionOf(now).clamp(0.0, 1.0);
  }

  return HomeView(
    date: day.date,
    kind: kind,
    utcOffset: day.utcOffset,
    rows: rows,
    dots: dots,
    nowFraction: nowFraction,
    next: next,
    current: state.current,
    remaining: next == null ? Duration.zero : state.remaining,
  );
}

/// The state of the home screen, recomputed every second.
final homeViewProvider = Provider<HomeView>((ref) {
  final today = ref.watch(todayProvider);
  final viewed = ref.watch(viewedDateProvider);
  final state = ref.watch(nextPrayerProvider);
  final now = ref.watch(nowProvider);
  final display = ref.watch(settingsProvider.select((s) => s.display));
  final target = homeTargetDate(today: today, viewed: viewed, next: state.next);
  return buildHomeView(
    day: ref.watch(prayerDayProvider(target.date)),
    kind: target.kind,
    state: state,
    display: display,
    now: now,
  );
});
