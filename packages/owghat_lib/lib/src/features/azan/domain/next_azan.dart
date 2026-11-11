import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:prayer_core/prayer_core.dart';

/// The instant of the next azan that is switched on, or null if none of
/// [days] holds one after [now].
///
/// [enabled] is `AzanSettings.enabledPrayers`; [days] should cover today and
/// tomorrow so that the answer exists after the last prayer of the day.
DateTime? nextAzanInstant({
  required Iterable<PrayerDay> days,
  required Set<Prayer> enabled,
  required DateTime now,
}) {
  DateTime? best;
  for (final day in days) {
    for (final entry in day.instants.entries) {
      if (!enabled.contains(entry.key)) continue;
      final instant = entry.value;
      if (!instant.isAfter(now)) continue;
      if (best == null || instant.isBefore(best)) best = instant;
    }
  }
  return best;
}
