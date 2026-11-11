import 'package:timezone/data/latest.dart' as tz_data;

bool _initialized = false;

/// Loads the bundled IANA time-zone database once.
///
/// `package:timezone` bundles the tz database release named in its changelog
/// (2026e at the time of writing). Iran abolished daylight saving time in
/// 2022; the regression test `iran_has_no_dst_test.dart` fails the build if
/// an older database is ever bundled.
void ensureTimeZonesInitialized() {
  if (_initialized) return;
  tz_data.initializeTimeZones();
  _initialized = true;
}
