import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/number_input.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';
import 'package:prayer_core/prayer_core.dart';

/// The Maghrib angle used when the user turns "Maghrib at sunset" off.
const double _defaultMaghribAngle = 4.5;

/// Isha minutes used when the user switches Isha to "minutes after Maghrib".
const double _defaultIshaMinutes = 90;

/// Isha angle used when the user switches Isha back to a sun angle.
const double _defaultIshaAngle = 14;

String _methodName(AppLocalizations l10n, CalculationMethod method) =>
    switch (method) {
      CalculationMethod.tehran => l10n.settingsMethodTehran,
      CalculationMethod.jafari => l10n.settingsMethodJafari,
      CalculationMethod.mwl => l10n.settingsMethodMwl,
      CalculationMethod.isna => l10n.settingsMethodIsna,
      CalculationMethod.egypt => l10n.settingsMethodEgypt,
      CalculationMethod.makkah => l10n.settingsMethodMakkah,
      CalculationMethod.karachi => l10n.settingsMethodKarachi,
      CalculationMethod.custom => l10n.settingsMethodCustom,
    };

/// Section 2: method, angles, rules, Imsak, per-prayer minute offsets, which
/// rows to show, and a live preview of today's nine times.
class CalculationSection extends ConsumerWidget {
  /// Creates the section.
  const CalculationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final calc = ref.watch(settingsProvider.select((s) => s.calculation));
    final display = ref.watch(settingsProvider.select((s) => s.display));
    final controller = ref.read(settingsProvider.notifier);
    final fmt = ref.watch(formatterProvider);
    final params = calc.params;
    final method = calc.method;
    final base = ref.watch(calculationBaseMethodProvider);

    String number(double value) {
      final trimmed = value
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'\.?0+$'), '');
      final dot = trimmed.indexOf('.');
      return fmt.formatNumber(
        value,
        fractionDigits: dot < 0 ? 0 : trimmed.length - dot - 1,
      );
    }

    CalculationParams current() =>
        ref.read(settingsProvider).calculation.params;

    // Validates and applies a typed decimal; returns the error text.
    String? commit(
      String text, {
      required double min,
      required double max,
      required SettingsFailure? Function(double value) apply,
    }) {
      final value = parseNumberInput(text);
      if (value != null && value >= min && value <= max) {
        if (apply(value) == null) return null;
      }
      return l10n.settingsInvalidNumber(
        fmt.formatNumber(min),
        fmt.formatNumber(max),
      );
    }

    final ishaIsAngle = params.ishaAngle != null;
    final sunsetMaghrib = params.maghribAngle == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          children: [
            SettingRow(
              title: l10n.settingsCalcMethod,
              description: l10n.settingsCalcMethodHelp,
              stacked: true,
              controlWidth: 420,
              control: AppDropdown<CalculationMethod>(
                key: const Key('set-calc-method'),
                value: method,
                semanticsLabel: l10n.settingsCalcMethod,
                itemKeyPrefix: 'set-calc-method-item',
                options: [
                  for (final m in CalculationMethod.values)
                    (m, _methodName(l10n, m)),
                ],
                // "Custom" can only be reached by editing a number, so it is
                // listed (to show the state) but not selectable.
                disabledValues: const {CalculationMethod.custom},
                onChanged: controller.applyMethod,
              ),
            ),
            SettingRow(
              title: l10n.settingsCalcFajrAngle,
              description: l10n.settingsCalcAngleHelp,
              controlWidth: 140,
              control: CommitField(
                key: const Key('set-calc-fajr'),
                value: number(params.fajrAngle),
                semanticsLabel: l10n.settingsCalcFajrAngle,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onCommit: (text) => commit(
                  text,
                  min: 5,
                  max: 30,
                  apply: (v) =>
                      controller.setParams(current().copyWith(fajrAngle: v)),
                ),
              ),
            ),
            SwitchRow(
              key: const Key('set-calc-maghrib-sunset'),
              title: l10n.settingsCalcMaghribSunset,
              description: l10n.settingsCalcMaghribSunsetHelp,
              value: sunsetMaghrib,
              onChanged: (value) => controller.setParams(
                current().copyWith(
                  maghribAngle: () => value ? null : _defaultMaghribAngle,
                ),
              ),
            ),
            if (!sunsetMaghrib)
              SettingRow(
                title: l10n.settingsCalcMaghribAngle,
                description: l10n.settingsCalcAngleHelp,
                controlWidth: 140,
                control: CommitField(
                  key: const Key('set-calc-maghrib'),
                  value: number(params.maghribAngle!),
                  semanticsLabel: l10n.settingsCalcMaghribAngle,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onCommit: (text) => commit(
                    text,
                    min: 0,
                    max: 10,
                    apply: (v) => controller.setParams(
                      current().copyWith(maghribAngle: () => v),
                    ),
                  ),
                ),
              ),
            SettingRow(
              title: l10n.settingsCalcIshaMode,
              stacked: true,
              control: ChoiceChips<bool>(
                keyPrefix: 'set-calc-isha-mode',
                semanticsLabel: l10n.settingsCalcIshaMode,
                value: ishaIsAngle,
                options: [
                  (true, l10n.settingsCalcIshaModeAngle),
                  (false, l10n.settingsCalcIshaModeMinutes),
                ],
                onChanged: (angle) => controller.setParams(
                  current().copyWith(
                    ishaAngle: () => angle ? _defaultIshaAngle : null,
                    ishaMinutes: () => angle ? null : _defaultIshaMinutes,
                  ),
                ),
              ),
            ),
            if (ishaIsAngle)
              SettingRow(
                title: l10n.settingsCalcIshaAngle,
                description: l10n.settingsCalcAngleHelp,
                controlWidth: 140,
                control: CommitField(
                  key: const Key('set-calc-isha-angle'),
                  value: number(params.ishaAngle!),
                  semanticsLabel: l10n.settingsCalcIshaAngle,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onCommit: (text) => commit(
                    text,
                    min: 5,
                    max: 30,
                    apply: (v) => controller.setParams(
                      current().copyWith(ishaAngle: () => v),
                    ),
                  ),
                ),
              )
            else
              SettingRow(
                title: l10n.settingsCalcIshaMinutes,
                controlWidth: 140,
                control: CommitField(
                  key: const Key('set-calc-isha-minutes'),
                  value: number(params.ishaMinutes!),
                  semanticsLabel: l10n.settingsCalcIshaMinutes,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onCommit: (text) => commit(
                    text,
                    min: 0,
                    max: 240,
                    apply: (v) => controller.setParams(
                      current().copyWith(ishaMinutes: () => v),
                    ),
                  ),
                ),
              ),
            SettingRow(
              title: l10n.settingsCalcMidnight,
              controlWidth: 320,
              control: AppDropdown<MidnightRule>(
                key: const Key('set-calc-midnight'),
                value: params.midnight,
                semanticsLabel: l10n.settingsCalcMidnight,
                itemKeyPrefix: 'set-calc-midnight-item',
                options: [
                  (MidnightRule.standard, l10n.settingsMidnightStandard),
                  (MidnightRule.jafari, l10n.settingsMidnightJafari),
                ],
                onChanged: (v) =>
                    controller.setParams(current().copyWith(midnight: v)),
              ),
            ),
            SettingRow(
              title: l10n.settingsCalcAsr,
              controlWidth: 320,
              control: AppDropdown<AsrRule>(
                key: const Key('set-calc-asr'),
                value: params.asr,
                semanticsLabel: l10n.settingsCalcAsr,
                itemKeyPrefix: 'set-calc-asr-item',
                options: [
                  (AsrRule.standard, l10n.settingsAsrStandard),
                  (AsrRule.hanafi, l10n.settingsAsrHanafi),
                ],
                onChanged: (v) =>
                    controller.setParams(current().copyWith(asr: v)),
              ),
            ),
            SettingRow(
              title: l10n.settingsCalcHighLat,
              description: l10n.settingsCalcHighLatHelp,
              controlWidth: 240,
              control: AppDropdown<HighLatitudeRule>(
                key: const Key('set-calc-highlat'),
                value: params.highLatitude,
                semanticsLabel: l10n.settingsCalcHighLat,
                itemKeyPrefix: 'set-calc-highlat-item',
                options: [
                  (HighLatitudeRule.none, l10n.settingsHighLatNone),
                  (
                    HighLatitudeRule.nightMiddle,
                    l10n.settingsHighLatNightMiddle,
                  ),
                  (HighLatitudeRule.oneSeventh, l10n.settingsHighLatOneSeventh),
                  (HighLatitudeRule.angleBased, l10n.settingsHighLatAngleBased),
                ],
                onChanged: (v) =>
                    controller.setParams(current().copyWith(highLatitude: v)),
              ),
            ),
            SettingRow(
              title: l10n.settingsCalcImsak,
              description: l10n.settingsCalcImsakHelp,
              control: IntStepper(
                keyPrefix: 'set-calc-imsak',
                semanticsLabel: l10n.settingsCalcImsak,
                value: params.imsakMinutes.round(),
                min: 0,
                max: 60,
                format: fmt.formatNumber,
                onChanged: (v) => controller.setParams(
                  current().copyWith(imsakMinutes: v.toDouble()),
                ),
              ),
            ),
            SettingRow(
              title: l10n.settingsCalcRestore,
              description: l10n.settingsCalcRestoreHelp(
                _methodName(l10n, base),
              ),
              stacked: true,
              control: OutlinedButton.icon(
                key: const Key('set-calc-restore'),
                icon: const Icon(Icons.settings_backup_restore),
                label: Text(l10n.settingsCalcRestore),
                onPressed: params == base.params
                    ? null
                    : () => controller.setParams(base.params),
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: l10n.settingsCalcOffsetsTitle,
          description: l10n.settingsCalcOffsetsHelp(
            fmt.formatNumber(CalculationSettings.maxOffsetMinutes),
          ),
          children: [
            for (final prayer in Prayer.values)
              SettingRow(
                key: Key('set-offset-row-${prayer.name}'),
                title: prayer.label(l10n),
                control: IntStepper(
                  keyPrefix: 'set-offset-${prayer.name}',
                  semanticsLabel: prayer.label(l10n),
                  value: calc.offsetsMinutes[prayer] ?? 0,
                  min: -CalculationSettings.maxOffsetMinutes,
                  max: CalculationSettings.maxOffsetMinutes,
                  format: (minutes) => fmt.digits(
                    minutes > 0
                        ? '+$minutes'
                        : (minutes < 0 ? '−${minutes.abs()}' : '0'),
                  ),
                  onChanged: (minutes) =>
                      controller.setPrayerOffset(prayer, minutes),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                key: const Key('set-offsets-reset'),
                icon: const Icon(Icons.restart_alt),
                label: Text(l10n.settingsCalcOffsetsReset),
                onPressed: calc.offsetsMinutes.isEmpty
                    ? null
                    : controller.resetPrayerOffsets,
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: l10n.settingsCalcRowsTitle,
          description: l10n.settingsCalcRowsHelp,
          children: [
            for (final prayer in const [
              Prayer.imsak,
              Prayer.asr,
              Prayer.isha,
              Prayer.sunset,
            ])
              SwitchRow(
                key: Key('set-rows-${prayer.name}'),
                title: prayer.label(l10n),
                value: display.shows(prayer),
                onChanged: (value) => controller.setDisplay(switch (prayer) {
                  Prayer.imsak => display.copyWith(showImsak: value),
                  Prayer.asr => display.copyWith(showAsr: value),
                  Prayer.isha => display.copyWith(showIsha: value),
                  _ => display.copyWith(showSunset: value),
                }),
              ),
          ],
        ),
        const _TodayPreview(),
      ],
    );
  }
}

/// The nine times of today for the active location, recalculated with every
/// change of the settings above.
class _TodayPreview extends ConsumerWidget {
  const _TodayPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = ref.watch(formatterProvider);
    final today = ref.watch(todayProvider);
    final day = ref.watch(prayerDayProvider(today));
    final header = ref.watch(dateHeaderProvider(today));
    final theme = Theme.of(context);

    return SettingsGroup(
      title: l10n.settingsCalcPreviewTitle,
      description: l10n.settingsCalcPreviewHelp(header.primary),
      children: [
        Wrap(
          key: const Key('set-preview'),
          spacing: Gaps.l,
          runSpacing: Gaps.m,
          children: [
            for (final prayer in Prayer.values)
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.label(l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      key: Key('set-preview-${prayer.name}'),
                      day.times[prayer] == null
                          ? l10n.homeNoValue
                          : Formatter.isolate(
                              fmt.formatTime(day.times[prayer]!),
                            ),
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
