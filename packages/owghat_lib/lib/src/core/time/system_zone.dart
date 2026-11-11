/// The UTC offset the operating system applies at an instant.
abstract interface class SystemZone {
  /// Offset of the Windows local time zone at the UTC [instant].
  Duration localOffsetAt(DateTime instant);
}

/// [SystemZone] backed by the Dart runtime (which asks the OS).
class DartSystemZone implements SystemZone {
  /// Creates the system zone.
  const DartSystemZone();

  @override
  Duration localOffsetAt(DateTime instant) =>
      DateTime.fromMicrosecondsSinceEpoch(
        instant.toUtc().microsecondsSinceEpoch,
        isUtc: true,
      ).toLocal().timeZoneOffset;
}
