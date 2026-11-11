import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';

/// The only `powercfg` invocations this app is allowed to make. Both are
/// read-only. The app never calls `powercfg` with a set/change flag
/// (rule 10 in `CLAUDE.md`).
const List<String> powercfgQueryWakeTimersArgs = [
  '/query',
  'SCHEME_CURRENT',
  'SUB_SLEEP',
  'RTCWAKE',
];

/// Lists the sleep states of this PC (read-only).
const List<String> powercfgAvailableStatesArgs = ['/a'];

/// "Allow wake timers" for each power source, read from `powercfg`.
class WakeTimerSettings {
  /// Creates the pair.
  const WakeTimerSettings({required this.onAc, required this.onBattery});

  /// While plugged in.
  final WakeTimerPolicy onAc;

  /// While on battery.
  final WakeTimerPolicy onBattery;
}

WakeTimerPolicy _policy(int value) => switch (value) {
  0 => WakeTimerPolicy.disabled,
  1 => WakeTimerPolicy.enabled,
  2 => WakeTimerPolicy.importantOnly,
  _ => WakeTimerPolicy.unknown,
};

final RegExp _hexIndex = RegExp(r'\b0x([0-9a-fA-F]{1,8})\b');

/// Parses the output of `powercfg /query SCHEME_CURRENT SUB_SLEEP RTCWAKE`.
///
/// The labels are localised but the two last `0x........` values are always
/// "current AC setting index" then "current DC setting index" (0 = disabled,
/// 1 = enabled, 2 = important wake timers only). Only those hexadecimal
/// numbers are read, so the language of Windows does not matter.
///
/// A machine without a battery may print only the AC value; the battery
/// policy is then [WakeTimerPolicy.unknown]. Output that holds no such value
/// gives `unknown` for both.
WakeTimerSettings parseWakeTimerSettings(String output) {
  final values = <int>[];
  for (final line in output.split(RegExp(r'\r?\n'))) {
    final match = _hexIndex.firstMatch(line);
    if (match != null) values.add(int.parse(match.group(1)!, radix: 16));
  }
  if (values.isEmpty) {
    return const WakeTimerSettings(
      onAc: WakeTimerPolicy.unknown,
      onBattery: WakeTimerPolicy.unknown,
    );
  }
  if (values.length == 1) {
    return WakeTimerSettings(
      onAc: _policy(values.single),
      onBattery: WakeTimerPolicy.unknown,
    );
  }
  return WakeTimerSettings(
    onAc: _policy(values[values.length - 2]),
    onBattery: _policy(values.last),
  );
}

final RegExp _sleepState = RegExp(r'\bS([0-5])\b');

/// Whether the output of `powercfg /a` says this PC uses Modern Standby
/// (S0 low power idle) instead of classic S3 sleep. Null when it cannot be
/// told (an unexpected or localised layout without `S0`/`S3` markers).
///
/// Reads the first block of text, which lists the states that ARE available.
bool? parseModernStandby(String output) {
  for (final block in output.split(RegExp(r'\r?\n\s*\r?\n'))) {
    final states = {
      for (final match in _sleepState.allMatches(block))
        int.parse(match.group(1)!),
    };
    if (states.isEmpty) continue;
    if (states.contains(3)) return false;
    if (states.contains(0)) return true;
    return false;
  }
  return null;
}
