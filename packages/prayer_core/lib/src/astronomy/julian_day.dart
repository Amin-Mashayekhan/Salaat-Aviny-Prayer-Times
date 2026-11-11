/// Julian Day at 00:00 UT of a proleptic Gregorian calendar date.
double julianDay(int year, int month, int day) {
  var y = year;
  var m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  return (365.25 * (y + 4716)).floorToDouble() +
      (30.6001 * (m + 1)).floorToDouble() +
      day +
      b -
      1524.5;
}

/// Julian Day of a UTC instant (fractional).
double julianDayOfInstant(DateTime utc) {
  assert(utc.isUtc, 'julianDayOfInstant needs a UTC DateTime');
  return utc.microsecondsSinceEpoch / Duration.microsecondsPerDay + 2440587.5;
}
