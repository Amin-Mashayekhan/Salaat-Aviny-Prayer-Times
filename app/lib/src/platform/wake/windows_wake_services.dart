import 'dart:convert';
import 'dart:io';

import 'package:owghat/src/platform/wake/ffi_in_process_wake_timer.dart';
import 'package:owghat/src/platform/wake/win32_awake_hold.dart';
import 'package:owghat/src/platform/wake/windows_power_control.dart';
import 'package:owghat_lib/wake_alarm.dart';

/// Runs a command without a shell. Output is decoded as Latin-1 so a console
/// code page can never make decoding throw; the parsers only read ASCII.
Future<CommandResult> runProcess(
  String executable,
  List<String> arguments,
) async {
  final result = await Process.run(
    executable,
    arguments,
    stdoutEncoding: latin1,
    stderrEncoding: latin1,
  );
  return CommandResult(
    exitCode: result.exitCode,
    stdout: result.stdout as String,
    stderr: result.stderr as String,
  );
}

/// The Windows implementations of the wake-up interfaces.
///
/// Bind them in the runner (see `docs/adr/0005-wake-timers.md`):
///
/// ```dart
/// final wake = WindowsWakeServices.create(tempDirectory: ...);
/// // overrides for ProviderContainer:
/// wakeTimerServiceProvider.overrideWithValue(wake.timer),
/// powerControlProvider.overrideWithValue(wake.power),
/// alarmSoundPlayerProvider.overrideWith(
///   (ref) => AudioOutputAlarmSoundPlayer(ref.read(audioOutputProvider))),
/// ```
class WindowsWakeServices {
  WindowsWakeServices._(this.timer, this.power);

  /// Builds the services. [tempDirectory] receives the short-lived task XML
  /// files (any writable folder, for example the app support folder).
  factory WindowsWakeServices.create({required String tempDirectory}) {
    final exe = Platform.resolvedExecutable;
    final tasks = SchtasksWakeScheduler(
      run: runProcess,
      executablePath: exe,
      tempDirectory: tempDirectory,
      workingDirectory: File(exe).parent.path,
      // Only used by the fallback trigger styles.
      localOffsetAt: (utc) => utc.toLocal().timeZoneOffset,
    );
    final timer = CompositeWakeTimerService(
      run: runProcess,
      timer: FfiInProcessWakeTimer(),
      awake: Win32AwakeHold(),
      tasks: tasks,
      openPowerOptionsAction: _openPowerOptions,
    );
    return WindowsWakeServices._(timer, WindowsPowerControl(run: runProcess));
  }

  /// Wake timers and the awake hold.
  final WakeTimerService timer;

  /// Sleep and hibernate.
  final PowerControl power;
}

/// Opens the Windows Power Options control panel. It only shows the window;
/// the user changes the setting, never the app.
Future<bool> _openPowerOptions() async {
  try {
    await Process.start('control.exe', const [
      'powercfg.cpl',
    ], mode: ProcessStartMode.detached);
    return true;
  } on Object {
    return false;
  }
}
