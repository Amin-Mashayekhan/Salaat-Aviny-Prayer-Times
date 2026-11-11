import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';

/// The UTC offset in effect at the active location at a given instant (the
/// location zone, never the Windows zone). Used to show clock times of
/// instants such as alarms and scheduled events.
final localOffsetAtProvider = Provider<Duration Function(DateTime instant)>((
  ref,
) {
  final location = ref.watch(activeLocationProvider);
  final resolver = ref.watch(zoneOffsetResolverProvider);
  return (instant) => resolver.currentOffset(
    rule: location.offset,
    zoneId: location.zoneId,
    instant: instant,
  );
});
