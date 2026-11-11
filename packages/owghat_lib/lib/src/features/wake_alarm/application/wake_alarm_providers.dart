import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_services.dart';

/// Wakes the PC and holds it awake. Overridden at start-up with the Windows
/// implementation; the default does nothing and reports "unsupported".
final wakeTimerServiceProvider = Provider<WakeTimerService>(
  (ref) => const NoWakeTimerService(),
);

/// Sleeps or hibernates the PC. Overridden at start-up; the default does
/// nothing.
final powerControlProvider = Provider<PowerControl>(
  (ref) => const NoPowerControl(),
);

/// Plays the sound of an alarm. Overridden at start-up with an adapter over
/// the app audio output; the default plays nothing.
final alarmSoundPlayerProvider = Provider<AlarmSoundPlayer>(
  (ref) => const NoAlarmSoundPlayer(),
);
