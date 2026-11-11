import 'package:flutter/material.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';

/// Spacing scale on a 4 px grid.
abstract final class Gaps {
  /// 8 px.
  static const double s = 8;

  /// 12 px.
  static const double m = 12;

  /// 16 px.
  static const double l = 16;

  /// 24 px.
  static const double xl = 24;

  /// 32 px.
  static const double xxl = 32;
}

/// Corner radii.
abstract final class Radii {
  /// Cards.
  static const double card = 16;

  /// Controls.
  static const double control = 12;
}

/// The font family bundled with the app (Persian and Latin).
const String appFontFamily = 'Vazirmatn';

/// Builds the app theme for [brightness].
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0F766E),
    brightness: brightness,
  ).copyWith(surface: dark ? const Color(0xFF111614) : const Color(0xFFFAFAF7));
  final colors = dark ? AppColors.dark : AppColors.light;

  const tabular = [FontFeature.tabularFigures()];
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    fontFamily: appFontFamily,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [colors],
  );
  final text = base.textTheme.copyWith(
    displayLarge: base.textTheme.displayLarge?.copyWith(
      fontSize: 56,
      height: 64 / 56,
      fontWeight: FontWeight.w700,
      fontFeatures: tabular,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      fontSize: 15,
      height: 24 / 15,
      fontFeatures: tabular,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      fontSize: 15,
      height: 24 / 15,
      fontFeatures: tabular,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
    ),
  );

  return base.copyWith(
    textTheme: text,
    cardTheme: CardThemeData(
      color: colors.surfaceCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      minWidth: 72,
      labelType: NavigationRailLabelType.all,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.control),
      ),
    ),
    visualDensity: VisualDensity.standard,
  );
}
