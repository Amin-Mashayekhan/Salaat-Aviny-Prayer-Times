import 'package:flutter/material.dart';

/// Colours that Material's `ColorScheme` has no slot for.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates the extension.
  const AppColors({
    required this.surfaceCard,
    required this.accentWarm,
    required this.success,
    required this.warning,
    required this.danger,
    required this.skyNight,
    required this.skyDawn,
    required this.skyDay,
    required this.skyDusk,
  });

  /// The light variant.
  static const light = AppColors(
    surfaceCard: Color(0xFFFFFFFF),
    accentWarm: Color(0xFFC2410C),
    success: Color(0xFF15803D),
    warning: Color(0xFFB45309),
    danger: Color(0xFFB91C1C),
    skyNight: [Color(0xFF1E1B4B), Color(0xFF312E81)],
    skyDawn: [Color(0xFF4C3F7A), Color(0xFFE59A75)],
    skyDay: [Color(0xFF2B6CB0), Color(0xFF6BA9E0)],
    skyDusk: [Color(0xFF7C3A5E), Color(0xFFE08A4A)],
  );

  /// The dark variant.
  static const dark = AppColors(
    surfaceCard: Color(0xFF1A211F),
    accentWarm: Color(0xFFFDBA74),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    skyNight: [Color(0xFF0F0D2E), Color(0xFF211F5E)],
    skyDawn: [Color(0xFF2F2650), Color(0xFFB8704E)],
    skyDay: [Color(0xFF1F4E80), Color(0xFF477FB3)],
    skyDusk: [Color(0xFF4F2540), Color(0xFFB86A33)],
  );

  /// Card background.
  final Color surfaceCard;

  /// Highlight for the next prayer and the countdown.
  final Color accentWarm;

  /// Positive status.
  final Color success;

  /// Cautionary status.
  final Color warning;

  /// Error status.
  final Color danger;

  /// Hero gradient at night.
  final List<Color> skyNight;

  /// Hero gradient at dawn.
  final List<Color> skyDawn;

  /// Hero gradient during the day.
  final List<Color> skyDay;

  /// Hero gradient at dusk.
  final List<Color> skyDusk;

  @override
  AppColors copyWith({
    Color? surfaceCard,
    Color? accentWarm,
    Color? success,
    Color? warning,
    Color? danger,
    List<Color>? skyNight,
    List<Color>? skyDawn,
    List<Color>? skyDay,
    List<Color>? skyDusk,
  }) => AppColors(
    surfaceCard: surfaceCard ?? this.surfaceCard,
    accentWarm: accentWarm ?? this.accentWarm,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    skyNight: skyNight ?? this.skyNight,
    skyDawn: skyDawn ?? this.skyDawn,
    skyDay: skyDay ?? this.skyDay,
    skyDusk: skyDusk ?? this.skyDusk,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    List<Color> mix(List<Color> a, List<Color> b) => [
      for (var i = 0; i < a.length; i++) Color.lerp(a[i], b[i], t)!,
    ];
    return AppColors(
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      skyNight: mix(skyNight, other.skyNight),
      skyDawn: mix(skyDawn, other.skyDawn),
      skyDay: mix(skyDay, other.skyDay),
      skyDusk: mix(skyDusk, other.skyDusk),
    );
  }
}

/// Shortcut: `context.appColors`.
extension AppColorsContext on BuildContext {
  /// The [AppColors] of the current theme.
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
