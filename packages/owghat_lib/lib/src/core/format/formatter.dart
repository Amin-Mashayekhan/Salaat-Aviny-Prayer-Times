import 'package:flutter/foundation.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';

/// Turns numbers, clock times and durations into display text.
///
/// One class does every conversion (digits, decimal separator, 12/24 hour,
/// duration words) so that no screen formats a number on its own. The
/// instance is immutable; the app builds it from the settings (see
/// `formatterProvider`).
@immutable
class Formatter {
  /// Creates a formatter.
  ///
  /// [persianDigits] selects the Persian digits and decimal separator,
  /// [twelveHour] the 12-hour clock, [l10n] supplies the words (AM/PM and
  /// the duration phrases).
  const Formatter({
    required this.persianDigits,
    required this.twelveHour,
    required this.l10n,
  });

  /// Whether digits are shown as Persian digits.
  final bool persianDigits;

  /// Whether times use the 12-hour clock.
  final bool twelveHour;

  /// Localised words.
  final AppLocalizations l10n;

  /// Unicode left-to-right isolate.
  static const String lri = '\u2066';

  /// Unicode right-to-left isolate.
  static const String rli = '\u2067';

  /// Unicode pop directional isolate.
  static const String pdi = '\u2069';

  /// Persian decimal separator.
  static const String persianDecimalSeparator = '\u066B';

  /// Wraps [text] in a left-to-right isolate so that times and Latin
  /// fragments never render reversed inside right-to-left text.
  static String isolate(String text) => '$lri$text$pdi';

  /// Replaces the digits of [text] with the configured style (Persian or
  /// Latin); other characters are unchanged.
  String digits(String text) {
    final out = StringBuffer();
    for (final rune in text.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        out.writeCharCode(persianDigits ? 0x06f0 + rune - 0x30 : rune);
      } else if (rune >= 0x06f0 && rune <= 0x06f9) {
        out.writeCharCode(persianDigits ? rune : 0x30 + rune - 0x06f0);
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        out.writeCharCode(
          persianDigits ? 0x06f0 + rune - 0x0660 : 0x30 + rune - 0x0660,
        );
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }

  /// A whole or decimal number: [fractionDigits] places, the configured
  /// digits and decimal separator, a real minus sign for negatives.
  String formatNumber(num value, {int fractionDigits = 0}) {
    final negative = value < 0;
    var text = value.abs().toStringAsFixed(fractionDigits);
    if (persianDigits) text = text.replaceAll('.', persianDecimalSeparator);
    final result = digits(text);
    // A rounded negative zero ("-0") is shown without the sign.
    final isZero = !RegExp('[1-9۱-۹]').hasMatch(result);
    return negative && !isZero ? '−$result' : result;
  }

  /// A number with at least [width] digits, padded with zeros.
  String formatPadded(int value, {int width = 2}) =>
      digits(value.toString().padLeft(width, '0'));

  /// The clock time [afterMidnight] (values of 24 hours or more wrap to the
  /// next day) as `HH:MM`, or `h:MM AM` on the 12-hour clock.
  String formatTime(Duration afterMidnight) {
    final minutesOfDay = afterMidnight.inMinutes % Duration.minutesPerDay;
    final hour = minutesOfDay ~/ 60;
    final minute = minutesOfDay % 60;
    if (!twelveHour) {
      return '${formatPadded(hour)}:${formatPadded(minute)}';
    }
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour < 12 ? l10n.formatAm : l10n.formatPm;
    return '${formatNumber(h12)}:${formatPadded(minute)} $suffix';
  }

  /// The local clock time of the UTC [instant] where the UTC offset is
  /// [utcOffset].
  String formatInstant(DateTime instant, Duration utcOffset) {
    final local = instant.toUtc().add(utcOffset);
    return formatTime(Duration(hours: local.hour, minutes: local.minute));
  }

  /// `HH:MM:SS` of [remaining] (hours may exceed two digits). Partial
  /// seconds round up, so a countdown never shows 00:00:00 before the event.
  /// Negative durations show as zero.
  String formatCountdown(Duration remaining) {
    final total = _ceilSeconds(remaining);
    final hours = total ~/ 3600;
    final minutes = total % 3600 ~/ 60;
    final seconds = total % 60;
    return '${formatPadded(hours)}:${formatPadded(minutes)}:'
        '${formatPadded(seconds)}';
  }

  /// A length of time in words, without direction: "1 h 23 min".
  ///
  /// Hours and minutes; below one minute it shows seconds.
  String formatDuration(Duration value) {
    final total = _ceilSeconds(value);
    final hours = total ~/ 3600;
    final minutes = total % 3600 ~/ 60;
    if (hours > 0 && minutes > 0) {
      return l10n.formatHoursMinutes(
        formatNumber(hours),
        formatNumber(minutes),
      );
    }
    if (hours > 0) return l10n.formatHours(formatNumber(hours));
    if (total >= 60) return l10n.formatMinutes(formatNumber(minutes));
    return l10n.formatSeconds(formatNumber(total));
  }

  /// Time still to wait, in words: "1 h 23 min from now" (Persian
  /// "1 ساعت و 23 دقیقه دیگر"). Seconds are dropped, the phrase changes only
  /// when the minute does.
  String formatDurationWords(Duration remaining) {
    final total = _ceilSeconds(remaining);
    if (total < 60) return l10n.formatRemainingLessThan(formatNumber(1));
    return l10n.formatRemaining(
      formatDuration(Duration(seconds: total - total % 60)),
    );
  }

  static int _ceilSeconds(Duration value) {
    if (value.isNegative) return 0;
    return (value.inMicroseconds / Duration.microsecondsPerSecond).ceil();
  }
}
