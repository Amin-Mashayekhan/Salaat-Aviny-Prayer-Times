import 'package:flutter/widgets.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/core/platform/app_notifier.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

/// Builds the user-visible texts of notifications and the tray, in the
/// language, digit style and clock style of the settings.
///
/// All words come from the ARB files (`docs/05-UI-UX-SPEC.md` section 5);
/// numbers and times go through the shared [Formatter]. This class only
/// fills in names, times and numbers.
class NoticeTexts {
  /// Creates a text builder.
  const NoticeTexts({
    required this.l10n,
    required this.formatter,
    required this.language,
  });

  /// A builder following the language, digits and clock of [settings].
  factory NoticeTexts.fromSettings(AppSettings settings) {
    final l10n = lookupAppLocalizations(Locale(settings.language.name));
    return NoticeTexts(
      l10n: l10n,
      formatter: Formatter(
        persianDigits: settings.digits == DigitStyle.persian,
        twelveHour: settings.hourFormat == HourFormat.h12,
        l10n: l10n,
      ),
      language: settings.language,
    );
  }

  /// The localised strings.
  final AppLocalizations l10n;

  /// Digits, times and durations.
  final Formatter formatter;

  /// The UI language.
  final AppLanguage language;

  /// The glossary name of [prayer].
  String prayerName(Prayer prayer) => switch (prayer) {
    Prayer.imsak => l10n.prayerImsak,
    Prayer.fajr => l10n.prayerFajr,
    Prayer.sunrise => l10n.prayerSunrise,
    Prayer.dhuhr => l10n.prayerDhuhr,
    Prayer.asr => l10n.prayerAsr,
    Prayer.sunset => l10n.prayerSunset,
    Prayer.maghrib => l10n.prayerMaghrib,
    Prayer.isha => l10n.prayerIsha,
    Prayer.midnight => l10n.prayerMidnight,
  };

  /// A whole number in the chosen digit style.
  String number(int value) => formatter.formatNumber(value);

  /// The wall-clock time of the UTC [instant] at a zone [offset], e.g.
  /// `۱۷:۲۰`. Latin digits inside Persian text are isolated so that the
  /// time never renders reversed.
  String clock(DateTime instant, Duration offset) {
    final text = formatter.formatInstant(instant, offset);
    final needsIsolate = language == AppLanguage.fa && !formatter.persianDigits;
    return needsIsolate ? Formatter.isolate(text) : text;
  }

  /// The time left, in words: `1 ساعت و 23 دقیقه دیگر`.
  String remaining(Duration left) => formatter.formatDurationWords(left);

  /// Toast for an azan. [withStop] adds the Stop button (only while the
  /// azan really plays).
  NotificationSpec azan({
    required Prayer prayer,
    required String place,
    required String time,
    required bool withStop,
  }) => NotificationSpec(
    tag: 'azan',
    title: l10n.notifAzanTitle(prayerName(prayer)),
    body: l10n.notifAzanBody(place, time),
    buttons: [
      if (withStop)
        NotificationButton(
          kind: NotificationActionKind.stop,
          label: l10n.notifStopAction,
        ),
    ],
  );

  /// Quiet toast `10 minutes to Maghrib`.
  NotificationSpec reminder({
    required Prayer prayer,
    required int minutes,
    required String place,
    required String time,
  }) => NotificationSpec(
    tag: 'reminder',
    title: l10n.notifReminderTitle(number(minutes), prayerName(prayer)),
    body: l10n.notifReminderBody(place, time),
  );

  /// Quiet toast for an azan that was not played.
  NotificationSpec missed({required Prayer prayer, required String time}) =>
      NotificationSpec(
        tag: 'missed',
        title: l10n.notifMissedTitle(prayerName(prayer)),
        body: l10n.notifMissedBody(time),
      );

  /// Notice that the chosen sound was missing and the default played.
  NotificationSpec soundFallback() => NotificationSpec(
    tag: 'audio-problem',
    title: l10n.appName,
    body: l10n.notifSoundFallback,
  );

  /// Notice that the azan could not be played at all.
  NotificationSpec azanFailed() => NotificationSpec(
    tag: 'audio-problem',
    title: l10n.appName,
    body: l10n.notifAzanFailed,
  );

  /// The one-time hint shown the first time the window hides to the tray.
  NotificationSpec trayHint() => NotificationSpec(
    tag: 'tray-hint',
    title: l10n.appName,
    body: l10n.notifTrayHint,
  );
}
