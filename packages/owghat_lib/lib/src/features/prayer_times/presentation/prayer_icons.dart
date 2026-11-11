import 'package:flutter/material.dart';
import 'package:prayer_core/prayer_core.dart';

/// The fixed icon of each time (dawn, sunrise, sun, low sun, sunset,
/// rising moon, moon, midnight star).
IconData prayerIcon(Prayer prayer) => switch (prayer) {
  Prayer.imsak => Icons.nights_stay_rounded,
  Prayer.fajr => Icons.wb_twilight_rounded,
  Prayer.sunrise => Icons.wb_sunny_outlined,
  Prayer.dhuhr => Icons.wb_sunny_rounded,
  Prayer.asr => Icons.brightness_6_rounded,
  Prayer.sunset => Icons.wb_twilight_outlined,
  Prayer.maghrib => Icons.nightlight_outlined,
  Prayer.isha => Icons.dark_mode_rounded,
  Prayer.midnight => Icons.star_rounded,
};
