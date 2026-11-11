import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/domain/city.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/location_draft.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/zone_info.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/presentation/location_forms.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';

/// Section 1: saved locations (set active, edit, delete), adding a location
/// from the built-in city database or by typing coordinates, and the time
/// zone of each location (automatic or fixed offset) with the live offset.
class LocationSection extends ConsumerStatefulWidget {
  /// Creates the section.
  const LocationSection({super.key});

  @override
  ConsumerState<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends ConsumerState<LocationSection> {
  String? _editing;
  bool _addCustom = false;
  int _customFormGeneration = 0;
  String? _customAddedName;

  Future<void> _confirmDelete(ResolvedLocation location) async {
    final l10n = AppLocalizations.of(context);
    final language = ref.read(settingsProvider).language;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLocDeleteTitle(location.nameIn(language))),
        content: Text(l10n.settingsLocDeleteBody),
        actions: [
          TextButton(
            key: const Key('set-dialog-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          FilledButton(
            key: const Key('set-loc-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsLocDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ref.read(settingsProvider.notifier).removeLocation(location.id);
    if (_editing == location.id) setState(() => _editing = null);
  }

  void _addCustomLocation(CustomLocationDraft draft) {
    final settings = ref.read(settingsProvider);
    final id = nextCustomLocationId([for (final l in settings.locations) l.id]);
    final failure = ref
        .read(settingsProvider.notifier)
        .addLocation(draft.build(id), activate: false);
    if (failure != null) return;
    setState(() {
      _customAddedName = draft.name.trim();
      _customFormGeneration++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final resolved = ref.watch(savedLocationsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final colors = context.appColors;
    final onlyOne = settings.locations.length <= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          title: l10n.settingsLocSavedTitle,
          description: l10n.settingsLocSavedHelp,
          children: [
            for (final location in resolved)
              _SavedLocationTile(
                key: Key('set-loc-${location.id}'),
                location: location,
                saved: settings.locations.firstWhere(
                  (l) => l.id == location.id,
                ),
                active: location.id == settings.activeLocationId,
                canDelete: !onlyOne,
                editing: _editing == location.id,
                onActivate: () => controller.setActiveLocation(location.id),
                onToggleEdit: () => setState(
                  () => _editing = _editing == location.id ? null : location.id,
                ),
                onDelete: () => _confirmDelete(location),
              ),
            if (onlyOne) InfoNote(l10n.settingsLocDeleteLast),
          ],
        ),
        SettingsGroup(
          title: l10n.settingsLocAddTitle,
          children: [
            ChoiceChips<bool>(
              keyPrefix: 'set-loc-add-mode',
              semanticsLabel: l10n.settingsLocAddTitle,
              value: _addCustom,
              options: [
                (false, l10n.settingsLocAddFromDb),
                (true, l10n.settingsLocAddCustom),
              ],
              onChanged: (value) => setState(() => _addCustom = value),
            ),
            if (_addCustom)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomLocationForm(
                    key: ValueKey('custom-form-$_customFormGeneration'),
                    submitLabel: l10n.settingsLocAdd,
                    onSubmit: _addCustomLocation,
                  ),
                  if (_customAddedName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Gaps.s),
                      child: StatusLine(
                        key: const Key('set-loc-custom-added'),
                        text: l10n.settingsLocAdded(_customAddedName!),
                        icon: Icons.check_circle_outline,
                        color: colors.success,
                      ),
                    ),
                ],
              )
            else
              const _AddFromDatabase(),
          ],
        ),
      ],
    );
  }
}

class _SavedLocationTile extends ConsumerWidget {
  const _SavedLocationTile({
    required this.location,
    required this.saved,
    required this.active,
    required this.canDelete,
    required this.editing,
    required this.onActivate,
    required this.onToggleEdit,
    required this.onDelete,
    super.key,
  });

  final ResolvedLocation location;
  final SavedLocation saved;
  final bool active;
  final bool canDelete;
  final bool editing;
  final VoidCallback onActivate;
  final VoidCallback onToggleEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final id = location.id;
    final info = ref.watch(offsetInEffectProvider(id));
    final controller = ref.read(settingsProvider.notifier);

    final zoneSummary = saved.offset.mode == OffsetMode.fixed
        ? l10n.settingsZoneFixedValue(formatUtcOffset(fmt, info.current))
        : Formatter.isolate(saved.zoneId);
    final coords = l10n.settingsLocCoords(
      fmt.formatNumber(location.latitude, fractionDigits: 3),
      fmt.formatNumber(location.longitude, fractionDigits: 3),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Gaps.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              location.nameIn(language),
              key: Key('set-loc-name-$id'),
              style: theme.textTheme.titleMedium,
            ),
            if (location.isCustom)
              Text(
                l10n.settingsLocCustomBadge,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        Text(
          '$coords · $zoneSummary',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Gaps.s),
        Wrap(
          spacing: Gaps.s,
          runSpacing: Gaps.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (active)
              Chip(
                key: Key('set-loc-active-$id'),
                avatar: const Icon(Icons.check, size: 18),
                label: Text(l10n.settingsLocActive),
              )
            else
              FilledButton.tonal(
                key: Key('set-loc-activate-$id'),
                onPressed: onActivate,
                child: Text(l10n.settingsLocSetActive),
              ),
            TextButton.icon(
              key: Key('set-loc-edit-$id'),
              icon: Icon(editing ? Icons.expand_less : Icons.edit_outlined),
              label: Text(
                editing ? l10n.settingsLocClose : l10n.settingsLocEdit,
              ),
              onPressed: onToggleEdit,
            ),
            IconButton(
              key: Key('set-loc-delete-$id'),
              tooltip: canDelete
                  ? l10n.settingsLocDelete
                  : l10n.settingsLocDeleteLast,
              icon: const Icon(Icons.delete_outline),
              onPressed: canDelete ? onDelete : null,
            ),
          ],
        ),
        if (editing) ...[
          const SizedBox(height: Gaps.m),
          Text(l10n.settingsZoneTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: Gaps.s),
          OffsetModeEditor(
            keyPrefix: 'set-loc-$id-offset',
            value: saved.offset,
            zoneId: saved.zoneId,
            onChanged: (offset) => controller.setLocationOffset(id, offset),
          ),
          const SizedBox(height: Gaps.s),
          OffsetInEffectLines(info: info, keyId: id),
          if (location.isCustom) ...[
            const SizedBox(height: Gaps.l),
            CustomLocationForm(
              key: Key('set-loc-$id-form'),
              keyPrefix: 'set-loc-$id-form',
              initial: saved,
              showOffset: false,
              submitLabel: l10n.settingsLocSave,
              onSubmit: (draft) {
                final current = ref
                    .read(settingsProvider)
                    .locations
                    .firstWhere((l) => l.id == id);
                controller.updateLocation(
                  draft.build(id).withOffset(current.offset),
                );
              },
            ),
          ],
        ],
      ],
    );
  }
}

/// Search field, province filter and result list for the built-in cities.
class _AddFromDatabase extends ConsumerStatefulWidget {
  const _AddFromDatabase();

  @override
  ConsumerState<_AddFromDatabase> createState() => _AddFromDatabaseState();
}

class _AddFromDatabaseState extends ConsumerState<_AddFromDatabase> {
  final _query = TextEditingController();
  int? _province;
  String? _addedName;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<City> _results() {
    final repository = ref.read(locationRepositoryProvider);
    final query = _query.text.trim();
    if (query.isEmpty) {
      return _province == null
          ? repository.provinceCentres
          : repository.citiesOf(_province!);
    }
    final found = repository.search(query, limit: 200);
    return [
      for (final city in found)
        if (_province == null || city.provinceId == _province) city,
    ].take(50).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final repository = ref.watch(locationRepositoryProvider);
    final settings = ref.watch(settingsProvider);
    final language = settings.language;
    final savedIds = {for (final l in settings.locations) l.id};
    final results = _results();

    String provinceName(Province p) =>
        language == AppLanguage.fa ? p.nameFa : p.nameEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Gaps.m),
        TextField(
          key: const Key('set-loc-search'),
          controller: _query,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search),
            labelText: l10n.settingsLocSearchHint,
          ),
        ),
        const SizedBox(height: Gaps.m),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AppDropdown<int?>(
              key: const Key('set-loc-province'),
              value: _province,
              semanticsLabel: l10n.settingsLocProvince,
              itemKeyPrefix: 'set-loc-province-item',
              options: [
                (null, l10n.settingsLocAllProvinces),
                for (final p in repository.provinces) (p.id, provinceName(p)),
              ],
              onChanged: (value) => setState(() => _province = value),
            ),
          ),
        ),
        const SizedBox(height: Gaps.s),
        SizedBox(
          height: 280,
          child: results.isEmpty
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(l10n.settingsLocNoResults),
                )
              : ListView.builder(
                  key: const Key('set-loc-results'),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final city = results[index];
                    final saved = savedIds.contains(builtinLocationId(city.id));
                    final province = repository.provinceById(city.provinceId);
                    final name = language == AppLanguage.fa
                        ? city.nameFa
                        : city.nameEn;
                    return Padding(
                      key: Key('set-loc-result-${city.id}'),
                      padding: const EdgeInsets.symmetric(vertical: Gaps.s / 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: theme.textTheme.bodyLarge),
                                if (province != null)
                                  Text(
                                    provinceName(province),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Gaps.s),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: saved
                                ? Text(
                                    l10n.settingsLocAlreadySaved,
                                    style: theme.textTheme.labelLarge,
                                  )
                                : TextButton(
                                    key: Key('set-loc-add-${city.id}'),
                                    onPressed: () {
                                      final failure = ref
                                          .read(settingsProvider.notifier)
                                          .addLocation(
                                            SavedLocation.builtin(
                                              id: builtinLocationId(city.id),
                                              cityId: city.id,
                                            ),
                                            activate: false,
                                          );
                                      if (failure == null) {
                                        setState(() => _addedName = name);
                                      }
                                    },
                                    child: Text(l10n.settingsLocAdd),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (_addedName != null)
          Padding(
            padding: const EdgeInsets.only(top: Gaps.s),
            child: StatusLine(
              key: const Key('set-loc-added'),
              text: l10n.settingsLocAdded(_addedName!),
              icon: Icons.check_circle_outline,
              color: colors.success,
            ),
          ),
      ],
    );
  }
}
