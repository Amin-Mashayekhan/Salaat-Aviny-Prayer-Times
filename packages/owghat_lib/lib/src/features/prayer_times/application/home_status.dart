import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

/// The quick-mute choices of the status card (and the tray).
enum MuteOption {
  /// Until the next azan.
  untilNextPrayer,

  /// For one hour.
  oneHour,

  /// For 24 hours.
  twentyFourHours,

  /// Until the user turns it back on.
  indefinite,

  /// Remove the mute.
  cancel,
}

/// The [MuteSetting] that [option] stands for, to hand to
/// `SettingsController.setMute`.
///
/// [nextAzan] is the instant of the next azan; [MuteOption.untilNextPrayer]
/// returns null (not offered) when it is unknown.
MuteSetting? muteSettingFor(
  MuteOption option, {
  required DateTime now,
  required DateTime? nextAzan,
}) => switch (option) {
  MuteOption.untilNextPrayer =>
    nextAzan == null ? null : MuteSetting(until: nextAzan.toUtc()),
  MuteOption.oneHour => MuteSetting(
    until: now.toUtc().add(const Duration(hours: 1)),
  ),
  MuteOption.twentyFourHours => MuteSetting(
    until: now.toUtc().add(const Duration(hours: 24)),
  ),
  MuteOption.indefinite => const MuteSetting(indefinite: true),
  MuteOption.cancel => MuteSetting.none,
};

/// The instant of the next azan after [now]: the next of the prayers whose
/// azan is switched on, or of any of the five if none is.
DateTime? nextAzanInstant({
  required Iterable<Map<Prayer, DateTime>> days,
  required AzanSettings azan,
  required DateTime now,
}) {
  DateTime? find(bool Function(Prayer) wanted) {
    DateTime? best;
    for (final day in days) {
      for (final entry in day.entries) {
        if (!wanted(entry.key) || !entry.value.isAfter(now)) continue;
        if (best == null || entry.value.isBefore(best)) best = entry.value;
      }
    }
    return best;
  }

  final enabled = azan.enabledPrayers;
  return find(enabled.contains) ?? find((p) => p.hasAzan);
}

/// The next azan instant at the active location.
final nextAzanInstantProvider = Provider<DateTime?>((ref) {
  final days = ref.watch(prayerDaysAroundTodayProvider);
  return nextAzanInstant(
    days: [for (final d in days) d.instants],
    azan: ref.watch(settingsProvider.select((s) => s.azan)),
    now: ref.watch(nowProvider),
  );
});

/// Summary of the reminder settings for the status card.
@immutable
class ReminderSummary {
  /// Creates a summary.
  const ReminderSummary({this.minMinutes, this.maxMinutes});

  /// Smallest non-zero lead time, null when reminders are off.
  final int? minMinutes;

  /// Largest lead time, null when reminders are off.
  final int? maxMinutes;

  /// Whether every reminder is off.
  bool get isOff => minMinutes == null;

  /// Whether all reminders use the same lead time.
  bool get isUniform => minMinutes == maxMinutes;

  @override
  bool operator ==(Object other) =>
      other is ReminderSummary &&
      other.minMinutes == minMinutes &&
      other.maxMinutes == maxMinutes;

  @override
  int get hashCode => Object.hash(minMinutes, maxMinutes);
}

/// Summarises [reminders] over the five prayers.
ReminderSummary summarizeReminders(ReminderSettings reminders) {
  final values = [
    for (final minutes in reminders.minutesBefore.values)
      if (minutes > 0) minutes,
  ];
  if (values.isEmpty) return const ReminderSummary();
  values.sort();
  return ReminderSummary(minMinutes: values.first, maxMinutes: values.last);
}

/// Index 0 to 7 of the eight-point compass (north, north-east, ... north-west)
/// of [bearing] degrees.
int compassIndex(double bearing) => ((bearing + 22.5) % 360) ~/ 45;

/// Qibla bearing and compass point at the active location.
@immutable
class QiblaSummary {
  /// Creates a summary.
  const QiblaSummary({required this.bearing, required this.compassIndex});

  /// Degrees clockwise from true north.
  final double bearing;

  /// Eight-point compass index, 0 = north.
  final int compassIndex;

  @override
  bool operator ==(Object other) =>
      other is QiblaSummary &&
      other.bearing == bearing &&
      other.compassIndex == compassIndex;

  @override
  int get hashCode => Object.hash(bearing, compassIndex);
}

/// The qibla summary of the active location.
final qiblaSummaryProvider = Provider<QiblaSummary>((ref) {
  final location = ref.watch(activeLocationProvider);
  final bearing = qiblaBearing(location.latitude, location.longitude);
  return QiblaSummary(bearing: bearing, compassIndex: compassIndex(bearing));
});
