// The collaborators keep private fields while the named parameters stay public.
// ignore_for_file: prefer_initializing_formals
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/wake_task_xml.dart';

/// The result of running an external command.
class CommandResult {
  /// Creates a result.
  const CommandResult({
    required this.exitCode,
    this.stdout = '',
    this.stderr = '',
  });

  /// Process exit code (0 is success).
  final int exitCode;

  /// Standard output.
  final String stdout;

  /// Standard error.
  final String stderr;

  /// Whether the command succeeded.
  bool get ok => exitCode == 0;

  /// The most useful error text.
  String get errorText {
    final text = stderr.trim().isNotEmpty ? stderr : stdout;
    return text.trim();
  }
}

/// Runs [executable] with [arguments] without a shell. The Windows build uses
/// `Process.run`; tests use a recording fake.
typedef CommandRunner = Future<CommandResult> Function(
  String executable,
  List<String> arguments,
);

/// `schtasks /Create` for [taskName] from the XML file [xmlPath].
List<String> schtasksCreateArgs({
  required String taskName,
  required String xmlPath,
}) => ['/Create', '/TN', taskName, '/XML', xmlPath, '/F'];

/// `schtasks /Delete` for [taskName].
List<String> schtasksDeleteArgs(String taskName) => [
  '/Delete',
  '/TN',
  taskName,
  '/F',
];

/// `schtasks /Query` of one task.
List<String> schtasksQueryOneArgs(String taskName) => [
  '/Query',
  '/TN',
  taskName,
  '/FO',
  'LIST',
];

/// `schtasks /Query` of every task, as CSV without a header row. The first
/// column is the full task name, which does not depend on the Windows
/// language.
List<String> schtasksQueryAllArgs() => ['/Query', '/FO', 'CSV', '/NH'];

/// Alarm ids of the wake tasks listed in the output of
/// [schtasksQueryAllArgs].
Set<String> parseWakeTaskIds(String csv) {
  final ids = <String>{};
  const prefix = '\\$wakeTaskFolder\\$wakeTaskPrefix';
  for (final line in csv.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('"')) continue;
    final end = trimmed.indexOf('"', 1);
    if (end < 0) continue;
    final name = trimmed.substring(1, end);
    if (name.startsWith(prefix) && name.length > prefix.length) {
      final id = name.substring(prefix.length);
      if (isSafeWakeId(id)) ids.add(id);
    }
  }
  return ids;
}

/// Creates, removes and lists the per-user Task Scheduler tasks that wake the
/// PC. Everything goes through the injected runner, so it is fully testable.
class SchtasksWakeScheduler {
  /// Creates the scheduler.
  ///
  /// - [executablePath]: the app exe the task starts with `--wake <id>`.
  /// - [tempDirectory]: where the XML is written before registration.
  /// - [localOffsetAt]: the Windows local offset at an instant; only used by
  ///   the fallback styles of the trigger.
  SchtasksWakeScheduler({
    required CommandRunner run,
    required String executablePath,
    required String tempDirectory,
    required Duration Function(DateTime utc) localOffsetAt,
    String? workingDirectory,
  }) : _run = run,
       _exe = executablePath,
       _temp = tempDirectory,
       _localOffsetAt = localOffsetAt,
       _workingDirectory = workingDirectory;

  static final Logger _log = Logger('SchtasksWakeScheduler');

  final CommandRunner _run;
  final String _exe;
  final String _temp;
  final Duration Function(DateTime utc) _localOffsetAt;
  final String? _workingDirectory;

  /// Registers (or replaces) the task of alarm [id] to start at [startUtc].
  ///
  /// Tries the absolute UTC form of the trigger first and, if Task Scheduler
  /// rejects it, the local forms. Returns null on success, otherwise the
  /// error text of the last attempt.
  Future<String?> register(String id, DateTime startUtc) async {
    final name = wakeTaskName(id);
    String? lastError;
    for (final style in StartBoundaryStyle.values) {
      final offset = style == StartBoundaryStyle.utc
          ? null
          : _localOffsetAt(startUtc);
      final xml = buildWakeTaskXml(
        alarmId: id,
        startUtc: startUtc,
        executablePath: _exe,
        workingDirectory: _workingDirectory,
        style: style,
        localOffset: offset,
      );
      final error = await _registerXml(name, id, xml);
      if (error == null) {
        if (style != StartBoundaryStyle.utc) {
          _log.info('Task $name registered with the ${style.name} trigger');
        }
        return null;
      }
      lastError = error;
      _log.warning('schtasks /Create with ${style.name} failed: $error');
    }
    return lastError;
  }

  Future<String?> _registerXml(String name, String id, String xml) async {
    final file = File('$_temp${Platform.pathSeparator}owghat-wake-$id.xml');
    try {
      await file.writeAsBytes(encodeUtf16LeWithBom(xml), flush: true);
      final result = await _run(
        'schtasks',
        schtasksCreateArgs(taskName: name, xmlPath: file.path),
      );
      return result.ok ? null : result.errorText;
    } on Object catch (error) {
      return error.toString();
    } finally {
      try {
        if (file.existsSync()) file.deleteSync();
      } on Object catch (error) {
        _log.fine('Could not remove ${file.path}: $error');
      }
    }
  }

  /// Removes the task of alarm [id]. Returns null on success (also when the
  /// task did not exist), otherwise the error text.
  Future<String?> remove(String id) async {
    final name = wakeTaskName(id);
    try {
      final result = await _run('schtasks', schtasksDeleteArgs(name));
      if (result.ok) return null;
      // The error text is localised, so ask instead: if the task is gone the
      // delete already did its job.
      final probe = await _run('schtasks', schtasksQueryOneArgs(name));
      return probe.ok ? result.errorText : null;
    } on Object catch (error) {
      return error.toString();
    }
  }

  /// Alarm ids that currently have a wake task.
  Future<Set<String>> listIds() async {
    final result = await _run('schtasks', schtasksQueryAllArgs());
    if (!result.ok) return const {};
    return parseWakeTaskIds(result.stdout);
  }

  /// Creates and removes a throw-away task far in the future to learn whether
  /// the current user may create tasks. Returns null when it works, otherwise
  /// the error text.
  Future<String?> probeCreate(DateTime farFutureUtc) async {
    final xml = buildWakeTaskXml(
      alarmId: 'probe',
      startUtc: farFutureUtc,
      executablePath: _exe,
      workingDirectory: _workingDirectory,
    );
    final error = await _registerXml(wakeProbeTaskName, 'probe', xml);
    if (error != null) return error;
    try {
      await _run('schtasks', schtasksDeleteArgs(wakeProbeTaskName));
    } on Object catch (error) {
      _log.warning('Could not remove the probe task: $error');
    }
    return null;
  }
}
