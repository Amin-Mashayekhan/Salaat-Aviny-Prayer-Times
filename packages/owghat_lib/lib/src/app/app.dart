import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/app_shell.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// Locale used by the app: follows `settings.language` (Persian by default).
final localeProvider = Provider<Locale>(
  (ref) => Locale(ref.watch(settingsProvider.select((s) => s.language)).name),
);

/// Theme mode used by the app: follows `settings.theme`.
final themeModeProvider = Provider<ThemeMode>(
  (ref) => switch (ref.watch(settingsProvider.select((s) => s.theme))) {
    ThemeSetting.system => ThemeMode.system,
    ThemeSetting.light => ThemeMode.light,
    ThemeSetting.dark => ThemeMode.dark,
  },
);

/// The root widget.
class OwghatApp extends ConsumerWidget {
  /// Creates the app.
  const OwghatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      home: const AppShell(),
    );
  }
}
