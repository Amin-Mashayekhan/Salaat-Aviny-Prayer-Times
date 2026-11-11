// Hand-written dart:ffi bindings for the Win32 calls that package:win32 6.4.0
// does not contain (CreateWaitableTimerW, SetWaitableTimer, SetSuspendState,
// AdjustTokenPrivileges, ...). The style follows win32's own generated files:
// one DynamicLibrary per DLL and lookupFunction with the native and the Dart
// signature.
//
// Handles are carried as `int` (IntPtr). Nothing here has been run on real
// hardware; see docs/adr/0005-wake-timers.md.
// ignore_for_file: non_constant_identifier_names
import 'dart:ffi';

import 'package:ffi/ffi.dart';

final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
final DynamicLibrary _advapi32 = DynamicLibrary.open('advapi32.dll');
final DynamicLibrary _powrprof = DynamicLibrary.open('powrprof.dll');

/// `WAIT_OBJECT_0`.
const int waitObject0 = 0;

/// `INFINITE`.
const int waitInfinite = 0xFFFFFFFF;

/// `SE_PRIVILEGE_ENABLED`.
const int sePrivilegeEnabled = 0x00000002;

/// `TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY`.
const int tokenAdjustAndQuery = 0x0020 | 0x0008;

/// `HANDLE CreateWaitableTimerW(LPSECURITY_ATTRIBUTES, BOOL manualReset,
/// LPCWSTR name)`.
final int Function(Pointer<Void>, int, Pointer<Utf16>) CreateWaitableTimerW =
    _kernel32.lookupFunction<
      IntPtr Function(Pointer<Void>, Int32, Pointer<Utf16>),
      int Function(Pointer<Void>, int, Pointer<Utf16>)
    >('CreateWaitableTimerW');

/// `BOOL SetWaitableTimer(HANDLE, const LARGE_INTEGER* due, LONG period,
/// PTIMERAPCROUTINE, LPVOID arg, BOOL fResume)`.
///
/// A positive `due` is an absolute UTC FILETIME; `fResume = TRUE` lets the
/// timer wake the PC from sleep.
final int Function(int, Pointer<Int64>, int, Pointer<Void>, Pointer<Void>, int)
SetWaitableTimer = _kernel32
    .lookupFunction<
      Int32 Function(
        IntPtr,
        Pointer<Int64>,
        Int32,
        Pointer<Void>,
        Pointer<Void>,
        Int32,
      ),
      int Function(int, Pointer<Int64>, int, Pointer<Void>, Pointer<Void>, int)
    >('SetWaitableTimer');

/// `BOOL CancelWaitableTimer(HANDLE)`.
final int Function(int) CancelWaitableTimer = _kernel32
    .lookupFunction<Int32 Function(IntPtr), int Function(int)>(
      'CancelWaitableTimer',
    );

/// `HANDLE CreateEventW(LPSECURITY_ATTRIBUTES, BOOL manualReset,
/// BOOL initialState, LPCWSTR name)`.
final int Function(Pointer<Void>, int, int, Pointer<Utf16>) CreateEventW =
    _kernel32.lookupFunction<
      IntPtr Function(Pointer<Void>, Int32, Int32, Pointer<Utf16>),
      int Function(Pointer<Void>, int, int, Pointer<Utf16>)
    >('CreateEventW');

/// `BOOL SetEvent(HANDLE)`.
final int Function(int) SetEvent = _kernel32
    .lookupFunction<Int32 Function(IntPtr), int Function(int)>('SetEvent');

/// `DWORD WaitForMultipleObjects(DWORD count, const HANDLE* handles,
/// BOOL waitAll, DWORD milliseconds)`.
final int Function(int, Pointer<IntPtr>, int, int) WaitForMultipleObjects =
    _kernel32.lookupFunction<
      Uint32 Function(Uint32, Pointer<IntPtr>, Int32, Uint32),
      int Function(int, Pointer<IntPtr>, int, int)
    >('WaitForMultipleObjects');

/// `BOOL CloseHandle(HANDLE)`.
final int Function(int) CloseHandle = _kernel32
    .lookupFunction<Int32 Function(IntPtr), int Function(int)>('CloseHandle');

/// `HANDLE GetCurrentProcess(void)` (a pseudo handle, never closed).
final int Function() GetCurrentProcess = _kernel32
    .lookupFunction<IntPtr Function(), int Function()>('GetCurrentProcess');

/// `BOOL OpenProcessToken(HANDLE, DWORD access, PHANDLE token)`.
final int Function(int, int, Pointer<IntPtr>) OpenProcessToken = _advapi32
    .lookupFunction<
      Int32 Function(IntPtr, Uint32, Pointer<IntPtr>),
      int Function(int, int, Pointer<IntPtr>)
    >('OpenProcessToken');

/// `BOOL LookupPrivilegeValueW(LPCWSTR system, LPCWSTR name, PLUID luid)`.
final int Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Uint8>)
LookupPrivilegeValueW = _advapi32
    .lookupFunction<
      Int32 Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Uint8>),
      int Function(Pointer<Utf16>, Pointer<Utf16>, Pointer<Uint8>)
    >('LookupPrivilegeValueW');

/// `BOOL AdjustTokenPrivileges(HANDLE token, BOOL disableAll,
/// PTOKEN_PRIVILEGES newState, DWORD bufferLength, PTOKEN_PRIVILEGES previous,
/// PDWORD returnLength)`.
final int Function(
  int,
  int,
  Pointer<Uint8>,
  int,
  Pointer<Uint8>,
  Pointer<Uint32>,
)
AdjustTokenPrivileges = _advapi32
    .lookupFunction<
      Int32 Function(
        IntPtr,
        Int32,
        Pointer<Uint8>,
        Uint32,
        Pointer<Uint8>,
        Pointer<Uint32>,
      ),
      int Function(
        int,
        int,
        Pointer<Uint8>,
        int,
        Pointer<Uint8>,
        Pointer<Uint32>,
      )
    >('AdjustTokenPrivileges');

/// `BOOLEAN SetSuspendState(BOOLEAN hibernate, BOOLEAN force,
/// BOOLEAN wakeupEventsDisabled)`. Returns non-zero on success; blocks until
/// the PC resumes.
final int Function(int, int, int) SetSuspendState = _powrprof
    .lookupFunction<
      Uint8 Function(Uint8, Uint8, Uint8),
      int Function(int, int, int)
    >('SetSuspendState');

/// `BOOLEAN GetPwrCapabilities(PSYSTEM_POWER_CAPABILITIES)`.
final int Function(Pointer<Uint8>) GetPwrCapabilities = _powrprof
    .lookupFunction<
      Uint8 Function(Pointer<Uint8>),
      int Function(Pointer<Uint8>)
    >('GetPwrCapabilities');
