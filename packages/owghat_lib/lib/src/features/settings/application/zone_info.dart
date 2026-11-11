import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// The UTC offset a location uses today and the next change, read from the
/// time-zone database or from the fixed rule. Nothing here is a setting.
@immutable
class OffsetInEffect {
  /// Creates the description.
  const OffsetInEffect({
    required this.current,
    required this.fixed,
    this.nextChangeAt,
    this.nextOffset,
  });

  /// The offset in effect now.
  final Duration current;

  /// The location uses a fixed offset (it never changes).
  final bool fixed;

  /// UTC instant of the next change in the database, if any.
  final DateTime? nextChangeAt;

  /// The offset after [nextChangeAt].
  final Duration? nextOffset;

  @override
  bool operator ==(Object other) =>
      other is OffsetInEffect &&
      other.current == current &&
      other.fixed == fixed &&
      other.nextChangeAt == nextChangeAt &&
      other.nextOffset == nextOffset;

  @override
  int get hashCode => Object.hash(current, fixed, nextChangeAt, nextOffset);
}

/// Describes the offset of ([rule], [zoneId]) at the UTC instant [now].
OffsetInEffect describeOffset({
  required ZoneOffsetResolver resolver,
  required LocationOffset rule,
  required String zoneId,
  required DateTime now,
}) {
  if (rule.mode == OffsetMode.fixed) {
    return OffsetInEffect(
      current: Duration(minutes: rule.fixedMinutes ?? 0),
      fixed: true,
    );
  }
  if (!resolver.knowsZone(zoneId)) {
    return const OffsetInEffect(current: Duration.zero, fixed: false);
  }
  final next = resolver.nextOffsetChange(zoneId, now);
  return OffsetInEffect(
    current: resolver.offsetAt(zoneId, now),
    fixed: false,
    nextChangeAt: next?.at,
    nextOffset: next?.after,
  );
}

/// "UTC+03:30" with the digits of [fmt], isolated so that it never renders
/// reversed inside right-to-left text.
String formatUtcOffset(Formatter fmt, Duration offset) {
  final minutes = offset.inMinutes.abs();
  final sign = offset.isNegative ? '−' : '+';
  final hh = (minutes ~/ 60).toString().padLeft(2, '0');
  final mm = (minutes % 60).toString().padLeft(2, '0');
  return Formatter.isolate(fmt.digits('UTC$sign$hh:$mm'));
}

/// Rounds [minutes] to the nearest quarter of an hour and clamps it to the
/// range a fixed offset may have.
int roundToQuarterHour(int minutes) => ((minutes / 15).round() * 15).clamp(
  LocationOffset.minFixedMinutes,
  LocationOffset.maxFixedMinutes,
);

/// The current time truncated to the minute (so listeners rebuild once a
/// minute, not once a second).
final settingsNowMinuteProvider = Provider<DateTime>((ref) {
  final now = ref.watch(nowProvider);
  return DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);
});

/// The offset in effect for the saved location with the given id.
// The family type is not exported under a stable name in Riverpod 3.
// ignore: specify_nonobvious_property_types
final offsetInEffectProvider = Provider.family<OffsetInEffect, String>((
  ref,
  locationId,
) {
  final locations = ref.watch(settingsProvider.select((s) => s.locations));
  final now = ref.watch(settingsNowMinuteProvider);
  final resolver = ref.watch(zoneOffsetResolverProvider);
  for (final location in locations) {
    if (location.id == locationId) {
      return describeOffset(
        resolver: resolver,
        rule: location.offset,
        zoneId: location.zoneId,
        now: now,
      );
    }
  }
  return const OffsetInEffect(current: Duration.zero, fixed: false);
});
