import 'dart:io';

import 'package:path/path.dart' as p;

/// Where the app keeps its files. On Windows the folder comes from
/// `path_provider` (`%APPDATA%\<company>\<product>`).
class PlatformPaths {
  /// Creates the paths around [appSupportDir].
  const PlatformPaths(this.appSupportDir);

  /// The per-user application support folder.
  final Directory appSupportDir;

  /// The user settings file (`settings.json`).
  File get settingsFile => File(p.join(appSupportDir.path, 'settings.json'));

  /// The non-user state file (`state.json`).
  File get stateFile => File(p.join(appSupportDir.path, 'state.json'));

  /// The folder for log files.
  Directory get logDir => Directory(p.join(appSupportDir.path, 'logs'));
}
