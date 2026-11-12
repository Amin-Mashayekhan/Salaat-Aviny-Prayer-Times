import 'dart:io';

import 'package:owghat_lib/owghat_lib.dart';

/// [AutostartService] through `reg.exe` on
/// `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`.
///
/// The value is named `Salaat` and holds `"<exe>" --minimized`, exactly what
/// the installer writes. It lives in the current user hive, so it never
/// needs administrator rights. (The `launch_at_startup` plugin is
/// not used because it pulls in a native build hook.)
class RegistryAutostart implements AutostartService {
  /// Creates the service. [executable] defaults to the running exe.
  RegistryAutostart({String? executable})
    : _executable = executable ?? Platform.resolvedExecutable;

  /// The registry key that Windows reads at sign-in.
  static const String runKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';

  /// The value name (the same one the installer uses).
  static const String valueName = 'Salaat';

  final String _executable;

  @override
  Future<bool> isEnabled() async {
    final result = await Process.run('reg', ['query', runKey, '/v', valueName]);
    return result.exitCode == 0;
  }

  @override
  Future<void> enable() async {
    final result = await Process.run('reg', [
      'add',
      runKey,
      '/v',
      valueName,
      '/t',
      'REG_SZ',
      '/d',
      '"$_executable" --minimized',
      '/f',
    ]);
    if (result.exitCode != 0 || !await isEnabled()) {
      throw StateError('reg add failed (${result.exitCode}): ${result.stderr}');
    }
  }

  @override
  Future<void> disable() async {
    if (!await isEnabled()) return;
    final result = await Process.run('reg', [
      'delete',
      runKey,
      '/v',
      valueName,
      '/f',
    ]);
    if (result.exitCode != 0) {
      throw StateError(
        'reg delete failed (${result.exitCode}): ${result.stderr}',
      );
    }
  }
}
