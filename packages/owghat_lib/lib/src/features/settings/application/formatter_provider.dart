import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// The text of the app language, read without a `BuildContext` (used by
/// providers that build display strings, such as the date header).
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final language = ref.watch(settingsProvider.select((s) => s.language));
  return lookupAppLocalizations(Locale(language.name));
});

/// The formatter that follows the digit style, clock style and language
/// of the settings.
final formatterProvider = Provider<Formatter>((ref) {
  final digits = ref.watch(settingsProvider.select((s) => s.digits));
  final hourFormat = ref.watch(settingsProvider.select((s) => s.hourFormat));
  return Formatter(
    persianDigits: digits == DigitStyle.persian,
    twelveHour: hourFormat == HourFormat.h12,
    l10n: ref.watch(appLocalizationsProvider),
  );
});
