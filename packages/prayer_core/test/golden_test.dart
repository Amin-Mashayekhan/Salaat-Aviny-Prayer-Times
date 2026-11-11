import 'dart:convert';
import 'dart:io';

import 'package:prayer_core/prayer_core.dart';
import 'package:test/test.dart';

const _calculator = PrayerCalculator();

HighLatitudeRule _highLatitude(String id) => switch (id) {
  'none' => HighLatitudeRule.none,
  'night_middle' => HighLatitudeRule.nightMiddle,
  'one_seventh' => HighLatitudeRule.oneSeventh,
  'angle_based' => HighLatitudeRule.angleBased,
  _ => throw ArgumentError('Unknown high latitude rule $id'),
};

String _clock(Duration value) {
  final minutes = minuteOfDay(value);
  return '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';
}

void main() {
  final file = File('../../seed/golden/prayer_times_golden.json');
  final doc = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final vectors = (doc['vectors'] as List).cast<Map<String, dynamic>>();

  test('golden file has the expected size', () {
    expect(vectors.length, 300);
  });

  group('method table equals the golden file', () {
    final methods = doc['methods'] as Map<String, dynamic>;
    for (final entry in methods.entries) {
      test(entry.key, () {
        final expected = entry.value as Map<String, dynamic>;
        final params = CalculationMethod.fromId(entry.key)!.params;
        expect(params.fajrAngle, expected['fajr_angle']);
        expect(params.ishaAngle, (expected['isha_angle'] as num?)?.toDouble());
        expect(
          params.ishaMinutes,
          (expected['isha_minutes'] as num?)?.toDouble(),
        );
        expect(
          params.maghribAngle,
          (expected['maghrib_angle'] as num?)?.toDouble(),
        );
        expect(params.midnight.name, expected['midnight']);
      });
    }
  });

  group('prayer times match the reference', () {
    for (final v in vectors) {
      final name =
          '${v['place']} ${v['date']} ${v['method']} ${v['asr']} '
          '${v['high_latitude']}';
      test(name, () {
        final params = CalculationMethod.fromId(v['method'] as String)!.params
            .copyWith(
              asr: AsrRule.values.byName(v['asr'] as String),
              highLatitude: _highLatitude(v['high_latitude'] as String),
              imsakMinutes: (v['imsak_minutes'] as num).toDouble(),
            );
        final times = _calculator.compute(
          date: CivilDate.parse(v['date'] as String),
          latitude: (v['latitude'] as num).toDouble(),
          longitude: (v['longitude'] as num).toDouble(),
          elevationMeters: (v['elevation_m'] as num).toDouble(),
          utcOffset: Duration(minutes: v['utc_offset_minutes'] as int),
          params: params,
        );
        final seconds = v['seconds'] as Map<String, dynamic>;
        final display = v['display'] as Map<String, dynamic>;
        for (final prayer in Prayer.values) {
          final expectedSeconds = seconds[prayer.name] as int?;
          final actual = times[prayer];
          if (expectedSeconds == null) {
            expect(actual, isNull, reason: '${prayer.name} should not occur');
            expect(display[prayer.name], isNull);
            continue;
          }
          expect(actual, isNotNull, reason: '${prayer.name} should occur');
          final actualSeconds =
              actual!.inMicroseconds / Duration.microsecondsPerSecond;
          expect(
            (actualSeconds - expectedSeconds).abs(),
            lessThanOrEqualTo(1),
            reason: '${prayer.name}: $actualSeconds vs $expectedSeconds',
          );
          expect(
            _clock(actual),
            display[prayer.name],
            reason: '${prayer.name} displayed minute',
          );
        }
      });
    }
  });

  group('qibla bearings match the reference', () {
    for (final q in (doc['qibla'] as List).cast<Map<String, dynamic>>()) {
      test(q['place'] as String, () {
        final bearing = qiblaBearing(
          (q['latitude'] as num).toDouble(),
          (q['longitude'] as num).toDouble(),
        );
        expect(bearing, closeTo((q['bearing_deg'] as num).toDouble(), 0.01));
      });
    }
  });
}
