import 'package:flutter/foundation.dart';

/// The command line the app was started with.
@immutable
class LaunchArgs {
  /// Creates the parsed arguments.
  const LaunchArgs({this.minimized = false, this.wakeAlarmId});

  /// Parses [args]: `--minimized` and `--wake <id>` (or `--wake=<id>`).
  /// Unknown arguments are ignored.
  factory LaunchArgs.parse(List<String> args) {
    var minimized = false;
    String? wake;
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      if (arg == '--minimized') {
        minimized = true;
      } else if (arg == '--wake' && i + 1 < args.length) {
        wake = args[++i];
      } else if (arg.startsWith('--wake=') && arg.length > 7) {
        wake = arg.substring(7);
      }
    }
    return LaunchArgs(minimized: minimized, wakeAlarmId: wake);
  }

  /// Start hidden in the tray (used by the autostart entry).
  final bool minimized;

  /// The wake-up alarm that started the app (`--wake <id>`), if any.
  final String? wakeAlarmId;

  @override
  bool operator ==(Object other) =>
      other is LaunchArgs &&
      other.minimized == minimized &&
      other.wakeAlarmId == wakeAlarmId;

  @override
  int get hashCode => Object.hash(minimized, wakeAlarmId);
}
