import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/time/second_ticker.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/next_prayer.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// The current time (UTC), ticking once per second.
final nowTickProvider = StreamProvider<DateTime>(
  (ref) => secondTicks(ref.watch(clockProvider)),
);

/// The current time (UTC): the latest tick, or the clock before the first.
final nowProvider = Provider<DateTime>((ref) {
  final tick = ref.watch(nowTickProvider);
  return tick.value ?? ref.read(clockProvider).now().toUtc();
});

/// Today in the active location. Only notifies when the date changes.
final todayProvider = Provider<CivilDate>((ref) {
  final now = ref.watch(nowProvider);
  final location = ref.watch(activeLocationProvider);
  final resolver = ref.watch(zoneOffsetResolverProvider);
  final offset = resolver.currentOffset(
    rule: location.offset,
    zoneId: location.zoneId,
    instant: now,
  );
  return resolver.civilDateAt(now, offset);
});

/// The prayer times of one civil date at the active location.
// The family type is not exported under a stable name in Riverpod 3.
// ignore: specify_nonobvious_property_types
final prayerDayProvider = Provider.family<PrayerDay, CivilDate>((ref, date) {
  return computePrayerDay(
    date: date,
    location: ref.watch(activeLocationProvider),
    calculation: ref.watch(settingsProvider.select((s) => s.calculation)),
    resolver: ref.watch(zoneOffsetResolverProvider),
  );
});

/// Yesterday, today and tomorrow, in that order.
final prayerDaysAroundTodayProvider = Provider<List<PrayerDay>>((ref) {
  final today = ref.watch(todayProvider);
  return [
    ref.watch(prayerDayProvider(today.addDays(-1))),
    ref.watch(prayerDayProvider(today)),
    ref.watch(prayerDayProvider(today.addDays(1))),
  ];
});

/// The current period and the next event, updated every second.
final nextPrayerProvider = Provider<NextPrayerState>((ref) {
  return computeNextPrayer(
    days: ref.watch(prayerDaysAroundTodayProvider),
    display: ref.watch(settingsProvider.select((s) => s.display)),
    now: ref.watch(nowProvider),
  );
});
