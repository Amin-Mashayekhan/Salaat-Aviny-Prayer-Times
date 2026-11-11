import 'package:flutter/material.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:prayer_core/prayer_core.dart';

/// The five sky looks of the hero card (night appears twice in the cycle).
enum SkyPeriod {
  /// After Isha until Fajr.
  night,

  /// From Imsak or Fajr to sunrise.
  dawn,

  /// From sunrise to sunset.
  day,

  /// From sunset to Isha.
  dusk,
}

/// The sky period after the event [current] (null: before the first event,
/// which is still the night).
SkyPeriod skyPeriodOf(Prayer? current) => switch (current) {
  null => SkyPeriod.night,
  Prayer.imsak || Prayer.fajr => SkyPeriod.dawn,
  Prayer.sunrise || Prayer.dhuhr || Prayer.asr => SkyPeriod.day,
  Prayer.sunset || Prayer.maghrib => SkyPeriod.dusk,
  Prayer.isha || Prayer.midnight => SkyPeriod.night,
};

/// Colours of the hero card: the sky gradient with a scrim baked in so that
/// white text keeps a contrast of at least 4.5:1 (checked by a test).
abstract final class SkyStyle {
  /// Text and marks on the hero card.
  static const Color onSky = Color(0xFFFFFFFF);

  /// Darkening laid over the gradient (40 % black).
  static const Color scrim = Color(0x66000000);

  /// The gradient stops of [period] with the scrim applied.
  static List<Color> gradient(AppColors colors, SkyPeriod period) {
    final stops = switch (period) {
      SkyPeriod.night => colors.skyNight,
      SkyPeriod.dawn => colors.skyDawn,
      SkyPeriod.day => colors.skyDay,
      SkyPeriod.dusk => colors.skyDusk,
    };
    return [for (final c in stops) Color.alphaBlend(scrim, c)];
  }
}
