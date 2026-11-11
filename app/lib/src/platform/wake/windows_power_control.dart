import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:owghat/src/platform/wake/wake_ffi.dart';
import 'package:owghat_lib/wake_alarm.dart';

/// Sleep and hibernate through `SetSuspendState` (powrprof.dll).
///
/// - `SeShutdownPrivilege` is enabled in the process token first (a standard
///   user has it, disabled by default; no elevation is needed to enable it).
/// - `bWakeupEventsDisabled` is FALSE so wake timers keep working.
/// - The call blocks until the PC resumes, so it runs on a short-lived
///   isolate and the UI thread never freezes.
/// - If `SetSuspendState` fails, the documented fallbacks run:
///   `rundll32.exe powrprof.dll,SetSuspendState 0,1,0` for sleep and
///   `shutdown /h` for hibernate.
/// - If hibernation is switched off, `SetSuspendState(TRUE, ...)` would sleep
///   instead, so [hibernate] reports [PowerResult.unavailable] rather than
///   doing something the user did not ask for. The app never turns hibernation
///   on itself (that needs `powercfg /hibernate on` as administrator).
///
/// UNVERIFIED on real hardware.
class WindowsPowerControl implements PowerControl {
  /// Creates the control. [run] runs the fallback commands.
  // ignore: prefer_initializing_formals, a named parameter cannot start with _
  WindowsPowerControl({required CommandRunner run}) : _run = run;

  final CommandRunner _run;

  @override
  Future<PowerResult> sleep() => _suspend(hibernate: false);

  @override
  Future<PowerResult> hibernate() async {
    if (!await Isolate.run(_hibernationAvailable)) {
      return PowerResult.unavailable;
    }
    return await _suspend(hibernate: true);
  }

  Future<PowerResult> _suspend({required bool hibernate}) async {
    final ok = await Isolate.run(() => _setSuspendState(hibernate: hibernate));
    if (ok) return PowerResult.ok;
    developer.log(
      'SetSuspendState failed; using the command-line fallback',
      name: 'owghat.wake',
    );
    final result = hibernate
        ? await _run('shutdown', const ['/h'])
        : await _run('rundll32.exe', const [
            'powrprof.dll,SetSuspendState',
            '0,1,0',
          ]);
    return result.ok ? PowerResult.ok : PowerResult.refused;
  }
}

/// Runs in a background isolate.
bool _setSuspendState({required bool hibernate}) {
  _enableShutdownPrivilege();
  // bHibernate, bForce (ignored by Windows since Vista),
  // bWakeupEventsDisabled = FALSE.
  return SetSuspendState(hibernate ? 1 : 0, 0, 0) != 0;
}

/// Turns `SeShutdownPrivilege` on in the process token. Failure is not fatal:
/// `SetSuspendState` is the arbiter.
void _enableShutdownPrivilege() {
  final token = calloc<IntPtr>();
  final name = 'SeShutdownPrivilege'.toNativeUtf16();
  // TOKEN_PRIVILEGES with one entry: DWORD count, LUID (8 bytes), DWORD attrs.
  final privileges = calloc<Uint8>(16);
  try {
    if (OpenProcessToken(GetCurrentProcess(), tokenAdjustAndQuery, token) ==
        0) {
      return;
    }
    final luid = privileges + 4;
    if (LookupPrivilegeValueW(nullptr, name, luid) == 0) {
      CloseHandle(token.value);
      return;
    }
    privileges.cast<Uint32>().value = 1;
    (privileges + 12).cast<Uint32>().value = sePrivilegeEnabled;
    AdjustTokenPrivileges(token.value, 0, privileges, 0, nullptr, nullptr);
    CloseHandle(token.value);
  } finally {
    calloc
      ..free(token)
      ..free(privileges);
    malloc.free(name);
  }
}

/// Whether hibernation is switched on (`HiberFilePresent`, byte 8 of
/// SYSTEM_POWER_CAPABILITIES). If the call fails, assume yes and let the
/// fallback report a refusal.
bool _hibernationAvailable() {
  final caps = calloc<Uint8>(128);
  try {
    if (GetPwrCapabilities(caps) == 0) return true;
    return caps[8] != 0;
  } finally {
    calloc.free(caps);
  }
}
