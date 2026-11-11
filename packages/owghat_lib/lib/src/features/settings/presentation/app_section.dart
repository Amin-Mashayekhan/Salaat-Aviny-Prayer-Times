import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/features/settings/application/settings_actions.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';

/// Section 7: start-up behaviour, backup and restore, reset.
class AppSection extends ConsumerStatefulWidget {
  /// Creates the section.
  const AppSection({super.key});

  @override
  ConsumerState<AppSection> createState() => _AppSectionState();
}

enum _Notice {
  none,
  exported,
  exportFailed,
  invalid,
  readFailed,
  imported,
  reset,
}

class _AppSectionState extends ConsumerState<AppSection> {
  _Notice _notice = _Notice.none;
  String? _path;

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    required Key confirmKey,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            key: const Key('set-dialog-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          FilledButton(
            key: confirmKey,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _export() async {
    final result = await ref.read(settingsActionsProvider).exportBackup();
    if (!mounted) return;
    setState(() {
      _path = result.path;
      _notice = switch (result.outcome) {
        BackupOutcome.exported => _Notice.exported,
        BackupOutcome.exportFailed => _Notice.exportFailed,
        _ => _notice,
      };
    });
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(settingsActionsProvider);
    final result = await actions.readBackup();
    if (!mounted) return;
    switch (result.outcome) {
      case BackupOutcome.importInvalid:
        setState(() => _notice = _Notice.invalid);
      case BackupOutcome.importReadFailed:
        setState(() => _notice = _Notice.readFailed);
      case BackupOutcome.importReady:
        final ok = await _confirm(
          title: l10n.settingsBackupImportTitle,
          body: l10n.settingsBackupImportBody,
          confirmLabel: l10n.settingsBackupImportConfirm,
          confirmKey: const Key('set-import-confirm'),
        );
        if (!ok || !mounted) return;
        actions.applyBackup(result.settings!);
        setState(() => _notice = _Notice.imported);
      case BackupOutcome.cancelled ||
          BackupOutcome.exported ||
          BackupOutcome.exportFailed:
        break;
    }
  }

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context);
    final ok = await _confirm(
      title: l10n.settingsResetConfirmTitle,
      body: l10n.settingsResetConfirmBody,
      confirmLabel: l10n.settingsResetConfirm,
      confirmKey: const Key('set-reset-confirm'),
    );
    if (!ok || !mounted) return;
    ref.read(settingsActionsProvider).resetToDefaults();
    setState(() => _notice = _Notice.reset);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final window = ref.watch(settingsProvider.select((s) => s.window));
    final controller = ref.read(settingsProvider.notifier);

    final message = switch (_notice) {
      _Notice.none => (null, false),
      _Notice.exported => (l10n.settingsBackupExported(_path ?? ''), false),
      _Notice.exportFailed => (l10n.settingsBackupExportFailed, true),
      _Notice.invalid => (l10n.settingsBackupImportInvalid, true),
      _Notice.readFailed => (l10n.settingsBackupImportReadFailed, true),
      _Notice.imported => (l10n.settingsBackupImported, false),
      _Notice.reset => (l10n.settingsResetDone, false),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          children: [
            SwitchRow(
              key: const Key('set-app-autostart'),
              title: l10n.settingsAppAutostart,
              description: l10n.settingsAppAutostartHelp,
              value: window.launchAtStartup,
              onChanged: (value) =>
                  controller.setLaunchAtStartup(enabled: value),
            ),
            SwitchRow(
              key: const Key('set-app-minimized'),
              title: l10n.settingsAppMinimized,
              description: l10n.settingsAppMinimizedHelp,
              value: window.startMinimized,
              onChanged: (value) =>
                  controller.setStartMinimized(enabled: value),
            ),
            SwitchRow(
              key: const Key('set-app-close-to-tray'),
              title: l10n.settingsAppCloseToTray,
              description: l10n.settingsAppCloseToTrayHelp,
              value: window.closeToTray,
              onChanged: (value) => controller.setCloseToTray(enabled: value),
            ),
          ],
        ),
        SettingsGroup(
          title: l10n.settingsBackupTitle,
          children: [
            SettingRow(
              title: l10n.settingsBackupExport,
              description: l10n.settingsBackupExportHelp,
              control: OutlinedButton.icon(
                key: const Key('set-backup-export'),
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(l10n.settingsBackupExport),
                onPressed: _export,
              ),
            ),
            SettingRow(
              title: l10n.settingsBackupImport,
              description: l10n.settingsBackupImportHelp,
              control: OutlinedButton.icon(
                key: const Key('set-backup-import'),
                icon: const Icon(Icons.download_outlined),
                label: Text(l10n.settingsBackupImport),
                onPressed: _import,
              ),
            ),
            SettingRow(
              title: l10n.settingsResetTitle,
              description: l10n.settingsResetHelp,
              control: OutlinedButton.icon(
                key: const Key('set-reset'),
                style: OutlinedButton.styleFrom(foregroundColor: colors.danger),
                icon: const Icon(Icons.restart_alt),
                label: Text(l10n.settingsResetTitle),
                onPressed: _reset,
              ),
            ),
            if (message.$1 != null)
              Semantics(
                liveRegion: true,
                child: StatusLine(
                  key: const Key('set-app-message'),
                  text: message.$1!,
                  icon: message.$2
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: message.$2 ? colors.danger : colors.success,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
