import 'package:owghat_lib/owghat_lib.dart';
import 'package:path_provider/path_provider.dart';

/// Resolves the application folders with `path_provider`.
///
/// On Windows the support directory is `%APPDATA%\<company>\<product>`, taken
/// from the exe's version resource (`Runner.rc`: `Owghat\Owghat`), which is
/// also what the installer uses to clean up.
abstract final class PathProviderPaths {
  /// Looks up the per-user application support folder.
  static Future<PlatformPaths> resolve() async =>
      PlatformPaths(await getApplicationSupportDirectory());
}
