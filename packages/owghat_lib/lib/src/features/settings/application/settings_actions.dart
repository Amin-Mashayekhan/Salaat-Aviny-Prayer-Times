import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/storage/json_file_store.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/data/backup_files.dart';
import 'package:owghat_lib/src/features/settings/data/settings_repository.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:prayer_core/prayer_core.dart';

/// The backup file reader and writer. Tests override it.
final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const IoBackupFiles(),
);

/// The object that turns settings into a backup map and back.
///
/// It is the settings repository when the app injected one; otherwise (tests)
/// a repository that is never asked to load or save anything.
final settingsBackupCodecProvider = Provider<SettingsRepository>(
  (ref) =>
      ref.watch(settingsRepositoryProvider) ??
      SettingsRepository(MemoryJsonStore()),
);

/// How a backup export or import step ended.
enum BackupOutcome {
  /// The user closed the file dialog.
  cancelled,

  /// The backup file was written.
  exported,

  /// The backup file could not be written.
  exportFailed,

  /// The file holds valid settings, ready to be applied after a confirmation.
  importReady,

  /// The file is not a settings backup; nothing was changed.
  importInvalid,

  /// The file could not be read; nothing was changed.
  importReadFailed,
}

/// Result of a backup step.
@immutable
class BackupResult {
  /// Creates a result.
  const BackupResult(this.outcome, {this.path, this.settings});

  /// What happened.
  final BackupOutcome outcome;

  /// The file involved, if any.
  final String? path;

  /// The parsed settings of an [BackupOutcome.importReady] result.
  final AppSettings? settings;
}

/// The user actions of the settings screen that need more than one provider.
///
/// Each method is called from a button press. Settings are still only written
/// by [SettingsController]; this class only decides what to write.
class SettingsActions {
  /// Creates the actions over [_ref].
  SettingsActions(this._ref);

  static final Logger _log = Logger('SettingsActions');

  final Ref _ref;

  SettingsController get _settings => _ref.read(settingsProvider.notifier);

  /// Opens the file dialog and, if the user chose a sound, stores it as the
  /// sound of [prayer]. Returns the chosen path, or null if cancelled.
  Future<String?> pickSound(Prayer prayer) async {
    final path = await _ref.read(fileDialogsProvider).pickSoundFile();
    if (path == null || path.isEmpty) return null;
    final current = _ref.read(settingsProvider).azan.perPrayer[prayer];
    _settings.setPrayerAzan(
      prayer,
      (current ?? const PrayerAzan()).copyWith(sound: SoundRef.file(path)),
    );
    return path;
  }

  /// Goes back to the bundled azan for [prayer].
  void useDefaultSound(Prayer prayer) {
    final current = _ref.read(settingsProvider).azan.perPrayer[prayer];
    _settings.setPrayerAzan(
      prayer,
      (current ?? const PrayerAzan()).copyWith(sound: SoundRef.defaultAzan),
    );
  }

  /// Plays the sound of [prayer] at its volume (through the master volume).
  Future<AzanPlayResult> previewAzan(Prayer prayer) {
    final entry =
        _ref.read(settingsProvider).azan.perPrayer[prayer] ??
        const PrayerAzan();
    return _ref
        .read(azanPlaybackProvider.notifier)
        .preview(entry.sound, volume: entry.volume);
  }

  /// Stops a preview.
  Future<void> stopPreview() => _ref.read(azanPlaybackProvider.notifier).stop();

  /// Plays the reminder chime once.
  Future<void> playChime() =>
      _ref.read(azanPlaybackProvider.notifier).playChime();

  /// Asks where to save and writes all settings there.
  Future<BackupResult> exportBackup() async {
    final now = _ref.read(clockProvider).now().toUtc();
    final stamp =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final path = await _ref
        .read(fileDialogsProvider)
        .pickBackupSavePath(suggestedName: 'owghat-backup-$stamp.json');
    if (path == null || path.isEmpty) {
      return const BackupResult(BackupOutcome.cancelled);
    }
    try {
      final map = _ref
          .read(settingsBackupCodecProvider)
          .export(_ref.read(settingsProvider));
      await _ref
          .read(backupFilesProvider)
          .write(path, const JsonEncoder.withIndent('  ').convert(map));
      return BackupResult(BackupOutcome.exported, path: path);
    } on Object catch (error, stack) {
      _log.warning('Writing the backup failed', error, stack);
      return BackupResult(BackupOutcome.exportFailed, path: path);
    }
  }

  /// Asks which backup to read and parses it. Nothing is changed until
  /// [applyBackup] is called with the result.
  Future<BackupResult> readBackup() async {
    final path = await _ref.read(fileDialogsProvider).pickBackupOpenPath();
    if (path == null || path.isEmpty) {
      return const BackupResult(BackupOutcome.cancelled);
    }
    final String text;
    try {
      text = await _ref.read(backupFilesProvider).read(path);
    } on Object catch (error, stack) {
      _log.warning('Reading the backup failed', error, stack);
      return BackupResult(BackupOutcome.importReadFailed, path: path);
    }
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      return BackupResult(BackupOutcome.importInvalid, path: path);
    }
    final settings = _ref.read(settingsBackupCodecProvider).tryImport(json);
    if (settings == null || !_zonesAreKnown(settings)) {
      return BackupResult(BackupOutcome.importInvalid, path: path);
    }
    return BackupResult(
      BackupOutcome.importReady,
      path: path,
      settings: settings,
    );
  }

  /// Whether every custom location of [settings] names a zone that exists in
  /// the bundled database (an unknown zone would break the calculation).
  bool _zonesAreKnown(AppSettings settings) {
    final resolver = _ref.read(zoneOffsetResolverProvider);
    return settings.locations.every(
      (l) =>
          l.kind != LocationKind.custom ||
          l.offset.mode == OffsetMode.fixed ||
          resolver.knowsZone(l.zoneId),
    );
  }

  /// Replaces all settings with [imported] (after the user confirmed). The
  /// first-run flow is not shown again.
  void applyBackup(AppSettings imported) =>
      _settings.replaceAll(imported.copyWith(onboardingCompleted: true));

  /// Restores the factory defaults (after the user confirmed).
  void resetToDefaults() => _settings.resetToDefaults();
}

/// The settings-screen actions.
final settingsActionsProvider = Provider<SettingsActions>(SettingsActions.new);
