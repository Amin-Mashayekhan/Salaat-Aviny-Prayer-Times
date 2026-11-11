import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';

/// Section 6: theme, language, digits, clock style and the Hijri adjustment.
class DisplaySection extends ConsumerWidget {
  /// Creates the section.
  const DisplaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final fmt = ref.watch(formatterProvider);

    String signed(int days) =>
        fmt.digits(days > 0 ? '+$days' : (days < 0 ? '−${days.abs()}' : '0'));

    return SettingsGroup(
      children: [
        SettingRow(
          title: l10n.settingsDispTheme,
          stacked: true,
          control: ChoiceChips<ThemeSetting>(
            keyPrefix: 'set-theme',
            semanticsLabel: l10n.settingsDispTheme,
            value: settings.theme,
            options: [
              (ThemeSetting.system, l10n.settingsThemeSystem),
              (ThemeSetting.light, l10n.settingsThemeLight),
              (ThemeSetting.dark, l10n.settingsThemeDark),
            ],
            onChanged: controller.setTheme,
          ),
        ),
        SettingRow(
          title: l10n.settingsDispLanguage,
          description: l10n.settingsDispLanguageHelp,
          stacked: true,
          control: ChoiceChips<AppLanguage>(
            keyPrefix: 'set-language',
            semanticsLabel: l10n.settingsDispLanguage,
            value: settings.language,
            options: [
              (AppLanguage.fa, l10n.settingsLanguageFa),
              (AppLanguage.en, l10n.settingsLanguageEn),
            ],
            onChanged: controller.setLanguage,
          ),
        ),
        SettingRow(
          title: l10n.settingsDispDigits,
          stacked: true,
          control: ChoiceChips<DigitStyle>(
            keyPrefix: 'set-digits',
            semanticsLabel: l10n.settingsDispDigits,
            value: settings.digits,
            options: [
              (DigitStyle.persian, l10n.settingsDigitsPersian),
              (DigitStyle.latin, l10n.settingsDigitsLatin),
            ],
            onChanged: controller.setDigits,
          ),
        ),
        SettingRow(
          title: l10n.settingsDispHour,
          stacked: true,
          control: ChoiceChips<HourFormat>(
            keyPrefix: 'set-hour',
            semanticsLabel: l10n.settingsDispHour,
            value: settings.hourFormat,
            options: [
              (HourFormat.h24, l10n.settingsHour24),
              (HourFormat.h12, l10n.settingsHour12),
            ],
            onChanged: controller.setHourFormat,
          ),
        ),
        SettingRow(
          title: l10n.settingsDispHijri,
          description: l10n.settingsDispHijriHelp,
          control: IntStepper(
            keyPrefix: 'set-hijri',
            semanticsLabel: l10n.settingsDispHijri,
            value: settings.hijriAdjustmentDays,
            min: -AppSettings.maxHijriAdjustment,
            max: AppSettings.maxHijriAdjustment,
            format: signed,
            onChanged: controller.setHijriAdjustment,
          ),
        ),
      ],
    );
  }
}
