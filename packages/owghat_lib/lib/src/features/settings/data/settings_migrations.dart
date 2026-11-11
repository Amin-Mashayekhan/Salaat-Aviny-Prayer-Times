import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// A step that upgrades a settings map from one schema version to the next.
typedef MigrationStep = Map<String, Object?> Function(Map<String, Object?>);

/// Upgrades settings files written by older versions of the app.
///
/// `steps[i]` upgrades version `i + 1` to version `i + 2`. Version 1 is the
/// first released layout, so the list is empty until the layout changes.
/// When it changes: bump [settingsSchemaVersion], append a step, and add a
/// fixture of the old layout to the tests.
abstract final class SettingsMigrations {
  /// Steps, oldest first.
  static final List<MigrationStep> steps = [];

  /// The schema version found in [json]; files without one count as 1.
  static int versionOf(Map<String, Object?> json) {
    final version = json['schemaVersion'];
    return version is int && version >= 1 ? version : 1;
  }

  /// Brings [json] up to [settingsSchemaVersion].
  ///
  /// Files from a newer app are returned unchanged and read leniently.
  static Map<String, Object?> migrate(Map<String, Object?> json) {
    var version = versionOf(json);
    var current = json;
    while (version < settingsSchemaVersion && version - 1 < steps.length) {
      current = steps[version - 1](current);
      version++;
    }
    return current;
  }
}
