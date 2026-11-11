import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/next_occurrence.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_plan.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/test_data.dart';

void main() {
  late LocationRepository repo;
  late ResolvedLocation tehran;
  late ZoneOffsetResolver resolver;
  const calculation = CalculationSettings();

  setUpAll(() async {
    repo = await loadTestRepository();
    tehran = ResolvedLocation.from(AppSettings.defaultLocation, repo)!;
    resolver = ZoneOffsetResolver();
  });

  /// The real calculator, as the app uses it.
  PrayerDayLookup real(ResolvedLocation location) =>
      (date) => computePrayerDay(
        date: date,
        location: location,
        calculation: calculation,
        resolver: resolver,
      );

  /// A lookup that returns fixed prayer times (no calculator).
  PrayerDayLookup stub(
    Map<Prayer, Duration?> Function(CivilDate date) times, {
    Duration offset = const Duration(minutes: 210),
  }) => (date) {
    final t = PrayerTimes(times(date));
    return PrayerDay(
      date: date,
      utcOffset: offset,
      times: t,
      instants: toUtcInstants(date: date, utcOffset: offset, times: t),
    );
  };

  /// A Tehran wall-clock time (UTC+03:30, no DST) as a UTC instant.
  DateTime tehranLocal(int y, int m, int d, [int h = 0, int min = 0]) =>
      DateTime.utc(y, m, d, h, min).subtract(const Duration(minutes: 210));

  WakeOccurrence? next(
    WakeAlarm alarm,
    DateTime now, {
    PrayerDayLookup? lookup,
    ResolvedLocation? location,
    bool onceFired = false,
  }) {
    final place = location ?? tehran;
    return nextOccurrence(
      alarm,
      nowUtc: now,
      prayerDay: lookup ?? real(place),
      resolver: resolver,
      location: place,
      onceFired: onceFired,
    );
  }

  const fixed4 = WakeAlarm(id: 'a');

  group('fixed time', () {
    test('later today: fires today', () {
      final result = next(fixed4, tehranLocal(2026, 11, 11, 1));
      expect(result!.instantUtc, tehranLocal(2026, 11, 11, 4));
      expect(result.date, CivilDate(2026, 11, 11));
    });

    test('earlier today: fires tomorrow', () {
      final result = next(fixed4, tehranLocal(2026, 11, 11, 5));
      expect(result!.instantUtc, tehranLocal(2026, 11, 12, 4));
      expect(result.date, CivilDate(2026, 11, 12));
    });

    test('strictly after now: at the exact instant it is tomorrow', () {
      final result = next(fixed4, tehranLocal(2026, 11, 11, 4));
      expect(result!.instantUtc, tehranLocal(2026, 11, 12, 4));
    });

    test('one second before: still today', () {
      final result = next(
        fixed4,
        tehranLocal(2026, 11, 11, 4).subtract(const Duration(seconds: 1)),
      );
      expect(result!.instantUtc, tehranLocal(2026, 11, 11, 4));
    });

    test('just after local midnight: the date is the local one', () {
      // 00:00:30 Tehran on the 12th is still the 11th in UTC.
      final result = next(
        fixed4,
        tehranLocal(2026, 11, 12).add(const Duration(seconds: 30)),
      );
      expect(result!.date, CivilDate(2026, 11, 12));
      expect(result.instantUtc, tehranLocal(2026, 11, 12, 4));
    });

    test('a fixed-offset location uses that offset every day', () {
      const custom = ResolvedLocation(
        id: 'custom:1',
        nameFa: 'x',
        nameEn: 'x',
        latitude: 35.7,
        longitude: 51.4,
        elevationMeters: 0,
        zoneId: 'Asia/Tehran',
        offset: LocationOffset.fixed(60),
        isCustom: true,
      );
      final result = next(
        const WakeAlarm(id: 'b', hour: 6, minute: 30),
        DateTime.utc(2026, 7),
        location: custom,
      );
      expect(result!.instantUtc, DateTime.utc(2026, 7, 1, 5, 30));
    });

    test(
      'a zone with DST follows the database offset (no DST logic of ours)',
      () {
        const london = ResolvedLocation(
          id: 'custom:2',
          nameFa: 'x',
          nameEn: 'x',
          latitude: 51.5,
          longitude: -0.12,
          elevationMeters: 0,
          zoneId: 'Europe/London',
          offset: LocationOffset.automatic(),
          isCustom: true,
        );
        // BST ended on 2026-10-25 at 01:00 UTC.
        final before = next(
          fixed4,
          DateTime.utc(2026, 10, 24),
          location: london,
        );
        final after = next(
          fixed4,
          DateTime.utc(2026, 10, 26),
          location: london,
        );
        expect(before!.instantUtc, DateTime.utc(2026, 10, 24, 3));
        expect(after!.instantUtc, DateTime.utc(2026, 10, 26, 4));
      },
    );
  });

  group('repeat', () {
    // 2026-11-11 is a Wednesday.
    test('weekdays: skips the days that are not chosen', () {
      const monday = WakeAlarm(
        id: 'w',
        repeat: AlarmRepeat.weekdays,
        weekdays: {DateTime.monday},
      );
      final result = next(monday, tehranLocal(2026, 11, 11, 1));
      expect(result!.date, CivilDate(2026, 11, 16));
      expect(result.date.weekday, DateTime.monday);
      expect(result.instantUtc, tehranLocal(2026, 11, 16, 4));
    });

    test('weekdays: today counts if its time is still ahead', () {
      const wed = WakeAlarm(
        id: 'w',
        repeat: AlarmRepeat.weekdays,
        weekdays: {DateTime.wednesday},
      );
      expect(
        next(wed, tehranLocal(2026, 11, 11, 1))!.date,
        CivilDate(2026, 11, 11),
      );
      expect(
        next(wed, tehranLocal(2026, 11, 11, 5))!.date,
        CivilDate(2026, 11, 18),
      );
    });

    test('weekdays: several days pick the nearest', () {
      const set = WakeAlarm(
        id: 'w',
        repeat: AlarmRepeat.weekdays,
        weekdays: {DateTime.saturday, DateTime.sunday, DateTime.thursday},
      );
      var now = tehranLocal(2026, 11, 11, 5);
      final seen = <int>[];
      for (var i = 0; i < 6; i++) {
        final result = next(set, now)!;
        seen.add(result.date.weekday);
        now = result.instantUtc;
      }
      expect(seen, [
        DateTime.thursday,
        DateTime.saturday,
        DateTime.sunday,
        DateTime.thursday,
        DateTime.saturday,
        DateTime.sunday,
      ]);
    });

    test('weekdays with no day chosen never fires', () {
      const none = WakeAlarm(id: 'w', repeat: AlarmRepeat.weekdays);
      expect(next(none, tehranLocal(2026, 11, 11)), isNull);
    });

    test('daily fires every day', () {
      var now = tehranLocal(2026, 11, 11, 5);
      for (var i = 0; i < 10; i++) {
        final result = next(fixed4, now)!;
        expect(
          result.instantUtc.difference(now),
          lessThanOrEqualTo(const Duration(hours: 24)),
        );
        expect(result.date, CivilDate(2026, 11, 12 + i));
        now = result.instantUtc;
      }
    });

    test('once fires once, then reports null after it has fired', () {
      const once = WakeAlarm(id: 'o', repeat: AlarmRepeat.once);
      final first = next(once, tehranLocal(2026, 11, 11, 1));
      expect(first!.instantUtc, tehranLocal(2026, 11, 11, 4));
      expect(next(once, first.instantUtc, onceFired: true), isNull);
      expect(
        upcomingOccurrences(
          once,
          nowUtc: tehranLocal(2026, 11, 11, 1),
          prayerDay: real(tehran),
          resolver: resolver,
          location: tehran,
          count: 5,
        ),
        hasLength(1),
      );
    });

    test('a disabled alarm is null', () {
      expect(
        next(fixed4.copyWith(enabled: false), tehranLocal(2026, 11, 11)),
        isNull,
      );
    });
  });

  group('relative to a prayer', () {
    const fajr40 = WakeAlarm(
      id: 'f',
      trigger: AlarmTriggerKind.relativeToPrayer,
    );

    test('40 minutes before Fajr follows Fajr across 30 days', () {
      final lookup = real(tehran);
      final seen = <DateTime>[];
      for (var i = 0; i < 30; i++) {
        final date = CivilDate(2026, 11, 1).addDays(i);
        final day = lookup(date);
        final fajr = day.instants[Prayer.fajr]!;
        // Ask from just after local midnight so today's alarm is ahead.
        final result = next(
          fajr40,
          day.localMidnightUtc.add(const Duration(minutes: 1)),
        );
        expect(
          result!.instantUtc,
          fajr.subtract(const Duration(minutes: 40)),
          reason: 'day $date',
        );
        expect(result.date, date);
        seen.add(result.instantUtc);
      }
      // The local clock time of the alarm drifts through the month: it is
      // not a fixed time of day.
      final minutesOfDay = {
        for (final t in seen)
          t.add(const Duration(minutes: 210)).hour * 60 +
              t.add(const Duration(minutes: 210)).minute,
      };
      expect(minutesOfDay.length, greaterThan(10));
    });

    test('Fajr already passed today: the next day is used', () {
      final lookup = real(tehran);
      final today = lookup(CivilDate(2026, 11, 11));
      final result = next(fajr40, today.instants[Prayer.dhuhr]!);
      final tomorrow = lookup(CivilDate(2026, 11, 12));
      expect(
        result!.instantUtc,
        tomorrow.instants[Prayer.fajr]!.subtract(const Duration(minutes: 40)),
      );
    });

    test('across a DST change the alarm still follows the prayer', () {
      const london = ResolvedLocation(
        id: 'custom:2',
        nameFa: 'x',
        nameEn: 'x',
        latitude: 51.5,
        longitude: -0.12,
        elevationMeters: 0,
        zoneId: 'Europe/London',
        offset: LocationOffset.automatic(),
        isCustom: true,
      );
      final lookup = real(london);
      var now = DateTime.utc(2026, 10, 20);
      for (var i = 0; i < 14; i++) {
        final result = next(fajr40, now, lookup: lookup, location: london)!;
        final day = lookup(result.date);
        expect(
          result.instantUtc,
          day.instants[Prayer.fajr]!.subtract(const Duration(minutes: 40)),
        );
        now = result.instantUtc;
      }
    });

    test('a prayer that does not occur on some days is skipped', () {
      final lookup = stub(
        (date) => {
          // Fajr is missing on the 12th and the 13th (polar).
          Prayer.fajr: date.day == 12 || date.day == 13
              ? null
              : const Duration(hours: 5),
        },
      );
      final result = next(fajr40, tehranLocal(2026, 11, 11, 6), lookup: lookup);
      expect(result!.date, CivilDate(2026, 11, 14));
      expect(result.instantUtc, tehranLocal(2026, 11, 14, 4, 20));
    });

    test('a prayer that never occurs gives null (no endless search)', () {
      final lookup = stub((date) => {Prayer.fajr: null});
      expect(next(fajr40, tehranLocal(2026, 11, 11), lookup: lookup), isNull);
    });

    test('a real polar location with no adjustment can give null days', () {
      // Tromso in June, "none" high-latitude rule: twilight never ends.
      const tromso = ResolvedLocation(
        id: 'custom:3',
        nameFa: 'x',
        nameEn: 'x',
        latitude: 69.65,
        longitude: 18.96,
        elevationMeters: 0,
        zoneId: 'Asia/Tehran',
        offset: LocationOffset.fixed(120),
        isCustom: true,
      );
      final strict = CalculationSettings(
        params: calculation.params.copyWith(
          highLatitude: HighLatitudeRule.none,
        ),
      );
      PrayerDay day(CivilDate d) => computePrayerDay(
        date: d,
        location: tromso,
        calculation: strict,
        resolver: resolver,
      );
      final missing = day(CivilDate(2026, 6, 21)).instants[Prayer.fajr];
      expect(missing, isNull, reason: 'no Fajr at 70N at midsummer');
      final result = next(
        fajr40,
        DateTime.utc(2026, 6, 20),
        lookup: day,
        location: tromso,
      );
      // Whatever it finds, it is never a day without Fajr.
      if (result != null) {
        expect(
          day(result.date).instants[Prayer.fajr]!
              .subtract(const Duration(minutes: 40)),
          result.instantUtc,
        );
      }
    });

    test(
      'a prayer shortly after midnight: the alarm rings the evening before',
      () {
        // Fajr at 00:30 local; 40 minutes before is 23:50 of the previous day.
        final lookup = stub(
          (date) => {Prayer.fajr: const Duration(minutes: 30)},
        );
        final result = next(
          fajr40,
          tehranLocal(2026, 11, 11, 12),
          lookup: lookup,
        );
        expect(result!.instantUtc, tehranLocal(2026, 11, 11, 23, 50));
        // The ring date is the date on the wall clock, not the prayer's date.
        expect(result.date, CivilDate(2026, 11, 11));
      },
    );

    test('midnight crossing is checked against the date it rings on', () {
      // Mondays only. Fajr 00:30 on Tuesday -> rings Monday 23:50.
      const monday = WakeAlarm(
        id: 'm',
        trigger: AlarmTriggerKind.relativeToPrayer,
        repeat: AlarmRepeat.weekdays,
        weekdays: {DateTime.monday},
      );
      final lookup = stub((date) => {Prayer.fajr: const Duration(minutes: 30)});
      final result = next(
        monday,
        tehranLocal(2026, 11, 11, 12), // Wednesday
        lookup: lookup,
      );
      expect(result!.date, CivilDate(2026, 11, 16));
      expect(result.date.weekday, DateTime.monday);
      expect(result.instantUtc, tehranLocal(2026, 11, 16, 23, 50));
    });

    test('Isha after midnight belongs to the previous prayer day', () {
      // Isha at 25:00 of the 11th is 01:00 on the 12th; 10 minutes before is
      // 00:50. Asked at 00:10 on the 12th, the occurrence comes from the
      // PREVIOUS day's computation.
      const isha10 = WakeAlarm(
        id: 'i',
        trigger: AlarmTriggerKind.relativeToPrayer,
        prayer: Prayer.isha,
        minutesBefore: 10,
      );
      final lookup = stub((date) => {Prayer.isha: const Duration(hours: 25)});
      final result = next(
        isha10,
        tehranLocal(2026, 11, 12, 0, 10),
        lookup: lookup,
      );
      expect(result!.instantUtc, tehranLocal(2026, 11, 12, 0, 50));
      expect(result.date, CivilDate(2026, 11, 12));
    });

    test('minutes before changes the result one for one', () {
      final lookup = real(tehran);
      final fajr = lookup(CivilDate(2026, 11, 12)).instants[Prayer.fajr]!;
      for (final minutes in [0, 1, 40, 90]) {
        final result = next(
          fajr40.copyWith(minutesBefore: minutes),
          tehranLocal(2026, 11, 11, 12),
        );
        expect(result!.instantUtc, fajr.subtract(Duration(minutes: minutes)));
      }
    });
  });

  group('upcomingOccurrences', () {
    test('returns consecutive occurrences', () {
      final list = upcomingOccurrences(
        fixed4,
        nowUtc: tehranLocal(2026, 11, 11, 5),
        prayerDay: real(tehran),
        resolver: resolver,
        location: tehran,
        count: 3,
      );
      expect(list.map((o) => o.date.iso), [
        '2026-11-12',
        '2026-11-13',
        '2026-11-14',
      ]);
    });
  });

  group('buildWakePlan', () {
    WakeAlarmPlan plan(
      List<WakeAlarm> alarms,
      DateTime now, {
      Map<String, DateTime> editedAt = const {},
      Set<String> onceFired = const {},
      List<WakeOccurrence> extra = const [],
    }) => buildWakePlan(
      alarms: alarms,
      nowUtc: now,
      prayerDay: real(tehran),
      resolver: resolver,
      location: tehran,
      editedAt: editedAt,
      onceFired: onceFired,
      extra: extra,
    );

    test('a few minutes late the alarm is still in the engine list', () {
      final p = plan([fixed4], tehranLocal(2026, 11, 11, 4, 3));
      expect(p.engine.first.instantUtc, tehranLocal(2026, 11, 11, 4));
      // ...but the OS must wake for tomorrow.
      expect(p.upcoming['a']!.instantUtc, tehranLocal(2026, 11, 12, 4));
      expect(p.engine, hasLength(2));
    });

    test('more than the catch-up window late: only tomorrow is left', () {
      final p = plan([fixed4], tehranLocal(2026, 11, 11, 4, 30));
      expect(p.engine.first.instantUtc, tehranLocal(2026, 11, 12, 4));
    });

    test(
      'an alarm just created for a time that has passed does not ring now',
      () {
        final now = tehranLocal(2026, 11, 11, 4, 3);
        final p = plan([fixed4], now, editedAt: {'a': now});
        expect(p.engine.first.instantUtc, tehranLocal(2026, 11, 12, 4));
      },
    );

    test('disabled alarms and fired once alarms are left out', () {
      const once = WakeAlarm(id: 'o', repeat: AlarmRepeat.once);
      final p = plan(
        [fixed4.copyWith(enabled: false), once],
        tehranLocal(2026, 11, 11, 1),
        onceFired: {'o'},
      );
      expect(p.engine, isEmpty);
      expect(p.upcoming, isEmpty);
    });

    test('extra occurrences join the plan', () {
      final at = tehranLocal(2026, 11, 11, 1, 2);
      final extra = WakeOccurrence(
        alarmId: 'wake-test-1',
        instantUtc: at,
        date: CivilDate(2026, 11, 11),
      );
      final p = plan([], tehranLocal(2026, 11, 11, 1), extra: [extra]);
      expect(p.upcoming['wake-test-1'], extra);
      expect(p.engine, [extra]);
    });

    test('plans with the same content are equal', () {
      final now = tehranLocal(2026, 11, 11, 1);
      expect(plan([fixed4], now), plan([fixed4], now));
      expect(plan([fixed4], now), isNot(plan([fixed4.copyWith(hour: 5)], now)));
    });
  });
}
