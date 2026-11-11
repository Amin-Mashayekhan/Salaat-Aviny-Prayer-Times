import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/time/clock_warning.dart';
import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:prayer_core/prayer_core.dart';

/// The clock problem to show on the home screen, if any (D-1 / D-2).
final clockWarningProvider = Provider<ClockWarning?>((ref) {
  final location = ref.watch(activeLocationProvider);
  final resolver = ref.watch(zoneOffsetResolverProvider);
  final now = ref.watch(systemClockProvider).now().toUtc();
  final measured = ref.watch(clockCorrectionProvider.select((s) => s.offset));
  final automatic = location.offset.mode == OffsetMode.automatic;
  final expected = resolver.offsetFor(
    rule: location.offset,
    zoneId: location.zoneId,
    date: CivilDate.fromDateTime(now),
  );
  return evaluateClockWarning(
    measuredSkew: measured,
    windowsOffset: ref.watch(systemZoneProvider).localOffsetAt(now),
    expectedOffset: expected,
    automaticZone: automatic,
    isIranZone: location.zoneId == 'Asia/Tehran',
  );
});
