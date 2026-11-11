/// The nine times shown by the app, in chronological order of a day.
enum Prayer {
  /// Start of fasting, a configurable number of minutes before [fajr].
  imsak,

  /// Dawn.
  fajr,

  /// Sunrise.
  sunrise,

  /// Midday prayer.
  dhuhr,

  /// Afternoon prayer.
  asr,

  /// Sunset.
  sunset,

  /// Evening prayer (twilight angle, not sunset, for Shia methods).
  maghrib,

  /// Night prayer.
  isha,

  /// Islamic midnight.
  midnight;

  /// Whether this is one of the five daily prayers that can have an azan.
  bool get hasAzan => switch (this) {
    fajr || dhuhr || asr || maghrib || isha => true,
    _ => false,
  };
}
