import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_actions.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';

/// Section 4: minutes before each azan (0 = off) and the soft chime.
class RemindersSection extends ConsumerWidget {
  /// Creates the section.
  const RemindersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reminders = ref.watch(settingsProvider.select((s) => s.reminders));
    final controller = ref.read(settingsProvider.notifier);
    final fmt = ref.watch(formatterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          description: l10n.settingsRemHelp(
            fmt.formatNumber(ReminderSettings.maxMinutes),
          ),
          children: [
            for (final prayer in AzanSettings.azanPrayers)
              SettingRow(
                key: Key('set-reminder-row-${prayer.name}'),
                title: l10n.settingsRemTitle(prayer.label(l10n)),
                description: (reminders.minutesBefore[prayer] ?? 0) == 0
                    ? l10n.settingsOff
                    : l10n.settingsRemSummary(
                        fmt.formatNumber(reminders.minutesBefore[prayer]!),
                      ),
                control: IntStepper(
                  keyPrefix: 'set-reminder-${prayer.name}',
                  semanticsLabel: l10n.settingsRemTitle(prayer.label(l10n)),
                  value: reminders.minutesBefore[prayer] ?? 0,
                  min: 0,
                  max: ReminderSettings.maxMinutes,
                  format: fmt.formatNumber,
                  onChanged: (minutes) =>
                      controller.setReminderMinutes(prayer, minutes),
                ),
              ),
            InfoNote(l10n.settingsRemIndependent),
          ],
        ),
        SettingsGroup(
          children: [
            SwitchRow(
              key: const Key('set-reminder-chime'),
              title: l10n.settingsRemChime,
              description: l10n.settingsRemChimeHelp,
              value: reminders.chime,
              onChanged: (value) => controller.setReminderChime(enabled: value),
            ),
            SettingRow(
              title: l10n.settingsRemChimeTest,
              control: OutlinedButton.icon(
                key: const Key('set-reminder-chime-test'),
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(l10n.settingsRemChimeTest),
                onPressed: () => ref.read(settingsActionsProvider).playChime(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
