import 'package:prayer_core/prayer_core.dart';
import 'package:test/test.dart';

void main() {
  test('roundTimesToMinute rounds every non-null time', () {
    final rounded = roundTimesToMinute(
      PrayerTimes({
        Prayer.fajr: const Duration(hours: 5, minutes: 10, seconds: 40),
        Prayer.dhuhr: const Duration(hours: 12, minutes: 1, seconds: 10),
      }),
    );
    expect(rounded[Prayer.fajr], const Duration(hours: 5, minutes: 11));
    expect(rounded[Prayer.dhuhr], const Duration(hours: 12, minutes: 1));
    expect(rounded[Prayer.isha], isNull);
  });

  test('equal values have equal hash codes and readable strings', () {
    final p1 = CalculationMethod.tehran.params;
    final p2 = CalculationMethod.tehran.params.copyWith();
    expect(p1, p2);
    expect(p1.hashCode, p2.hashCode);
    expect(p1.toString(), contains('17.7'));

    expect(CivilDate(2026, 3, 21).hashCode, CivilDate(2026, 3, 21).hashCode);
    expect(CivilDate(2026, 3, 21).toString(), '2026-03-21');

    final t1 = PrayerTimes({Prayer.fajr: const Duration(hours: 5)});
    final t2 = PrayerTimes({Prayer.fajr: const Duration(hours: 5)});
    expect(t1.hashCode, t2.hashCode);
    expect(t1.toString(), startsWith('PrayerTimes('));
    expect(t1, isNot('fajr'));
  });

  test('events with the same id and instant are equal', () {
    final date = CivilDate(2026, 11, 11);
    final instant = DateTime.utc(2026, 11, 11, 8, 18);
    final a = ScheduledEvent(
      kind: EventKind.azan,
      instantUtc: instant,
      date: date,
      prayer: Prayer.dhuhr,
    );
    final b = ScheduledEvent(
      kind: EventKind.azan,
      instantUtc: instant,
      date: date,
      prayer: Prayer.dhuhr,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a.toString(), contains('azan:dhuhr:2026-11-11'));
    expect(
      a,
      isNot(
        ScheduledEvent(
          kind: EventKind.azan,
          instantUtc: instant.add(const Duration(minutes: 1)),
          date: date,
          prayer: Prayer.dhuhr,
        ),
      ),
    );
  });

  test('events at the same instant sort by kind, then id', () {
    final date = CivilDate(2026, 11, 11);
    final instant = DateTime.utc(2026, 11, 11, 8, 18);
    final events = const ScheduleBuilder().build(
      instantsByDate: {
        date: {Prayer.dhuhr: instant},
      },
      azanEnabled: {Prayer.dhuhr},
      alarms: [
        AlarmOccurrence(alarmId: 'b', instantUtc: instant, date: date),
        AlarmOccurrence(alarmId: 'a', instantUtc: instant, date: date),
      ],
    );
    expect(events.map((e) => e.id), [
      'azan:dhuhr:2026-11-11',
      'wakeAlarm:a:2026-11-11',
      'wakeAlarm:b:2026-11-11',
    ]);
  });
}
