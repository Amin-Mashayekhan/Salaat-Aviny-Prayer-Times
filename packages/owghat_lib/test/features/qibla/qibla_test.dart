import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/qibla/application/qibla_providers.dart';
import 'package:owghat_lib/src/features/qibla/presentation/compass_painter.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/app_harness.dart';
import '../../support/test_data.dart';

// 20 Aban 1405, 15:30 in Tehran: the sun is up, in the south-west.
final _afternoon = DateTime.utc(2026, 11, 11, 12);

// 03:30 in Tehran: night.
final _night = DateTime.utc(2026, 11, 11);

void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  Future<AppHarness> open(
    WidgetTester tester, {
    AppSettings? settings,
    DateTime? now,
    Size size = const Size(1200, 800),
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    final harness = await AppHarness.pump(
      tester,
      repository: repo,
      now: now ?? _afternoon,
      settings: settings,
      size: size,
      textScale: textScale,
      brightness: brightness,
    );
    harness.container
        .read(destinationProvider.notifier)
        .select(Destination.qibla);
    await tester.pumpAndSettle();
    return harness;
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  QiblaCompassPainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(find.byKey(const Key('qibla-compass')))
              .painter!
          as QiblaCompassPainter;

  group('numbers', () {
    testWidgets('bearing, compass point and distance of Tehran', (
      tester,
    ) async {
      final harness = await open(tester);
      final info = harness.container.read(qiblaInfoProvider);
      expect(info.bearing, closeTo(218.4, 0.2));
      expect(info.compassIndex, 5);
      final place = harness.container.read(activeLocationProvider);
      expect(info.bearing, qiblaBearing(place.latitude, place.longitude));
      expect(
        info.distanceKm,
        distanceToKaabaKm(place.latitude, place.longitude),
      );
      // Tehran is roughly 1 950 km from Mecca in a straight line.
      expect(info.distanceKm, inInclusiveRange(1900, 2000));
      expect(text(tester, 'qibla-bearing'), '۲۱۸٫۴° (جنوب غربی)');
      final km = harness.container
          .read(formatterProvider)
          .formatNumber(info.distanceKm.round());
      expect(text(tester, 'qibla-distance'), '$km کیلومتر');
      expect(text(tester, 'qibla-place'), 'جهت قبله برای تهران');
    });

    testWidgets('the sun now comes from the clock, once a minute', (
      tester,
    ) async {
      final harness = await open(tester);
      final place = harness.container.read(activeLocationProvider);
      final first = harness.container.read(sunNowProvider);
      final expected = sunDirection(
        _afternoon,
        latitude: place.latitude,
        longitude: place.longitude,
      );
      expect(first.azimuth, expected.azimuth);
      expect(first.altitude, expected.altitude);
      expect(first.isUp, isTrue);
      // Mid-afternoon in November: south-west, low.
      expect(first.azimuth, inInclusiveRange(200, 250));
      expect(first.altitude, inInclusiveRange(5, 30));
      expect(painter(tester).sunAzimuth, first.azimuth);

      // Thirty seconds later it is still the same minute.
      await harness.setNow(tester, _afternoon.add(const Duration(seconds: 30)));
      expect(harness.container.read(sunNowProvider), first);

      // Ten minutes later the sun has moved and the drawing follows.
      await harness.setNow(tester, _afternoon.add(const Duration(minutes: 10)));
      final later = harness.container.read(sunNowProvider);
      expect(later.azimuth, greaterThan(first.azimuth + 1));
      expect(later.altitude, lessThan(first.altitude));
      expect(painter(tester).sunAzimuth, later.azimuth);
      expect(
        text(tester, 'qibla-sun-now'),
        startsWith(
          'سمت ${harness.container.read(formatterProvider).formatNumber(later.azimuth, fractionDigits: 1)}°',
        ),
      );
    });

    testWidgets('at night the sun marker is hidden', (tester) async {
      final harness = await open(tester, now: _night);
      expect(harness.container.read(sunNowProvider).isUp, isFalse);
      expect(painter(tester).sunAzimuth, isNull);
      expect(text(tester, 'qibla-sun-now'), 'خورشید زیر افق است.');
      // And it comes back after sunrise.
      await harness.setNow(tester, _afternoon);
      expect(painter(tester).sunAzimuth, isNotNull);
    });

    testWidgets('sun in the qibla direction today, with its explanation', (
      tester,
    ) async {
      final harness = await open(tester);
      final today = harness.container.read(sunOnQiblaTodayProvider);
      final place = harness.container.read(activeLocationProvider);
      final bearing = qiblaBearing(place.latitude, place.longitude);
      expect(today.date, CivilDate(2026, 11, 11));
      expect(today.utcOffset, const Duration(hours: 3, minutes: 30));
      final at = today.inDirection!;
      // The sun really is in the qibla direction at that instant, above the
      // horizon, in the afternoon.
      final sun = sunDirection(
        at,
        latitude: place.latitude,
        longitude: place.longitude,
      );
      expect(sun.azimuth, closeTo(bearing, 0.3));
      expect(sun.altitude, greaterThan(0));
      final fmt = harness.container.read(formatterProvider);
      expect(
        text(tester, 'qibla-sun-in'),
        fmt.formatInstant(at.add(const Duration(seconds: 30)), today.utcOffset),
      );
      // In November the sun never stands opposite the qibla in Tehran.
      expect(today.opposite, isNull);
      expect(text(tester, 'qibla-sun-opposite'), '—');
      expect(
        find.text(
          'در این لحظه خورشید دقیقاً در جهت قبله است؛ رو به خورشید بایستید.',
        ),
        findsOneWidget,
      );
      expect(find.text('امروز رخ نمی‌دهد.'), findsOneWidget);
    });

    testWidgets('sun opposite the qibla (Jakarta in November)', (tester) async {
      final harness = await open(tester);
      harness.settings.addLocation(
        const SavedLocation.custom(
          id: 'jkt',
          name: 'Jakarta',
          latitude: -6.2,
          longitude: 106.85,
          zoneId: 'Asia/Jakarta',
        ),
      );
      await tester.pumpAndSettle();
      final today = harness.container.read(sunOnQiblaTodayProvider);
      expect(today.utcOffset, const Duration(hours: 7));
      expect(today.opposite, isNotNull);
      final fmt = harness.container.read(formatterProvider);
      expect(
        text(tester, 'qibla-sun-opposite'),
        fmt.formatInstant(
          today.opposite!.add(const Duration(seconds: 30)),
          today.utcOffset,
        ),
      );
      expect(
        find.text('در این لحظه سایه‌ی شاخص جهت قبله را نشان می‌دهد.'),
        findsOneWidget,
      );
      expect(text(tester, 'qibla-place'), 'جهت قبله برای Jakarta');
    });
  });

  group('texts', () {
    testWidgets('Persian: names, note, labels', (tester) async {
      await open(tester);
      expect(
        text(tester, 'qibla-note'),
        'رایانه قطب‌نما ندارد؛ شکل نسبت به شمال حقیقی رسم شده است (شمال بالاست).',
      );
      expect(painter(tester).cardinals, ['شمال', 'شرق', 'جنوب', 'غرب']);
      expect(find.text('خورشید و قبله امروز'), findsOneWidget);
      expect(find.text('فاصله تا کعبه'), findsOneWidget);
    });

    testWidgets('English: names, note, labels, Latin digits', (tester) async {
      await open(tester, settings: englishSettings);
      expect(text(tester, 'qibla-bearing'), '218.4° (south-west)');
      expect(text(tester, 'qibla-place'), 'Qibla direction for Tehran');
      expect(painter(tester).cardinals, ['N', 'E', 'S', 'W']);
      expect(
        text(tester, 'qibla-note'),
        'A PC has no compass, so the drawing is relative to true north '
        '(north is at the top).',
      );
      expect(text(tester, 'qibla-distance'), endsWith(' km'));
      expect(find.text('Distance to the Kaaba'), findsOneWidget);
      expect(
        find.text(
          'At this moment the sun is exactly in the qibla direction; '
          'face the sun.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the compass has a spoken description', (tester) async {
      await open(tester, settings: englishSettings);
      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp('qibla is at 218.4 degrees')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('painter', () {
    const colors = CompassColors(
      face: Colors.white,
      ring: Colors.grey,
      tick: Colors.black54,
      label: Colors.black,
      north: Colors.red,
      qibla: Colors.teal,
      sun: Colors.orange,
    );

    QiblaCompassPainter make({
      double bearing = 218.4,
      double? sun = 225,
      TextScaler scaler = TextScaler.noScaling,
      TextDirection direction = TextDirection.rtl,
    }) => QiblaCompassPainter(
      qiblaBearing: bearing,
      sunAzimuth: sun,
      cardinals: const ['N', 'E', 'S', 'W'],
      colors: colors,
      textDirection: direction,
      textScaler: scaler,
    );

    void paintOn(QiblaCompassPainter painter, Size size) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, size);
      recorder.endRecording().dispose();
    }

    test('paints for every bearing and sun position without throwing', () {
      for (var bearing = 0.0; bearing < 360; bearing += 37.5) {
        for (final sun in <double?>[null, 0, 90, 225, 359.9]) {
          paintOn(make(bearing: bearing, sun: sun), const Size(380, 380));
        }
      }
    });

    test('paints at odd sizes, text scales and directions', () {
      for (final size in const [
        Size(380, 380),
        Size(120, 300),
        Size(40, 40),
        Size(1, 1),
        Size.zero,
      ]) {
        for (final scaler in const [
          TextScaler.noScaling,
          TextScaler.linear(2),
        ]) {
          for (final direction in TextDirection.values) {
            paintOn(make(scaler: scaler, direction: direction), size);
          }
        }
      }
    });

    test('repaints only when something it draws changed', () {
      final base = make();
      expect(base.shouldRepaint(make()), isFalse);
      expect(base.shouldRepaint(make(bearing: 100)), isTrue);
      expect(base.shouldRepaint(make(sun: 226)), isTrue);
      expect(base.shouldRepaint(make(sun: null)), isTrue);
      expect(
        base.shouldRepaint(make(scaler: const TextScaler.linear(2))),
        isTrue,
      );
      expect(base.shouldRepaint(make(direction: TextDirection.ltr)), isTrue);
    });
  });

  group('layout', () {
    for (final locale in ['fa', 'en']) {
      for (final dark in [false, true]) {
        for (final size in [const Size(1200, 800), const Size(800, 560)]) {
          for (final scale in [1.0, 2.0]) {
            testWidgets('$locale ${dark ? 'dark' : 'light'} '
                '${size.width.toInt()}x${size.height.toInt()} x$scale '
                'has no overflow', (tester) async {
              await open(
                tester,
                settings: locale == 'fa' ? persianSettings : englishSettings,
                size: size,
                textScale: scale,
                brightness: dark ? Brightness.dark : Brightness.light,
              );
              expect(tester.takeException(), isNull);
              expect(find.byKey(const Key('qibla-compass')), findsOneWidget);
              expect(find.byKey(const Key('qibla-note')), findsOneWidget);
            });
          }
        }
      }
    }
  });
}
