import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

Formatter fa({bool persian = true, bool twelve = false}) => Formatter(
  persianDigits: persian,
  twelveHour: twelve,
  l10n: lookupAppLocalizations(const Locale('fa')),
);

Formatter en({bool persian = false, bool twelve = false}) => Formatter(
  persianDigits: persian,
  twelveHour: twelve,
  l10n: lookupAppLocalizations(const Locale('en')),
);

void main() {
  group('digits and numbers', () {
    test('Persian digits and decimal separator', () {
      expect(fa().formatNumber(218.4, fractionDigits: 1), '۲۱۸٫۴');
      expect(fa().formatNumber(0), '۰');
      expect(fa().digits('17:20 abc 5'), '۱۷:۲۰ abc ۵');
    });

    test('Latin digits keep the dot and convert Persian input', () {
      expect(en().formatNumber(218.4, fractionDigits: 1), '218.4');
      expect(en().digits('۱۷:۲۰'), '17:20');
    });

    test('negative numbers use a real minus, never -0', () {
      expect(en().formatNumber(-2), '−2');
      expect(fa().formatNumber(-3.5, fractionDigits: 1), '−۳٫۵');
      expect(en().formatNumber(-0.01, fractionDigits: 1), '0.0');
    });
  });

  group('formatTime', () {
    const t = Duration(hours: 17, minutes: 20);

    test('24 hour, Persian and Latin digits', () {
      expect(fa().formatTime(t), '۱۷:۲۰');
      expect(en().formatTime(t), '17:20');
      expect(fa().formatTime(const Duration(hours: 5, minutes: 10)), '۰۵:۱۰');
    });

    test('12 hour in both languages', () {
      expect(en(twelve: true).formatTime(t), '5:20 PM');
      expect(
        en(twelve: true).formatTime(const Duration(minutes: 5)),
        '12:05 AM',
      );
      expect(
        en(twelve: true).formatTime(const Duration(hours: 12)),
        '12:00 PM',
      );
      expect(fa(twelve: true).formatTime(t), '۵:۲۰ ب.ظ');
      expect(
        fa(twelve: true).formatTime(const Duration(hours: 5, minutes: 10)),
        '۵:۱۰ ق.ظ',
      );
    });

    test('values of 24 hours or more wrap to the next day', () {
      expect(en().formatTime(const Duration(hours: 24, minutes: 30)), '00:30');
    });

    test('formatInstant applies the UTC offset', () {
      final instant = DateTime.utc(2026, 11, 11, 13, 50);
      expect(
        en().formatInstant(instant, const Duration(hours: 3, minutes: 30)),
        '17:20',
      );
    });
  });

  group('formatCountdown', () {
    test('HH:MM:SS', () {
      const d = Duration(hours: 1, minutes: 23, seconds: 45);
      expect(fa().formatCountdown(d), '۰۱:۲۳:۴۵');
      expect(en().formatCountdown(d), '01:23:45');
    });

    test('partial seconds round up and negatives are zero', () {
      expect(
        en().formatCountdown(const Duration(milliseconds: 1500)),
        '00:00:02',
      );
      expect(
        en().formatCountdown(const Duration(milliseconds: -5)),
        '00:00:00',
      );
      expect(en().formatCountdown(const Duration(hours: 100)), '100:00:00');
    });
  });

  group('durations in words', () {
    const d = Duration(hours: 1, minutes: 23, seconds: 45);

    test('Persian', () {
      expect(fa().formatDurationWords(d), '۱ ساعت و ۲۳ دقیقه دیگر');
      expect(fa().formatDurationWords(const Duration(hours: 2)), '۲ ساعت دیگر');
      expect(
        fa().formatDurationWords(const Duration(minutes: 5, seconds: 1)),
        '۵ دقیقه دیگر',
      );
      expect(
        fa().formatDurationWords(const Duration(seconds: 20)),
        'کمتر از ۱ دقیقه دیگر',
      );
    });

    test('English', () {
      expect(en().formatDurationWords(d), 'in 1 h 23 min');
      expect(en().formatDurationWords(const Duration(hours: 2)), 'in 2 h');
      expect(
        en().formatDurationWords(const Duration(seconds: 20)),
        'in less than 1 min',
      );
    });

    test(
      'formatDuration has no direction and shows seconds below a minute',
      () {
        expect(en().formatDuration(d), '1 h 23 min');
        expect(en().formatDuration(const Duration(seconds: 45)), '45 s');
        expect(fa().formatDuration(const Duration(seconds: 45)), '۴۵ ثانیه');
      },
    );
  });

  test('isolate wraps text in a left-to-right isolate', () {
    final text = Formatter.isolate('17:20');
    expect(text.codeUnitAt(0), 0x2066);
    expect(text.codeUnitAt(text.length - 1), 0x2069);
    expect(text.substring(1, text.length - 1), '17:20');
  });

  group('formatterProvider follows the settings', () {
    Formatter read(AppSettings settings) {
      final container = ProviderContainer(
        overrides: [initialSettingsProvider.overrideWithValue(settings)],
      );
      addTearDown(container.dispose);
      return container.read(formatterProvider);
    }

    test('defaults: Persian digits, 24 hour', () {
      final f = read(const AppSettings.defaults());
      expect(f.formatTime(const Duration(hours: 17, minutes: 20)), '۱۷:۲۰');
    });

    test('English, Latin digits, 12 hour', () {
      final f = read(
        const AppSettings(
          language: AppLanguage.en,
          digits: DigitStyle.latin,
          hourFormat: HourFormat.h12,
        ),
      );
      expect(f.formatTime(const Duration(hours: 17, minutes: 20)), '5:20 PM');
    });

    test('changing a setting changes the formatter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(formatterProvider).formatNumber(7), '۷');
      container.read(settingsProvider.notifier).setDigits(DigitStyle.latin);
      expect(container.read(formatterProvider).formatNumber(7), '7');
    });
  });
}
