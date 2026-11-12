import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// The sections of the settings screen, in display order.
enum SettingsSection {
  /// Saved locations, time zone.
  location,

  /// Method, angles, offsets, rows.
  calculation,

  /// Azan sounds and volume.
  azan,

  /// Reminders before the azan.
  reminders,

  /// Network time check and clock diagnostics.
  time,

  /// Theme, language, digits, clock style.
  display,

  /// Start-up behaviour, backup, reset.
  app,

  /// Version, licences, diagnostics (built by `aboutSectionBuilderProvider`).
  about;

  /// The localised section title.
  String title(AppLocalizations l10n) => switch (this) {
    location => l10n.settingsSectionLocation,
    calculation => l10n.settingsSectionCalculation,
    azan => l10n.settingsSectionAzan,
    reminders => l10n.settingsSectionReminders,
    time => l10n.settingsSectionTime,
    display => l10n.settingsSectionDisplay,
    app => l10n.settingsSectionApp,
    about => l10n.settingsSectionAbout,
  };
}

/// The section that is open. Other screens can call `select` to deep-link
/// (for example the "Calculation settings" link of the home screen).
class SelectedSettingsSection extends Notifier<SettingsSection> {
  @override
  SettingsSection build() => SettingsSection.location;

  /// Opens [section].
  // A method reads better than a setter at call sites such as onTap.
  // ignore: use_setters_to_change_properties
  void select(SettingsSection section) => state = section;
}

/// Provider of the open settings section.
final selectedSettingsSectionProvider =
    NotifierProvider<SelectedSettingsSection, SettingsSection>(
      SelectedSettingsSection.new,
    );

/// Counts the settings changes made while the settings screen is open, so the
/// small "saved" tick can confirm each one.
class SettingsSavedCount extends Notifier<int> {
  @override
  int build() {
    ref.listen(settingsProvider, (previous, next) {
      if (previous != null && previous != next) state = state + 1;
    });
    return 0;
  }
}

/// Provider of the saved-change counter.
final settingsSavedCountProvider = NotifierProvider<SettingsSavedCount, int>(
  SettingsSavedCount.new,
);

/// Builds the "About and diagnostics" section. `bootstrap` overrides it with
/// `AboutDiagnosticsSection`; until then a short placeholder text is shown
/// (for example in widget tests of the settings page alone).
final aboutSectionBuilderProvider = Provider<WidgetBuilder>(
  (ref) =>
      (context) => Text(AppLocalizations.of(context).settingsAboutPlaceholder),
);

/// The built-in method the calculation settings last followed.
///
/// Editing any angle turns the method into "custom", which no longer says
/// which method the user started from; "restore defaults for this method"
/// restores this one. It is screen state only (never written to the settings)
/// and starts as the current method, or Tehran when that is custom.
class CalculationBaseMethod extends Notifier<CalculationMethod> {
  @override
  CalculationMethod build() {
    ref.listen(settingsProvider.select((s) => s.calculation.method), (
      previous,
      next,
    ) {
      if (next != CalculationMethod.custom) state = next;
    });
    final current = ref.read(settingsProvider).calculation.method;
    return current == CalculationMethod.custom
        ? CalculationMethod.tehran
        : current;
  }
}

/// Provider of the method that "restore defaults" returns to.
final calculationBaseMethodProvider =
    NotifierProvider<CalculationBaseMethod, CalculationMethod>(
      CalculationBaseMethod.new,
    );
