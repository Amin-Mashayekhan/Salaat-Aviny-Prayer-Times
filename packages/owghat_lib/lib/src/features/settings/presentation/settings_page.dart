import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/presentation/app_section.dart';
import 'package:owghat_lib/src/features/settings/presentation/azan_section.dart';
import 'package:owghat_lib/src/features/settings/presentation/calculation_section.dart';
import 'package:owghat_lib/src/features/settings/presentation/display_section.dart';
import 'package:owghat_lib/src/features/settings/presentation/location_section.dart';
import 'package:owghat_lib/src/features/settings/presentation/reminders_section.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';
import 'package:owghat_lib/src/features/settings/presentation/time_section.dart';

/// Icon of each section in the section list.
IconData _iconOf(SettingsSection section) => switch (section) {
  SettingsSection.location => Icons.place_outlined,
  SettingsSection.calculation => Icons.calculate_outlined,
  SettingsSection.azan => Icons.volume_up_outlined,
  SettingsSection.reminders => Icons.notifications_outlined,
  SettingsSection.time => Icons.schedule_outlined,
  SettingsSection.display => Icons.palette_outlined,
  SettingsSection.app => Icons.tune_outlined,
  SettingsSection.about => Icons.info_outline,
};

/// The settings screen: the list of
/// sections on the start side and the open section beside it. Below
/// [collapseWidth] (scaled with the text size) the list becomes a drop-down.
/// Every change applies at once; a small tick confirms it.
class SettingsPage extends ConsumerWidget {
  /// Creates the page.
  const SettingsPage({super.key});

  /// Width below which the section list collapses into a drop-down.
  static const double collapseWidth = 560;

  /// Width of the section list.
  static const double listWidth = 208;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final section = ref.watch(selectedSettingsSectionProvider);
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final content = _SectionContent(section: section);

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < collapseWidth * scale;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gaps.l,
                  Gaps.l,
                  Gaps.l,
                  Gaps.s,
                ),
                child: AppDropdown<SettingsSection>(
                  key: const Key('settings-section-dropdown'),
                  value: section,
                  semanticsLabel: l10n.settingsSectionsLabel,
                  itemKeyPrefix: 'settings-section-item',
                  options: [
                    for (final s in SettingsSection.values) (s, s.title(l10n)),
                  ],
                  onChanged: ref
                      .read(selectedSettingsSectionProvider.notifier)
                      .select,
                ),
              ),
              Expanded(child: content),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: listWidth,
              child: Semantics(
                label: l10n.settingsSectionsLabel,
                container: true,
                child: ListView(
                  padding: const EdgeInsets.all(Gaps.s),
                  children: [
                    for (final s in SettingsSection.values)
                      ListTile(
                        key: Key('settings-section-${s.name}'),
                        selected: s == section,
                        selectedTileColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Radii.control),
                        ),
                        dense: true,
                        leading: Icon(_iconOf(s)),
                        title: Text(s.title(l10n)),
                        onTap: () => ref
                            .read(selectedSettingsSectionProvider.notifier)
                            .select(s),
                      ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class _SectionContent extends ConsumerWidget {
  const _SectionContent({required this.section});

  final SettingsSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final body = switch (section) {
      SettingsSection.location => const LocationSection(),
      SettingsSection.calculation => const CalculationSection(),
      SettingsSection.azan => const AzanSection(),
      SettingsSection.reminders => const RemindersSection(),
      SettingsSection.time => const TimeSection(),
      SettingsSection.display => const DisplaySection(),
      SettingsSection.app => const AppSection(),
      SettingsSection.about => Builder(
        key: const Key('settings-about-slot'),
        builder: ref.watch(aboutSectionBuilderProvider),
      ),
    };
    return SingleChildScrollView(
      key: PageStorageKey<SettingsSection>(section),
      padding: const EdgeInsets.all(Gaps.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    section.title(l10n),
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ),
              const SavedTick(),
            ],
          ),
          const SizedBox(height: Gaps.l),
          body,
        ],
      ),
    );
  }
}
