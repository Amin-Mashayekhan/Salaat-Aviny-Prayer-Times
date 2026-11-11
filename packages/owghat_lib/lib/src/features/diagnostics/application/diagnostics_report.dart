import 'package:owghat_lib/src/core/time/clock_warning.dart';
import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:prayer_core/prayer_core.dart';

/// Number of scheduled events the diagnostics list.
const int diagnosticsEventCount = 10;

/// Formats a UTC offset as `UTC+03:30`.
String formatUtcOffset(Duration offset) {
  final minutes = offset.inMinutes;
  final sign = minutes < 0 ? '-' : '+';
  final abs = minutes.abs();
  return 'UTC$sign${_two(abs ~/ 60)}:${_two(abs % 60)}';
}

/// `2026-11-11 12:00:00` (no fraction, so the text never looks like a
/// precise coordinate).
String formatTimestamp(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${_two(value.month)}-'
    '${_two(value.day)} ${_two(value.hour)}:${_two(value.minute)}:'
    '${_two(value.second)}';

String _two(int value) => value.toString().padLeft(2, '0');

/// The next [diagnosticsEventCount] user-visible events after [now]: azan,
/// reminders and wake-up alarms, sorted by time (day-rollover markers are
/// internal and left out).
List<ScheduledEvent> nextDiagnosticEvents(
  Iterable<ScheduledEvent> events,
  DateTime now,
) {
  final list = [
    for (final event in events)
      if (event.kind != EventKind.dayRollover && event.instantUtc.isAfter(now))
        event,
  ]..sort((a, b) => a.instantUtc.compareTo(b.instantUtc));
  return list.take(diagnosticsEventCount).toList();
}

/// Builds the plain-text report behind the "Copy diagnostics" button.
///
/// PRIVACY: the report holds no personal data. It has no location name, no
/// alarm names or ids, no file names, no network-time server, no raw error
/// text and nothing typed by the user. Coordinates are rounded to two
/// decimals (about one kilometre). The user name in the log folder path is
/// replaced. English only: it is meant to be pasted into a bug report.
String buildDiagnosticsReport({
  required String version,
  required DateTime nowUtc,
  required AppSettings settings,
  required ResolvedLocation location,
  required Duration offsetNow,
  required ClockWarning? clockWarning,
  required WakeCapability? wakeCapability,
  required int armedWakeRequests,
  required List<ScheduledEvent> events,
  required Duration Function(DateTime instant) offsetAt,
  String? logDirectory,
}) {
  final out = StringBuffer()
    ..writeln('Owghat diagnostics')
    ..writeln('Generated: ${formatTimestamp(nowUtc)} UTC')
    ..writeln('App version: $version')
    ..writeln(
      'Language: ${settings.language.name}, digits: ${settings.digits.name}, '
      'clock: ${settings.hourFormat.name}',
    )
    ..writeln()
    ..writeln('Location (coordinates rounded to 2 decimals)')
    ..writeln('  Latitude: ${location.latitude.toStringAsFixed(2)}')
    ..writeln('  Longitude: ${location.longitude.toStringAsFixed(2)}')
    ..writeln('  Elevation: ${location.elevationMeters.round()} m')
    ..writeln('  User-defined: ${location.isCustom ? 'yes' : 'no'}');
  final rule = location.offset;
  out
    ..writeln(
      rule.mode == OffsetMode.fixed
          ? '  Time zone: fixed offset ${rule.fixedMinutes} min east of UTC'
          : '  Time zone: ${location.zoneId} (automatic)',
    )
    ..writeln('  Offset now: ${formatUtcOffset(offsetNow)}');

  final params = settings.calculation.params;
  final isha = params.ishaAngle != null
      ? '${params.ishaAngle} deg'
      : '${params.ishaMinutes} min after Maghrib';
  out
    ..writeln()
    ..writeln('Calculation')
    ..writeln(
      '  Fajr ${params.fajrAngle} deg, '
      'Maghrib ${params.maghribAngle == null ? 'sunset' : '${params.maghribAngle} deg'}, '
      'Isha $isha, midnight ${params.midnight.name}, Asr ${params.asr.name}, '
      'high latitude ${params.highLatitude.name}, '
      'Imsak ${params.imsakMinutes} min',
    )
    ..writeln('  Hijri adjustment: ${settings.hijriAdjustmentDays} days')
    ..writeln()
    ..writeln('Clock')
    ..writeln('  Status: ${_clockStatus(clockWarning)}')
    ..writeln(
      '  Network time check: ${settings.networkTime.enabled ? 'on' : 'off'}',
    )
    ..writeln()
    ..writeln('Azan and reminders')
    ..writeln(
      '  Azan: ${settings.azan.enabled ? 'on' : 'off'}, '
      'muted now: ${settings.azan.mute.isActiveAt(nowUtc) ? 'yes' : 'no'}',
    )
    ..writeln()
    ..writeln('Wake-up')
    ..writeln(
      '  Alarms: ${settings.wakeAlarms.length} saved, '
      '${settings.wakeAlarms.where((a) => a.enabled).length} on, '
      '$armedWakeRequests wake requests registered',
    );
  final capability = wakeCapability;
  if (capability == null) {
    out.writeln('  Capability: not checked');
  } else {
    final issues = capability.issues.isEmpty
        ? 'none'
        : capability.issues.map((i) => i.name).join(', ');
    out
      ..writeln(
        '  Capability: task=${_tri(capability.taskCreationOk)} '
        'plugged-in=${capability.wakeTimersOnAc.name} '
        'battery=${capability.wakeTimersOnBattery.name} '
        'in-app-timer=${capability.inProcessTimerOk} '
        'modern-standby=${_tri(capability.modernStandby)}',
      )
      ..writeln('  Issues: $issues');
  }

  out
    ..writeln()
    ..writeln('Log folder: ${anonymisePath(logDirectory) ?? 'not available'}')
    ..writeln()
    ..writeln('Next ${events.length} scheduled events (UTC | local)');
  if (events.isEmpty) out.writeln('  (nothing scheduled)');
  for (var i = 0; i < events.length; i++) {
    final event = events[i];
    final name = switch (event.kind) {
      EventKind.azan => 'azan ${event.prayer?.name ?? ''}',
      EventKind.reminder => 'reminder ${event.prayer?.name ?? ''}',
      EventKind.wakeAlarm => 'wake-up alarm',
      EventKind.dayRollover => 'day rollover',
    };
    final offset = offsetAt(event.instantUtc);
    final local = event.instantUtc.add(offset);
    out.writeln(
      '  ${i + 1}. ${name.trim()}: ${formatTimestamp(event.instantUtc)} UTC | '
      '${formatTimestamp(local)} (${formatUtcOffset(offset)})',
    );
  }
  return out.toString();
}

String _tri(bool? value) => value == null ? 'unknown' : '$value';

String _clockStatus(ClockWarning? warning) => switch (warning) {
  null => 'no problem found',
  ClockSkewWarning(:final skew) =>
    'D-1 clock skew of about ${skew.abs().inSeconds} s',
  StaleZoneRulesWarning(:final windowsOffset, :final expectedOffset) =>
    'D-2 Windows uses ${formatUtcOffset(windowsOffset)} but the time-zone '
        'database says ${formatUtcOffset(expectedOffset)}',
};

/// Replaces the user name in `...\Users\<name>\...` and `/home/<name>/`.
String? anonymisePath(String? path) {
  if (path == null || path.isEmpty) return null;
  return path
      .replaceAllMapped(
        RegExp(r'([\\/]Users[\\/])[^\\/]+', caseSensitive: false),
        (m) => '${m[1]}<user>',
      )
      .replaceAllMapped(RegExp('(/home/)[^/]+'), (m) => '${m[1]}<user>');
}
