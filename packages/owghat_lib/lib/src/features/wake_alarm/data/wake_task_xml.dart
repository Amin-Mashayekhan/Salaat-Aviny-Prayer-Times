import 'dart:typed_data';

/// Folder and name prefix of every task this app creates.
const String wakeTaskFolder = 'Salaat';

/// Name prefix of a wake task inside [wakeTaskFolder].
const String wakeTaskPrefix = 'Wake-';

final RegExp _safeId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$');

/// Whether [id] can be used in a task name and on a command line without
/// quoting. Ids the app generates always qualify.
bool isSafeWakeId(String id) => _safeId.hasMatch(id);

/// The task name (without the leading backslash) for alarm [id].
///
/// Throws [ArgumentError] for an id that is not [isSafeWakeId].
String wakeTaskName(String id) {
  if (!isSafeWakeId(id)) {
    throw ArgumentError.value(id, 'id', 'not usable in a task name');
  }
  return '$wakeTaskFolder\\$wakeTaskPrefix$id';
}

/// The task name of the throw-away task used by the capability probe.
const String wakeProbeTaskName = '$wakeTaskFolder\\Probe';

/// How the one-time trigger's `StartBoundary` is written.
enum StartBoundaryStyle {
  /// `2026-11-12T00:30:00Z`: an absolute instant, independent of the Windows
  /// time-zone rules (so a Windows with stale daylight-saving rules cannot
  /// shift the alarm). First choice.
  utc,

  /// Local wall time with an explicit offset, `2026-11-12T04:00:00+03:30`.
  localWithOffset,

  /// Local wall time without any zone, `2026-11-12T04:00:00`: Task Scheduler
  /// interprets it with the Windows zone rules. Last-resort fallback.
  localFloating,
}

String _two(int v) => v.toString().padLeft(2, '0');

/// Formats [startUtc] for a `StartBoundary` element.
///
/// For the two local styles [localOffset] is the offset to apply (east of
/// UTC); it is required for them.
String formatStartBoundary(
  DateTime startUtc, {
  StartBoundaryStyle style = StartBoundaryStyle.utc,
  Duration? localOffset,
}) {
  final utc = startUtc.toUtc();
  String stamp(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${_two(t.month)}-${_two(t.day)}'
      'T${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
  switch (style) {
    case StartBoundaryStyle.utc:
      return '${stamp(utc)}Z';
    case StartBoundaryStyle.localWithOffset:
    case StartBoundaryStyle.localFloating:
      if (localOffset == null) {
        throw ArgumentError.notNull('localOffset');
      }
      final local = utc.add(localOffset);
      if (style == StartBoundaryStyle.localFloating) return stamp(local);
      final minutes = localOffset.inMinutes;
      final sign = minutes < 0 ? '-' : '+';
      final abs = minutes.abs();
      return '${stamp(local)}$sign${_two(abs ~/ 60)}:${_two(abs % 60)}';
  }
}

/// ISO 8601 duration for the task schema; zero is `PT0S` ("no limit").
String formatTaskDuration(Duration value) {
  if (value <= Duration.zero) return 'PT0S';
  final hours = value.inHours;
  final minutes = value.inMinutes % 60;
  final seconds = value.inSeconds % 60;
  return 'PT${hours > 0 ? '${hours}H' : ''}'
      '${minutes > 0 ? '${minutes}M' : ''}'
      '${seconds > 0 ? '${seconds}S' : ''}';
}

String _escape(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');

/// The Task Scheduler XML of a one-time wake task.
///
/// Matches `docs/03-ARCHITECTURE.md` section 6: `WakeToRun`, a one-time
/// `TimeTrigger`, `InteractiveToken` + `LeastPrivilege` (no elevation), and
/// an action that starts [executablePath] with `--wake <alarmId>`.
///
/// - `MultipleInstancesPolicy=Parallel` because the process the task starts
///   is the app itself and stays alive; a later wake must still start (the
///   second process hands `--wake` to the first and exits).
/// - [executionTimeLimit] defaults to "no limit" for the same reason: a limit
///   would let Task Scheduler kill the app it just started.
/// - `StartWhenAvailable` runs the task when the PC comes back after missing
///   the time; the schedule engine drops alarms that are more than 10 minutes
///   late.
///
/// The XML is UTF-16 (see [encodeUtf16LeWithBom]).
String buildWakeTaskXml({
  required String alarmId,
  required DateTime startUtc,
  required String executablePath,
  String? workingDirectory,
  StartBoundaryStyle style = StartBoundaryStyle.utc,
  Duration? localOffset,
  Duration executionTimeLimit = Duration.zero,
}) {
  if (!isSafeWakeId(alarmId)) {
    throw ArgumentError.value(alarmId, 'alarmId', 'not usable in a task');
  }
  if (executablePath.trim().isEmpty) {
    throw ArgumentError.value(executablePath, 'executablePath', 'is empty');
  }
  final boundary = formatStartBoundary(
    startUtc,
    style: style,
    localOffset: localOffset,
  );
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-16"?>')
    ..writeln(
      '<Task version="1.2" '
      'xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">',
    )
    ..writeln('  <RegistrationInfo>')
    ..writeln('    <Description>Salaat wake-up alarm</Description>')
    ..writeln('  </RegistrationInfo>')
    ..writeln('  <Triggers>')
    ..writeln('    <TimeTrigger>')
    ..writeln('      <StartBoundary>${_escape(boundary)}</StartBoundary>')
    ..writeln('      <Enabled>true</Enabled>')
    ..writeln('    </TimeTrigger>')
    ..writeln('  </Triggers>')
    ..writeln('  <Principals>')
    ..writeln('    <Principal id="Author">')
    ..writeln('      <LogonType>InteractiveToken</LogonType>')
    ..writeln('      <RunLevel>LeastPrivilege</RunLevel>')
    ..writeln('    </Principal>')
    ..writeln('  </Principals>')
    ..writeln('  <Settings>')
    ..writeln('    <MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>')
    ..writeln(
      '    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>',
    )
    ..writeln('    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>')
    ..writeln('    <AllowHardTerminate>true</AllowHardTerminate>')
    ..writeln('    <StartWhenAvailable>true</StartWhenAvailable>')
    ..writeln(
      '    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>',
    )
    ..writeln('    <AllowStartOnDemand>true</AllowStartOnDemand>')
    ..writeln('    <Enabled>true</Enabled>')
    ..writeln('    <Hidden>false</Hidden>')
    ..writeln('    <RunOnlyIfIdle>false</RunOnlyIfIdle>')
    ..writeln('    <WakeToRun>true</WakeToRun>')
    ..writeln(
      '    <ExecutionTimeLimit>${formatTaskDuration(executionTimeLimit)}'
      '</ExecutionTimeLimit>',
    )
    ..writeln('    <Priority>5</Priority>')
    ..writeln('  </Settings>')
    ..writeln('  <Actions Context="Author">')
    ..writeln('    <Exec>')
    ..writeln('      <Command>${_escape('"$executablePath"')}</Command>')
    ..writeln('      <Arguments>--wake $alarmId</Arguments>');
  if (workingDirectory != null && workingDirectory.isNotEmpty) {
    buffer.writeln(
      '      <WorkingDirectory>${_escape(workingDirectory)}'
      '</WorkingDirectory>',
    );
  }
  buffer
    ..writeln('    </Exec>')
    ..writeln('  </Actions>')
    ..writeln('</Task>');
  return buffer.toString();
}

/// Encodes [text] as UTF-16 little-endian with a byte-order mark, the form
/// `schtasks /Create /XML` expects for a file that declares
/// `encoding="UTF-16"`.
Uint8List encodeUtf16LeWithBom(String text) {
  final units = text.codeUnits;
  final bytes = Uint8List(2 + units.length * 2);
  bytes[0] = 0xFF;
  bytes[1] = 0xFE;
  for (var i = 0; i < units.length; i++) {
    bytes[2 + i * 2] = units[i] & 0xFF;
    bytes[3 + i * 2] = (units[i] >> 8) & 0xFF;
  }
  return bytes;
}
