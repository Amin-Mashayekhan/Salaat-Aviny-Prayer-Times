// The collaborators keep private fields while the named parameters stay public.
// ignore_for_file: prefer_initializing_formals
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/powercfg_parser.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/schtasks.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/wake_task_xml.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_services.dart';

/// The second wake mechanism: a timer inside the running process that the OS
/// is allowed to wake the PC for (Windows: `SetWaitableTimer` with
/// `fResume = TRUE`). Implemented with FFI in the app package.
abstract interface class InProcessWakeTimer {
  /// Whether such a timer can be created here.
  Future<bool> probe();

  /// Arms the timer [id] for [utc], replacing an earlier one with that id.
  /// Throws if it cannot be armed.
  Future<void> schedule(String id, DateTime utc);

  /// Disarms the timer [id]; no error if there is none.
  Future<void> cancel(String id);

  /// Disarms every timer.
  Future<void> cancelAll();
}

/// Keeps the machine awake (Windows: `SetThreadExecutionState`).
abstract interface class AwakeHold {
  /// Starts holding the system and the display awake.
  void hold();

  /// Releases the hold.
  void release();
}

/// A [WakeTimerService] built from the two wake mechanisms, the awake hold and
/// the read-only `powercfg` probe. All operating-system access goes through
/// the injected parts, so this class is testable on any machine.
///
/// An alarm is armed with BOTH mechanisms: the Task Scheduler task survives
/// the app being closed, the in-process timer works even if the task could not
/// be created. [scheduleWake] only fails when neither could be armed.
class CompositeWakeTimerService implements WakeTimerService {
  /// Creates the service. [tasks] is null when the app path is unknown.
  CompositeWakeTimerService({
    required CommandRunner run,
    required InProcessWakeTimer timer,
    required AwakeHold awake,
    required Future<bool> Function() openPowerOptionsAction,
    SchtasksWakeScheduler? tasks,
  }) : _run = run,
       _timer = timer,
       _awake = awake,
       _open = openPowerOptionsAction,
       _tasks = tasks;

  static final Logger _log = Logger('CompositeWakeTimerService');

  final CommandRunner _run;
  final InProcessWakeTimer _timer;
  final AwakeHold _awake;
  final Future<bool> Function() _open;
  final SchtasksWakeScheduler? _tasks;

  String? _lastError;

  /// The most recent failure text of a probe or of arming a wake, if any.
  String? get lastError => _lastError;

  @override
  Future<WakeCapability> probe() async {
    String? error;

    bool? taskOk;
    final tasks = _tasks;
    if (tasks == null) {
      taskOk = false;
      error = 'The application path is unknown, so no task can be created.';
    } else {
      final failure = await _guard(() => tasks.probeCreate(DateTime.utc(2099)));
      taskOk = failure == null;
      if (failure != null) error = failure;
    }

    var timerOk = false;
    try {
      timerOk = await _timer.probe();
    } on Object catch (e) {
      error ??= 'In-process timer: $e';
    }

    var settings = const WakeTimerSettings(
      onAc: WakeTimerPolicy.unknown,
      onBattery: WakeTimerPolicy.unknown,
    );
    try {
      final result = await _run('powercfg', powercfgQueryWakeTimersArgs);
      if (result.ok) {
        settings = parseWakeTimerSettings(result.stdout);
      } else {
        error ??= 'powercfg: ${result.errorText}';
      }
    } on Object catch (e) {
      error ??= 'powercfg: $e';
    }

    bool? modern;
    try {
      final result = await _run('powercfg', powercfgAvailableStatesArgs);
      if (result.ok) modern = parseModernStandby(result.stdout);
    } on Object catch (e) {
      _log.fine('powercfg /a failed: $e');
    }

    _lastError = error;
    return WakeCapability(
      taskCreationOk: taskOk,
      wakeTimersOnAc: settings.onAc,
      wakeTimersOnBattery: settings.onBattery,
      inProcessTimerOk: timerOk,
      modernStandby: modern,
      lastError: error,
    );
  }

  Future<String?> _guard(Future<String?> Function() action) async {
    try {
      return await action();
    } on Object catch (e) {
      return e.toString();
    }
  }

  @override
  Future<void> scheduleWake(DateTime utc, String id) async {
    if (!isSafeWakeId(id)) {
      throw WakeServiceException('"$id" cannot be used as a wake id.');
    }
    String? timerError;
    try {
      await _timer.schedule(id, utc);
    } on Object catch (e) {
      timerError = e.toString();
    }
    String? taskError;
    final tasks = _tasks;
    if (tasks == null) {
      taskError = 'The application path is unknown.';
    } else {
      taskError = await _guard(() => tasks.register(id, utc));
    }
    if (taskError != null) _log.warning('Task for $id: $taskError');
    if (timerError != null) _log.warning('Timer for $id: $timerError');
    if (taskError != null && timerError != null) {
      _lastError = 'Task: $taskError; timer: $timerError';
      throw WakeServiceException(_lastError!);
    }
    _lastError = taskError ?? timerError;
  }

  @override
  Future<void> cancel(String id) async {
    if (!isSafeWakeId(id)) return;
    try {
      await _timer.cancel(id);
    } on Object catch (e) {
      _log.warning('Cancelling the timer of $id failed: $e');
    }
    final tasks = _tasks;
    if (tasks == null) return;
    final error = await _guard(() => tasks.remove(id));
    if (error != null) {
      throw WakeServiceException('Could not remove the task of $id: $error');
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _timer.cancelAll();
    } on Object catch (e) {
      _log.warning('Cancelling the timers failed: $e');
    }
    final tasks = _tasks;
    if (tasks == null) return;
    final failures = <String>[];
    for (final id in await tasks.listIds()) {
      final error = await _guard(() => tasks.remove(id));
      if (error != null) failures.add('$id: $error');
    }
    if (failures.isNotEmpty) {
      throw WakeServiceException(
        'Could not remove some tasks: ${failures.join('; ')}',
      );
    }
  }

  @override
  Future<Set<String>> pendingIds() {
    final tasks = _tasks;
    if (tasks == null) return Future.value(const <String>{});
    return tasks.listIds();
  }

  @override
  Future<void> keepAwake(Duration? maxDuration) async => _awake.hold();

  @override
  Future<void> releaseAwake() async => _awake.release();

  @override
  Future<bool> openPowerOptions() => _open();
}
