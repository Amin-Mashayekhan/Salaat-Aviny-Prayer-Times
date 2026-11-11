import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:owghat/src/platform/wake/wake_ffi.dart';
import 'package:owghat_lib/wake_alarm.dart';

/// Milliseconds between 1601-01-01 (FILETIME epoch) and 1970-01-01, in 100 ns
/// units.
const int _filetimeUnixOffset = 116444736000000000;

/// The in-process wake mechanism: a Win32 waitable timer armed with
/// `SetWaitableTimer(..., fResume = TRUE)`, so Windows may wake the PC from
/// sleep for it while this process lives.
///
/// Threading: waiting on the timer blocks its thread, so every timer gets its
/// own short-lived background isolate that creates the timer, arms it and
/// blocks in `WaitForMultipleObjects` on [timer, cancelEvent]. The UI isolate
/// never blocks. Cancelling sets the cancel event, which wakes the worker so
/// it can free the timer and exit; killing an isolate that is blocked in a
/// native call would not work. Event handles are process-wide, so the main
/// isolate can create and signal the event while the worker waits on it.
///
/// The timer only wakes the PC. The schedule engine itself runs the alarm
/// when it sees that the time has come, exactly as after any resume.
///
/// UNVERIFIED on real hardware.
class FfiInProcessWakeTimer implements InProcessWakeTimer {
  /// Creates the timer manager.
  FfiInProcessWakeTimer();

  final Map<String, _Armed> _armed = {};

  @override
  Future<bool> probe() async {
    final handle = CreateWaitableTimerW(nullptr, 1, nullptr);
    if (handle == 0) return false;
    CloseHandle(handle);
    return true;
  }

  @override
  Future<void> schedule(String id, DateTime utc) async {
    await cancel(id);
    final cancelEvent = CreateEventW(nullptr, 1, 0, nullptr);
    if (cancelEvent == 0) {
      throw StateError('CreateEventW failed');
    }
    final port = ReceivePort();
    final armed = _Armed(cancelEvent, port);
    _armed[id] = armed;
    port.listen((message) {
      developer.log('wake timer $id: $message', name: 'owghat.wake');
      port.close();
      CloseHandle(cancelEvent);
      if (identical(_armed[id], armed)) _armed.remove(id);
    });
    final due = utc.toUtc().microsecondsSinceEpoch * 10 + _filetimeUnixOffset;
    try {
      await Isolate.spawn<List<Object>>(_timerWorker, [
        port.sendPort,
        due,
        cancelEvent,
      ]);
    } on Object {
      port.close();
      CloseHandle(cancelEvent);
      _armed.remove(id);
      rethrow;
    }
  }

  @override
  Future<void> cancel(String id) async {
    final armed = _armed.remove(id);
    // The worker answers on the port, which closes the port and the handle.
    if (armed != null) SetEvent(armed.cancelEvent);
  }

  @override
  Future<void> cancelAll() async {
    for (final id in _armed.keys.toList()) {
      await cancel(id);
    }
  }
}

class _Armed {
  _Armed(this.cancelEvent, this.port);
  final int cancelEvent;
  final ReceivePort port;
}

/// Runs in the background isolate: create, arm, wait, report.
void _timerWorker(List<Object> request) {
  final port = request[0] as SendPort;
  final due = request[1] as int;
  final cancelEvent = request[2] as int;

  final timer = CreateWaitableTimerW(nullptr, 1, nullptr);
  if (timer == 0) {
    port.send('error: CreateWaitableTimerW failed');
    return;
  }
  final dueTime = calloc<Int64>()..value = due;
  final armedOk = SetWaitableTimer(timer, dueTime, 0, nullptr, nullptr, 1) != 0;
  calloc.free(dueTime);
  if (!armedOk) {
    CloseHandle(timer);
    port.send('error: SetWaitableTimer failed');
    return;
  }

  final handles = calloc<IntPtr>(2);
  handles[0] = timer;
  handles[1] = cancelEvent;
  final result = WaitForMultipleObjects(2, handles, 0, waitInfinite);
  calloc.free(handles);

  CancelWaitableTimer(timer);
  CloseHandle(timer);
  port.send(switch (result) {
    waitObject0 => 'fired',
    1 => 'cancelled',
    _ => 'error: wait returned $result',
  });
}
