import 'dart:math' as math;

import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_status.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_view.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/next_prayer.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/sky_palette.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/test_data.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('sky palette', () {
    test('every period maps from the latest passed event', () {
      expect(skyPeriodOf(null), SkyPeriod.night);
      expect(skyPeriodOf(Prayer.fajr), SkyPeriod.dawn);
      expect(skyPeriodOf(Prayer.sunrise), SkyPeriod.day);
      expect(skyPeriodOf(Prayer.asr), SkyPeriod.day);
      expect(skyPeriodOf(Prayer.sunset), SkyPeriod.dusk);
      expect(skyPeriodOf(Prayer.maghrib), SkyPeriod.dusk);
      expect(skyPeriodOf(Prayer.isha), SkyPeriod.night);
      expect(skyPeriodOf(Prayer.midnight), SkyPeriod.night);
    });

    test('white text keeps 4.5:1 on every gradient stop (scrim applied)', () {
      for (final colors in [AppColors.light, AppColors.dark]) {
        for (final period in SkyPeriod.values) {
          for (final stop in SkyStyle.gradient(colors, period)) {
            expect(
              _contrast(SkyStyle.onSky, stop),
              greaterThanOrEqualTo(4.5),
              reason: '$period $stop',
            );
          }
        }
      }
    });
  });

  group('home target date and view', () {
    late ResolvedLocation tehran;
    final resolver = ZoneOffsetResolver();

    setUpAll(() async {
      final repo = await loadTestRepository();
      tehran = ResolvedLocation.from(AppSettings.defaultLocation, repo)!;
    });

    PrayerDay day(CivilDate date) => computePrayerDay(
      date: date,
      location: tehran,
      calculation: const CalculationSettings(),
      resolver: resolver,
    );

    NextPrayerState stateAt(DateTime now, {DisplaySettings? display}) =>
        computeNextPrayer(
          days: [
            day(CivilDate(2026, 11, 10)),
            day(CivilDate(2026, 11, 11)),
            day(CivilDate(2026, 11, 12)),
          ],
          display: display ?? const DisplaySettings(),
          now: now,
        );

    final today = CivilDate(2026, 11, 11);

    test('today stays today while an event is left', () {
      final state = stateAt(DateTime.utc(2026, 11, 11, 12));
      final target = homeTargetDate(
        today: today,
        viewed: null,
        next: state.next,
      );
      expect(target.date, today);
      expect(target.kind, HomeDayKind.today);
    });

    test('after the last event the list is tomorrow', () {
      final state = stateAt(DateTime.utc(2026, 11, 11, 20));
      final target = homeTargetDate(
        today: today,
        viewed: null,
        next: state.next,
      );
      expect(target.date, CivilDate(2026, 11, 12));
      expect(target.kind, HomeDayKind.tomorrow);
    });

    test('a viewed day wins; viewing today is just today', () {
      final state = stateAt(DateTime.utc(2026, 11, 11, 12));
      expect(
        homeTargetDate(
          today: today,
          viewed: CivilDate(2026, 11, 20),
          next: state.next,
        ).kind,
        HomeDayKind.other,
      );
      expect(
        homeTargetDate(today: today, viewed: today, next: state.next).kind,
        HomeDayKind.today,
      );
    });

    test('rows, passed and next flags, timeline fractions', () {
      final now = DateTime.utc(2026, 11, 11, 12); // 15:30 local
      final view = buildHomeView(
        day: day(today),
        kind: HomeDayKind.today,
        state: stateAt(now),
        display: const DisplaySettings(),
        now: now,
      );
      expect(
        [for (final r in view.rows) r.prayer],
        [
          Prayer.fajr,
          Prayer.sunrise,
          Prayer.dhuhr,
          Prayer.asr,
          Prayer.sunset,
          Prayer.maghrib,
          Prayer.isha,
          Prayer.midnight,
        ],
      );
      expect({
        for (final r in view.rows) r.prayer: r.passed,
      }, containsPair(Prayer.asr, true));
      expect(view.rows.where((r) => r.isNext).single.prayer, Prayer.sunset);
      expect(view.rows.where((r) => r.passed).length, 4);
      expect(view.dots.first.fraction, 0);
      expect(view.dots.last.fraction, 1);
      expect(view.dots.last.prayer, Prayer.midnight);
      expect(view.nowFraction, inExclusiveRange(0.4, 0.8));
      expect(view.remaining, const Duration(hours: 1, minutes: 30));
      expect(view.isLive, isTrue);
      expect(view.hasMissingTimes, isFalse);
    });

    test('browsing another day has no next, no passed rows, no now marker', () {
      final now = DateTime.utc(2026, 11, 11, 12);
      final view = buildHomeView(
        day: day(CivilDate(2026, 11, 12)),
        kind: HomeDayKind.other,
        state: stateAt(now),
        display: const DisplaySettings(),
        now: now,
      );
      expect(view.next, isNull);
      expect(view.nowFraction, isNull);
      expect(view.rows.any((r) => r.passed || r.isNext), isFalse);
      expect(view.isLive, isFalse);
      expect(view.remaining, Duration.zero);
    });
  });

  group('mute options', () {
    final now = DateTime.utc(2026, 11, 11, 12);
    final next = DateTime.utc(2026, 11, 11, 13, 50);

    test('each option maps to the matching mute setting', () {
      expect(
        muteSettingFor(MuteOption.untilNextPrayer, now: now, nextAzan: next),
        MuteSetting(until: next),
      );
      expect(
        muteSettingFor(MuteOption.oneHour, now: now, nextAzan: next),
        MuteSetting(until: now.add(const Duration(hours: 1))),
      );
      expect(
        muteSettingFor(MuteOption.twentyFourHours, now: now, nextAzan: next),
        MuteSetting(until: now.add(const Duration(hours: 24))),
      );
      expect(
        muteSettingFor(MuteOption.indefinite, now: now, nextAzan: next),
        const MuteSetting(indefinite: true),
      );
      expect(
        muteSettingFor(MuteOption.cancel, now: now, nextAzan: next),
        MuteSetting.none,
      );
    });

    test('until next prayer is unavailable without a next azan', () {
      expect(
        muteSettingFor(MuteOption.untilNextPrayer, now: now, nextAzan: null),
        isNull,
      );
    });

    test('the next azan skips prayers whose azan is off', () {
      final days = [
        {
          Prayer.asr: DateTime.utc(2026, 11, 11, 11, 9),
          Prayer.maghrib: next,
          Prayer.isha: DateTime.utc(2026, 11, 11, 14, 38),
        },
      ];
      expect(
        nextAzanInstant(days: days, azan: const AzanSettings(), now: now),
        next,
      );
      // Everything off: any of the five counts.
      expect(
        nextAzanInstant(
          days: days,
          azan: const AzanSettings(enabled: false),
          now: now,
        ),
        next,
      );
    });
  });

  group('status summaries', () {
    test('reminder summary', () {
      expect(
        summarizeReminders(const ReminderSettings()),
        const ReminderSummary(minMinutes: 10, maxMinutes: 10),
      );
      expect(summarizeReminders(const ReminderSettings()).isUniform, isTrue);
      expect(
        summarizeReminders(
          const ReminderSettings(
            minutesBefore: {Prayer.fajr: 5, Prayer.asr: 0, Prayer.maghrib: 15},
          ),
        ),
        const ReminderSummary(minMinutes: 5, maxMinutes: 15),
      );
      expect(
        summarizeReminders(
          const ReminderSettings(minutesBefore: {Prayer.fajr: 0}),
        ).isOff,
        isTrue,
      );
    });

    test('compass points', () {
      expect(compassIndex(0), 0);
      expect(compassIndex(359), 0);
      expect(compassIndex(44), 1);
      expect(compassIndex(90), 2);
      expect(compassIndex(218.4), 5);
      expect(compassIndex(337.4), 7);
      expect(compassIndex(337.6), 0);
    });
  });
}
