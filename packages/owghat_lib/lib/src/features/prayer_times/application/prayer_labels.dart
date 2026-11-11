import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:prayer_core/prayer_core.dart';

/// Display names of the prayers (glossary of `docs/05-UI-UX-SPEC.md` §6).
///
/// Prayer identity is always the [Prayer] enum; text comes from here only.
extension PrayerLabels on Prayer {
  /// The localised name.
  String label(AppLocalizations l10n) => switch (this) {
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
}
