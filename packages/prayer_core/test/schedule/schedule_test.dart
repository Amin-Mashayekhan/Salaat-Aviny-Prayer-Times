import 'package:prayer_core/prayer_core.dart';
import 'package:test/test.dart';

void main() {
  final day = CivilDate(2026, 11, 11);
  final nextDay = day.addDays(1);

  Map<Prayer, DateTime> instantsOf(CivilDate date, DateTime base) => {
    Prayer.imsak: base.add(const Duration(hours: 1, minutes: 30)),
    Prayer.fajr: base.add(const Duration(hours: 1, minutes: 40)),
    Prayer.sunrise: base.add(const Duration(hours: 3)),
    Prayer.dhuhr: base.add(const Duration(hours: 8, minutes: 18)),
    Prayer.asr: base.add(const Duration(hours: 11, minutes: 9)),
    Prayer.sunset: base.add(const Duration(hours: 13, minutes: 30)),
    Prayer.maghrib: base.add(const Duration(hours: 13, minutes: 50)),
    Prayer.isha: base.add(const Duration(hours: 14, minutes: 38)),
  };

  final base = DateTime.utc(2026, 11, 11);

  group('ScheduleBuilder', () {
    const builder = ScheduleBuilder();

    test('builds azan events only for enabled prayers with an azan', () {
      final events = builder.build(
        instantsByDate: {day: instantsOf(day, base)},
        azanEnabled: {Prayer.fajr, Prayer.maghrib, Prayer.sunrise},
      );
      // sunrise has no azan even though it was passed as "enabled".
      expect(events.map((e) => e.id), [
        'azan:fajr:2026-11-11',
        'azan:maghrib:2026-11-11',
      ]);
    });

    test('a reminder is the azan minus N minutes and links to it', () {
      final events = builder.build(
        instantsByDate: {day: instantsOf(day, base)},
        azanEnabled: {Prayer.maghrib},
        reminderMinutes: {Prayer.maghrib: 10, Prayer.fajr: 10},
      );
      expect(events.map((e) => e.id), [
        'reminder:maghrib:2026-11-11',
        'azan:maghrib:2026-11-11',
      ]);
      final reminder = events.first;
      expect(
        reminder.instantUtc,
        base.add(const Duration(hours: 13, minutes: 40)),
      );
      expect(
        reminder.relatedInstantUtc,
        base.add(const Duration(hours: 13, minutes: 50)),
      );
    });

    test('zero minutes means no reminder', () {
      final events = builder.build(
        instantsByDate: {day: instantsOf(day, base)},
        azanEnabled: {Prayer.maghrib},
        reminderMinutes: {Prayer.maghrib: 0},
      );
      expect(events.length, 1);
    });

    test('alarms and rollovers are included and everything is sorted', () {
      final events = builder.build(
        instantsByDate: {
          nextDay: instantsOf(nextDay, base.add(const Duration(days: 1))),
          day: instantsOf(day, base),
        },
        azanEnabled: {Prayer.fajr},
        alarms: [
          AlarmOccurrence(
            alarmId: 'a1',
            instantUtc: base.add(const Duration(hours: 1)),
            date: day,
          ),
        ],
        rolloverByDate: {nextDay: base.add(const Duration(hours: 20))},
      );
      expect(events.map((e) => e.id), [
        'wakeAlarm:a1:2026-11-11',
        'azan:fajr:2026-11-11',
        'dayRollover:day:2026-11-12',
        'azan:fajr:2026-11-12',
      ]);
      for (var i = 1; i < events.length; i++) {
        expect(
          events[i].instantUtc.isBefore(events[i - 1].instantUtc),
          isFalse,
        );
      }
    });

    test('ids are stable across rebuilds', () {
      List<String> ids() => builder
          .build(
            instantsByDate: {day: instantsOf(day, base)},
            azanEnabled: {Prayer.fajr, Prayer.dhuhr},
            reminderMinutes: {Prayer.fajr: 5},
          )
          .map((e) => e.id)
          .toList();
      expect(ids(), ids());
    });

    test('an empty input gives no events', () {
      expect(
        builder.build(instantsByDate: const {}, azanEnabled: const {}),
        isEmpty,
      );
    });
  });

  group('CatchUpPolicy.decide', () {
    const policy = CatchUpPolicy();
    final azanAt = DateTime.utc(2026, 11, 11, 10);
    final azan = ScheduledEvent(
      kind: EventKind.azan,
      instantUtc: azanAt,
      date: day,
      prayer: Prayer.dhuhr,
    );

    CatchUpDecision at(Duration late, {Set<String> handled = const {}}) =>
        policy.decide(azan, azanAt.add(late), handled);

    test('not due before the instant', () {
      expect(at(const Duration(seconds: -1)), CatchUpDecision.notYetDue);
    });

    test('on time within the tolerance', () {
      expect(at(Duration.zero), CatchUpDecision.fire);
      expect(at(const Duration(seconds: 5)), CatchUpDecision.fire);
    });

    test('late but inside the grace plays late', () {
      expect(at(const Duration(seconds: 6)), CatchUpDecision.fireLate);
      expect(at(const Duration(minutes: 3)), CatchUpDecision.fireLate);
    });

    test('later than the grace is only announced as missed', () {
      expect(
        at(const Duration(minutes: 3, seconds: 1)),
        CatchUpDecision.notifyMissed,
      );
      expect(at(const Duration(hours: 6)), CatchUpDecision.notifyMissed);
    });

    test('handled events are never handled again', () {
      expect(
        at(Duration.zero, handled: {azan.id}),
        CatchUpDecision.alreadyHandled,
      );
    });

    test('a reminder is useful only while its azan is still ahead', () {
      final reminder = ScheduledEvent(
        kind: EventKind.reminder,
        instantUtc: azanAt.subtract(const Duration(minutes: 10)),
        date: day,
        prayer: Prayer.dhuhr,
        relatedInstantUtc: azanAt,
      );
      expect(
        policy.decide(
          reminder,
          azanAt.subtract(const Duration(minutes: 10)),
          {},
        ),
        CatchUpDecision.fire,
      );
      expect(
        policy.decide(
          reminder,
          azanAt.subtract(const Duration(minutes: 4)),
          {},
        ),
        CatchUpDecision.fireLate,
      );
      expect(policy.decide(reminder, azanAt, {}), CatchUpDecision.drop);
      expect(
        policy.decide(reminder, azanAt.add(const Duration(hours: 1)), {}),
        CatchUpDecision.drop,
      );
    });

    test('a wake alarm is run up to ten minutes late, then dropped', () {
      final alarm = ScheduledEvent(
        kind: EventKind.wakeAlarm,
        instantUtc: azanAt,
        date: day,
        alarmId: 'a1',
      );
      expect(
        policy.decide(alarm, azanAt.add(const Duration(minutes: 10)), {}),
        CatchUpDecision.fireLate,
      );
      expect(
        policy.decide(alarm, azanAt.add(const Duration(minutes: 11)), {}),
        CatchUpDecision.drop,
      );
    });

    test('the day rollover always fires when due', () {
      final rollover = ScheduledEvent(
        kind: EventKind.dayRollover,
        instantUtc: azanAt,
        date: day,
      );
      expect(
        policy.decide(rollover, azanAt.add(const Duration(days: 2)), {}),
        CatchUpDecision.fire,
      );
    });
  });

  group('CatchUpPolicy.decideAll', () {
    const policy = CatchUpPolicy(azanGrace: Duration(hours: 10));

    ScheduledEvent azanOf(Prayer prayer, DateTime at) => ScheduledEvent(
      kind: EventKind.azan,
      instantUtc: at,
      date: day,
      prayer: prayer,
    );

    test('of several playable azans only the most recent plays', () {
      final fajr = azanOf(Prayer.fajr, DateTime.utc(2026, 11, 11, 1, 40));
      final dhuhr = azanOf(Prayer.dhuhr, DateTime.utc(2026, 11, 11, 8, 18));
      final now = DateTime.utc(2026, 11, 11, 9);
      final decisions = policy.decideAll([fajr, dhuhr], now, {});
      expect(decisions[dhuhr.id], CatchUpDecision.fireLate);
      expect(decisions[fajr.id], CatchUpDecision.notifyMissed);
    });

    test('future and handled events are untouched', () {
      final fajr = azanOf(Prayer.fajr, DateTime.utc(2026, 11, 11, 1, 40));
      final asr = azanOf(Prayer.asr, DateTime.utc(2026, 11, 11, 11, 9));
      final now = DateTime.utc(2026, 11, 11, 9);
      final decisions = policy.decideAll([fajr, asr], now, {fajr.id});
      expect(decisions[fajr.id], CatchUpDecision.alreadyHandled);
      expect(decisions[asr.id], CatchUpDecision.notYetDue);
    });

    test('an on-time azan stays "fire" next to missed ones', () {
      final fajr = azanOf(Prayer.fajr, DateTime.utc(2026, 11, 11, 1, 40));
      final dhuhr = azanOf(Prayer.dhuhr, DateTime.utc(2026, 11, 11, 8, 18));
      final decisions = policy.decideAll([fajr, dhuhr], dhuhr.instantUtc, {});
      expect(decisions[dhuhr.id], CatchUpDecision.fire);
      expect(decisions[fajr.id], CatchUpDecision.notifyMissed);
    });
  });
}
