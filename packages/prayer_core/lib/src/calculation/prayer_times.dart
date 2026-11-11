import 'package:meta/meta.dart';
import 'package:prayer_core/src/calculation/prayer.dart';

/// The nine times of one civil day, as durations after local midnight.
///
/// A value may be 24 hours or more (Islamic midnight, or Isha at high
/// latitudes): it then falls after 00:00 of the next civil day. A `null`
/// value means the event does not occur that day at that place.
@immutable
class PrayerTimes {
  /// Creates times from a map; missing keys are null.
  PrayerTimes(Map<Prayer, Duration?> values)
    : _values = Map.unmodifiable({
        for (final prayer in Prayer.values) prayer: values[prayer],
      });

  final Map<Prayer, Duration?> _values;

  /// Time of [prayer], or null if it does not occur.
  Duration? operator [](Prayer prayer) => _values[prayer];

  /// Copy with every non-null value replaced by [transform].
  PrayerTimes map(Duration Function(Prayer prayer, Duration value) transform) {
    return PrayerTimes({
      for (final entry in _values.entries)
        entry.key: entry.value == null
            ? null
            : transform(entry.key, entry.value!),
    });
  }

  /// All entries in [Prayer] order.
  Iterable<MapEntry<Prayer, Duration?>> get entries => _values.entries;

  @override
  bool operator ==(Object other) {
    if (other is! PrayerTimes) return false;
    for (final prayer in Prayer.values) {
      if (other[prayer] != this[prayer]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_values.values);

  @override
  String toString() => 'PrayerTimes($_values)';
}
