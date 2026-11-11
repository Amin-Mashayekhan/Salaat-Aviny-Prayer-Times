import 'package:owghat_lib/src/core/storage/json_file_store.dart';
import 'package:owghat_lib/src/core/time/debouncer.dart';
import 'package:owghat_lib/src/core/utils/json_value.dart';
import 'package:owghat_lib/src/features/settings/data/settings_migrations.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// What loading the settings file produced.
typedef SettingsLoadResult = ({
  AppSettings settings,

  /// No settings file existed (first run).
  bool firstRun,

  /// The file was unreadable, renamed aside, and defaults are used.
  bool wasReset,
});

/// Loads and saves [AppSettings].
class SettingsRepository {
  /// Creates a repository over a store; saves are debounced.
  SettingsRepository(
    this._store, {
    Duration debounce = const Duration(milliseconds: 300),
  }) : _debouncer = Debouncer(debounce);

  final JsonFileStore _store;
  final Debouncer _debouncer;
  AppSettings? _pending;

  /// Loads the settings; never throws.
  Future<SettingsLoadResult> load() async {
    final result = await _store.read();
    final json = result.json;
    if (json is! Map) {
      return (
        settings: const AppSettings.defaults(),
        firstRun: !result.existed,
        wasReset: result.quarantined || (result.existed && json != null),
      );
    }
    final migrated = SettingsMigrations.migrate(json.cast<String, Object?>());
    return (
      settings: AppSettings.fromJson(migrated),
      firstRun: false,
      wasReset: false,
    );
  }

  /// Schedules a save of [settings].
  void save(AppSettings settings) {
    _pending = settings;
    _debouncer.run(_write);
  }

  /// Writes any pending change now.
  Future<void> flush() async {
    _debouncer.dispose();
    await _write();
  }

  Future<void> _write() async {
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    await _store.write(pending.toJson());
  }

  /// Exports [settings] to a JSON string-friendly map.
  Map<String, Object?> export(AppSettings settings) => settings.toJson();

  /// Parses a backup map; returns null if it is not a settings file.
  AppSettings? tryImport(Object? json) {
    final map = Json.map(json);
    if (map.isEmpty || !map.containsKey('locations')) return null;
    return AppSettings.fromJson(SettingsMigrations.migrate(map));
  }
}
