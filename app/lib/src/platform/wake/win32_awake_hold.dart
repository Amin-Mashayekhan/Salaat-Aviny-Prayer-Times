import 'package:owghat_lib/wake_alarm.dart';
import 'package:win32/win32.dart';

/// Keeps the PC and the display awake with `SetThreadExecutionState`.
///
/// `ES_CONTINUOUS` state belongs to the calling thread, so [hold] and
/// [release] must run on the same thread. They are always called from the main
/// isolate, which runs on the Flutter UI thread for the life of the process.
/// (If that ever proves wrong, `PowerCreateRequest`/`PowerSetRequest` are
/// process-wide alternatives.)
///
/// UNVERIFIED on real hardware.
class Win32AwakeHold implements AwakeHold {
  /// Creates the hold.
  Win32AwakeHold();

  @override
  void hold() {
    SetThreadExecutionState(
      ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED,
    );
  }

  @override
  void release() {
    // ES_CONTINUOUS alone clears the previously set requirements.
    SetThreadExecutionState(ES_CONTINUOUS);
  }
}
