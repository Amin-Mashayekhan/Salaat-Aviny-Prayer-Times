/// A problem with the PC clock the user should hear about.
sealed class ClockWarning {
  const ClockWarning();
}

/// The PC clock is off by [skew] or more.
final class ClockSkewWarning extends ClockWarning {
  /// Creates the warning.
  const ClockSkewWarning(this.skew);

  /// Network time minus PC time.
  final Duration skew;
}

/// Windows applies a different UTC offset than the bundled database for
/// the selected location, typically because it still uses abolished
/// daylight-saving rules. The app times stay correct; the Windows clock is
/// the one that is off.
final class StaleZoneRulesWarning extends ClockWarning {
  /// Creates the warning.
  const StaleZoneRulesWarning({
    required this.windowsOffset,
    required this.expectedOffset,
  });

  /// Offset Windows applies now.
  final Duration windowsOffset;

  /// Offset of the location according to the bundled database.
  final Duration expectedOffset;
}

/// The skew from which the clock warning is shown.
const Duration clockSkewThreshold = Duration(seconds: 30);

/// Decides which warning, if any, to show.
///
/// - [measuredSkew]: network time minus PC time, null if never measured.
/// - [windowsOffset] and [expectedOffset]: offsets at the same instant.
/// - [automaticZone]: the active location uses the zone database (a stale-rules warning is
///   meaningless for a user-typed fixed offset).
/// - [isIranZone]: the active location is in `Asia/Tehran`.
ClockWarning? evaluateClockWarning({
  required Duration? measuredSkew,
  required Duration windowsOffset,
  required Duration expectedOffset,
  required bool automaticZone,
  required bool isIranZone,
}) {
  final stale =
      automaticZone &&
      (windowsOffset - expectedOffset).abs() == const Duration(hours: 1);
  final skew = measuredSkew;
  final shiftedAnHour =
      skew != null &&
      isIranZone &&
      (skew.abs() - const Duration(hours: 1)).abs() <=
          const Duration(minutes: 2);
  if (stale || shiftedAnHour) {
    return StaleZoneRulesWarning(
      windowsOffset: windowsOffset,
      expectedOffset: expectedOffset,
    );
  }
  if (skew != null && skew.abs() >= clockSkewThreshold) {
    return ClockSkewWarning(skew);
  }
  return null;
}
