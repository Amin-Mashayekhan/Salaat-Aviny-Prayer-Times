import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Facts found while loading at start-up.
@immutable
class StartupInfo {
  /// Creates the info.
  const StartupInfo({this.firstRun = false, this.settingsWereReset = false});

  /// No settings file existed: this is the first run.
  final bool firstRun;

  /// The settings file was unreadable, was renamed aside, and the defaults
  /// are in use (the UI shows a notice).
  final bool settingsWereReset;
}

/// What start-up found. Overridden by `bootstrap`.
final startupInfoProvider = Provider<StartupInfo>((ref) => const StartupInfo());
