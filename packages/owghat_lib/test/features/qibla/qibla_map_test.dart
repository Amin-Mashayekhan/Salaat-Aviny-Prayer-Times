import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/core/platform/device_location.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_device_location.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_place_search.dart';
import 'package:owghat_lib/src/core/platform/place_search.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/qibla/application/qibla_point.dart';
import 'package:owghat_lib/src/features/qibla/presentation/qibla_map_support.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/app_harness.dart';
import '../../support/test_data.dart';

final _now = DateTime.utc(2026, 11, 11, 12);

/// Tiles that always fail to decode, like an unreachable tile server.
class _FailingTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(Uint8List.fromList([1, 2, 3]));
}

void main() {
  late LocationRepository repo;
  late FakeDeviceLocation gps;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  setUp(() {
    gps = FakeDeviceLocation();
  });

  AppSettings withMap(AppSettings base, {bool enabled = true}) =>
      base.copyWith(qibla: QiblaSettings(mapEnabled: enabled));

  Future<AppHarness> open(
    WidgetTester tester, {
    AppSettings? settings,
    Size size = const Size(1200, 800),
    double textScale = 1,
    Brightness brightness = Brightness.light,
    DeviceLocationService? location,
    TileProvider? tiles,
    List<Override> overrides = const [],
  }) async {
    final harness = await AppHarness.pump(
      tester,
      repository: repo,
      now: _now,
      settings: settings ?? withMap(englishSettings),
      size: size,
      textScale: textScale,
      brightness: brightness,
      overrides: [
        deviceLocationProvider.overrideWithValue(location ?? gps),
        qiblaTileProviderProvider.overrideWithValue(
          tiles ?? BlankTileProvider(),
        ),
        ...overrides,
      ],
    );
    harness.container
        .read(destinationProvider.notifier)
        .select(Destination.qibla);
    await tester.pumpAndSettle();
    return harness;
  }

  /// A widget test that runs as if on [platform] (the help card is written
  /// for the operating system); the override is always reset, even when an
  /// expectation fails, because the framework checks it before tear-downs.
  void platformWidgets(
    TargetPlatform platform,
    String description,
    Future<void> Function(WidgetTester tester) body,
  ) {
    testWidgets(description, (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await body(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> chooseSource(WidgetTester tester, IconData icon) async {
    final tile = find.descendant(
      of: find.byKey(const Key('qibla-source')),
      matching: find.byIcon(icon),
    );
    await tester.ensureVisible(tile);
    await tester.pump();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  QiblaPointState choice(AppHarness h) => h.container.read(qiblaPointProvider);

  group('opening the tab', () {
    testWidgets('the Qibla page opens on the map tab', (tester) async {
      await open(tester);
      expect(find.byKey(const Key('qibla-map')), findsOneWidget);
      expect(find.byKey(const Key('qibla-compass')), findsNothing);
    });

    testWidgets('without the map setting only the consent card shows, '
        'and the map widget is not built', (tester) async {
      final h = await open(
        tester,
        settings: withMap(englishSettings, enabled: false),
      );
      expect(find.byKey(const Key('qibla-map-consent')), findsOneWidget);
      expect(find.byKey(const Key('qibla-map')), findsNothing);
      // The numbers do not need the map.
      expect(find.byKey(const Key('qibla-map-bearing')), findsOneWidget);
      expect(h.current.qibla.mapEnabled, isFalse);
    });

    testWidgets('agreeing writes the setting and shows the map; turning it '
        'off brings the consent card back', (tester) async {
      final h = await open(
        tester,
        settings: withMap(englishSettings, enabled: false),
      );
      await tapKey(tester, 'qibla-map-enable');
      expect(h.current.qibla.mapEnabled, isTrue);
      expect(find.byKey(const Key('qibla-map')), findsOneWidget);
      expect(find.byKey(const Key('qibla-map-consent')), findsNothing);

      await tapKey(tester, 'qibla-map-off');
      expect(h.current.qibla.mapEnabled, isFalse);
      expect(find.byKey(const Key('qibla-map-consent')), findsOneWidget);
    });

    testWidgets('the compass tab still works next to it', (tester) async {
      await open(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('qibla-tabs')),
          matching: find.byIcon(Icons.explore_outlined),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('qibla-compass')), findsOneWidget);
      expect(find.byKey(const Key('qibla-map')), findsNothing);
    });
  });

  group('the city source', () {
    testWidgets('shows the bearing, distance and coordinates of Tehran', (
      tester,
    ) async {
      await open(tester);
      expect(text(tester, 'qibla-map-bearing'), contains('218.4'));
      expect(text(tester, 'qibla-map-distance'), contains('1944'));
      expect(text(tester, 'qibla-map-lat'), startsWith('35.6'));
      expect(text(tester, 'qibla-map-lon'), startsWith('51.4'));
      expect(text(tester, 'qibla-source-help'), contains('Tehran'));
    });

    testWidgets('the line has 65 points from the city to the Kaaba', (
      tester,
    ) async {
      await open(tester);
      final layer = tester.widget<PolylineLayer>(find.byType(PolylineLayer));
      final points = layer.polylines.single.points;
      expect(points.length, 65);
      expect(points.first.latitude, closeTo(35.6892, 0.01));
      expect(points.last.latitude, closeTo(kaabaLatitude, 1e-6));
      expect(points.last.longitude, closeTo(kaabaLongitude, 1e-6));
    });

    testWidgets('has a marker for the position, for the Kaaba and an arrow '
        'turned to the qibla bearing', (tester) async {
      await open(tester);
      expect(find.byKey(const Key('qibla-map-you')), findsOneWidget);
      expect(find.byKey(const Key('qibla-map-kaaba')), findsOneWidget);
      final arrow = tester.widget<Transform>(
        find
            .ancestor(
              of: find.byKey(const Key('qibla-map-arrow')),
              matching: find.byType(Transform),
            )
            .first,
      );
      // Tehran to the Kaaba is 218.4 degrees: the arrow is turned that far.
      final angle = arrow.transform.getRotation().row0.y.abs();
      expect(angle, greaterThan(0));
    });
  });

  group('the device source', () {
    testWidgets('finds the position on request and measures from it', (
      tester,
    ) async {
      final h = await open(tester);
      expect(gps.calls, 0, reason: 'nothing is read until the user asks');

      await chooseSource(tester, Icons.my_location);
      expect(gps.calls, 1);
      expect(choice(h).kind, QiblaSourceKind.device);
      expect(text(tester, 'qibla-map-lat'), startsWith('36.2133'));
      expect(text(tester, 'qibla-map-lon'), startsWith('58.7958'));
      expect(text(tester, 'qibla-accuracy'), contains('35'));
      expect(find.byKey(const Key('qibla-locate-failure')), findsNothing);
    });

    testWidgets('shows progress while waiting and ignores a second tap', (
      tester,
    ) async {
      final gate = Completer<void>();
      gps.gate = gate.future;
      final h = await open(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('qibla-source')),
          matching: find.byIcon(Icons.my_location),
        ),
      );
      await tester.pump();
      expect(choice(h).locating, isTrue);
      expect(find.text('Finding your position…'), findsOneWidget);
      final button = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('qibla-locate')),
      );
      expect(button.onPressed, isNull);

      gate.complete();
      await tester.pumpAndSettle();
      expect(choice(h).locating, isFalse);
      expect(gps.calls, 1);
      expect(choice(h).kind, QiblaSourceKind.device);
    });

    for (final entry in {
      DeviceLocationFailure.serviceDisabled: 'Location services are off',
      DeviceLocationFailure.permissionDenied: 'has not allowed this app',
      DeviceLocationFailure.permissionDeniedForever:
          'Location access was refused',
      DeviceLocationFailure.timeout: 'No position arrived in time',
      DeviceLocationFailure.unsupported: 'cannot report a position',
      DeviceLocationFailure.failed: 'could not be read',
    }.entries) {
      testWidgets('${entry.key.name}: explains why and keeps the city', (
        tester,
      ) async {
        gps.failure = DeviceLocationException(entry.key);
        final h = await open(tester);
        await chooseSource(tester, Icons.my_location);
        expect(find.byKey(const Key('qibla-locate-failure')), findsOneWidget);
        expect(text(tester, 'qibla-locate-failure'), contains(entry.value));
        expect(choice(h).kind, QiblaSourceKind.city);
        // The numbers are still those of the city, so the page is usable.
        expect(text(tester, 'qibla-map-lat'), startsWith('35.6'));
        // And the user can try again.
        gps.failure = null;
        await tapKey(tester, 'qibla-locate');
        expect(choice(h).kind, QiblaSourceKind.device);
        expect(find.byKey(const Key('qibla-locate-failure')), findsNothing);
      });
    }

    group('location help card', () {
      const helpFailures = [
        DeviceLocationFailure.serviceDisabled,
        DeviceLocationFailure.permissionDenied,
        DeviceLocationFailure.permissionDeniedForever,
      ];
      for (final failure in helpFailures) {
        platformWidgets(
          TargetPlatform.windows,
          '${failure.name}: Windows shows the four steps and the '
          'open button',
          (tester) async {
            gps.failure = DeviceLocationException(failure);
            await open(tester);
            await chooseSource(tester, Icons.my_location);
            expect(
              find.byKey(const Key('qibla-location-help')),
              findsOneWidget,
            );
            expect(find.text('Open Windows location settings'), findsOneWidget);
            for (var i = 0; i < 4; i++) {
              expect(find.byKey(Key('qibla-help-step-$i')), findsOneWidget);
            }
            expect(
              text(tester, 'qibla-help-step-2'),
              contains('Let desktop apps access your location'),
            );
          },
        );
      }

      platformWidgets(
        TargetPlatform.windows,
        'the button opens the OS settings page and nothing else',
        (tester) async {
          gps.failure = const DeviceLocationException(
            DeviceLocationFailure.permissionDenied,
          );
          await open(tester);
          await chooseSource(tester, Icons.my_location);
          final callsBefore = gps.calls;
          await tapKey(tester, 'qibla-open-os-settings');
          expect(gps.openSettingsCalls, 1);
          expect(
            gps.calls,
            callsBefore,
            reason: 'it must not read the position',
          );
          expect(
            find.byKey(const Key('qibla-open-os-settings-failed')),
            findsNothing,
          );
        },
      );

      platformWidgets(
        TargetPlatform.windows,
        'if the page cannot be opened the steps stay and a note '
        'says so',
        (tester) async {
          gps
            ..failure = const DeviceLocationException(
              DeviceLocationFailure.permissionDenied,
            )
            ..openSettingsResult = false;
          await open(tester);
          await chooseSource(tester, Icons.my_location);
          await tapKey(tester, 'qibla-open-os-settings');
          expect(
            find.byKey(const Key('qibla-open-os-settings-failed')),
            findsOneWidget,
          );
          expect(find.byKey(const Key('qibla-help-step-0')), findsOneWidget);
        },
      );

      platformWidgets(
        TargetPlatform.windows,
        'an error while opening is treated as "could not open"',
        (tester) async {
          final fake = _OpenThrows()
            ..failure = const DeviceLocationException(
              DeviceLocationFailure.permissionDenied,
            );
          await open(tester, location: fake);
          await chooseSource(tester, Icons.my_location);
          await tapKey(tester, 'qibla-open-os-settings');
          expect(
            find.byKey(const Key('qibla-open-os-settings-failed')),
            findsOneWidget,
          );
        },
      );

      platformWidgets(
        TargetPlatform.android,
        'another platform gets a short generic hint',
        (tester) async {
          gps.failure = const DeviceLocationException(
            DeviceLocationFailure.permissionDenied,
          );
          await open(tester);
          await chooseSource(tester, Icons.my_location);
          expect(find.text('Open location settings'), findsOneWidget);
          expect(find.byKey(const Key('qibla-help-step-0')), findsOneWidget);
          expect(find.byKey(const Key('qibla-help-step-1')), findsNothing);
        },
      );

      for (final failure in [
        DeviceLocationFailure.timeout,
        DeviceLocationFailure.unsupported,
        DeviceLocationFailure.failed,
      ]) {
        platformWidgets(
          TargetPlatform.windows,
          '${failure.name}: no settings card (settings would not '
          'help)',
          (tester) async {
            gps.failure = DeviceLocationException(failure);
            await open(tester);
            await chooseSource(tester, Icons.my_location);
            expect(find.byKey(const Key('qibla-location-help')), findsNothing);
          },
        );
      }

      platformWidgets(
        TargetPlatform.windows,
        'Persian: steps use Persian digits and the Persian button',
        (tester) async {
          gps.failure = const DeviceLocationException(
            DeviceLocationFailure.permissionDenied,
          );
          await open(tester, settings: withMap(persianSettings));
          await chooseSource(tester, Icons.my_location);
          expect(find.text('باز کردن تنظیمات موقعیت ویندوز'), findsOneWidget);
          expect(find.text('۱'), findsOneWidget);
          expect(find.text('۴'), findsOneWidget);
        },
      );
    });

    testWidgets('an unexpected error is reported as a generic failure', (
      tester,
    ) async {
      final broken = _ThrowingLocation();
      final h = await open(tester, location: broken);
      await chooseSource(tester, Icons.my_location);
      expect(choice(h).failure, DeviceLocationFailure.failed);
      expect(find.byKey(const Key('qibla-locate-failure')), findsOneWidget);
    });

    testWidgets('an impossible fix is rejected', (tester) async {
      gps.fix = const DeviceFix(latitude: 123, longitude: 5);
      final h = await open(tester);
      await chooseSource(tester, Icons.my_location);
      expect(choice(h).failure, DeviceLocationFailure.failed);
      expect(choice(h).kind, QiblaSourceKind.city);
    });

    testWidgets('going back to the city and to the device again reuses the '
        'last fix without asking twice', (tester) async {
      final h = await open(tester);
      await chooseSource(tester, Icons.my_location);
      await chooseSource(tester, Icons.location_city_outlined);
      expect(choice(h).kind, QiblaSourceKind.city);
      expect(text(tester, 'qibla-map-lat'), startsWith('35.6'));

      await chooseSource(tester, Icons.my_location);
      expect(choice(h).kind, QiblaSourceKind.device);
      expect(gps.calls, 1);
      await tapKey(tester, 'qibla-locate');
      expect(gps.calls, 2, reason: '"Find again" asks the device again');
    });

    testWidgets('an answer that arrives after another choice is dropped', (
      tester,
    ) async {
      final gate = Completer<void>();
      gps.gate = gate.future;
      final h = await open(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('qibla-source')),
          matching: find.byIcon(Icons.my_location),
        ),
      );
      await tester.pump();
      // While it is being asked the device counts as chosen, so a tap on the
      // city is a real change that cancels the request.
      await chooseSource(tester, Icons.location_city_outlined);
      expect(choice(h).locating, isFalse);
      gate.complete();
      await tester.pumpAndSettle();
      expect(choice(h).kind, QiblaSourceKind.city);
      expect(choice(h).deviceFix, isNull);
    });

    testWidgets('the position is never written to the settings', (
      tester,
    ) async {
      final h = await open(tester);
      final before = h.current;
      await chooseSource(tester, Icons.my_location);
      expect(h.current, before);
    });
  });

  group('any point', () {
    testWidgets('typed coordinates are applied', (tester) async {
      final h = await open(tester);
      await chooseSource(tester, Icons.edit_location_alt_outlined);
      await tester.enterText(
        find.byKey(const Key('qibla-coords-field')),
        '40.7128, -74.0060',
      );
      await tapKey(tester, 'qibla-coords-apply');
      expect(choice(h).kind, QiblaSourceKind.custom);
      expect(text(tester, 'qibla-map-lat'), startsWith('40.7128'));
      expect(text(tester, 'qibla-map-lon'), startsWith('−74.006'));
      // New York to the Kaaba: about 9,500 km to the north-east.
      expect(text(tester, 'qibla-map-bearing'), contains('north-east'));
    });

    testWidgets('invalid coordinates show an error and change nothing', (
      tester,
    ) async {
      final h = await open(tester);
      await chooseSource(tester, Icons.edit_location_alt_outlined);
      final before = text(tester, 'qibla-map-lat');
      await tester.enterText(
        find.byKey(const Key('qibla-coords-field')),
        '95, 10',
      );
      await tapKey(tester, 'qibla-coords-apply');
      expect(find.textContaining('Not valid coordinates'), findsOneWidget);
      expect(text(tester, 'qibla-map-lat'), before);
      expect(choice(h).customPoint, isNotNull); // the starting point stays

      await tester.enterText(
        find.byKey(const Key('qibla-coords-field')),
        '10, 20',
      );
      await tapKey(tester, 'qibla-coords-apply');
      expect(find.textContaining('Not valid coordinates'), findsNothing);
    });

    testWidgets('the first switch starts from the point that was shown', (
      tester,
    ) async {
      final h = await open(tester);
      await chooseSource(tester, Icons.edit_location_alt_outlined);
      expect(choice(h).kind, QiblaSourceKind.custom);
      expect(choice(h).customPoint!.latitude, closeTo(35.6892, 0.01));
    });

    testWidgets('tapping the map picks that point', (tester) async {
      final h = await open(tester);
      final map = find.byKey(const Key('qibla-map'));
      final bottom = tester.getBottomLeft(map) + const Offset(120, -120);
      await tester.tapAt(bottom);
      // flutter_map waits a moment to tell a tap from a double tap.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(choice(h).kind, QiblaSourceKind.custom);
      expect(choice(h).customPoint, isNotNull);
    });
  });

  group('the camera', () {
    double zoom(WidgetTester tester) => tester
        .widget<FlutterMap>(find.byKey(const Key('qibla-map')))
        .mapController!
        .camera
        .zoom;

    testWidgets('"Around me" zooms to street level, "Kaaba" to the Kaaba, '
        '"Whole route" back out', (tester) async {
      await open(tester);
      final overview = zoom(tester);
      expect(overview, lessThan(10));

      await tapKey(tester, 'qibla-cam-nearby');
      expect(zoom(tester), 17);
      await tapKey(tester, 'qibla-cam-kaaba');
      expect(zoom(tester), 19);
      await tapKey(tester, 'qibla-cam-overview');
      expect(zoom(tester), closeTo(overview, 0.5));
    });

    testWidgets('a new position moves the camera to the chosen view', (
      tester,
    ) async {
      await open(tester);
      await tapKey(tester, 'qibla-cam-nearby');
      await chooseSource(tester, Icons.my_location);
      final map = tester.widget<FlutterMap>(find.byKey(const Key('qibla-map')));
      expect(map.mapController!.camera.zoom, 17);
      expect(map.mapController!.camera.center.latitude, closeTo(36.2133, 1e-4));
    });
  });

  group('any point: search a place by name', () {
    late FakePlaceSearch search;

    setUp(() => search = FakePlaceSearch());

    Future<AppHarness> openSearch(WidgetTester tester) async {
      final h = await open(
        tester,
        overrides: [placeSearchProvider.overrideWithValue(search)],
      );
      await chooseSource(tester, Icons.edit_location_alt_outlined);
      return h;
    }

    Future<void> find0(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.byKey(const Key('qibla-place-field')));
      await tester.enterText(find.byKey(const Key('qibla-place-field')), text);
      await tapKey(tester, 'qibla-place-button');
    }

    QiblaPointState pointOf(AppHarness h) =>
        h.container.read(qiblaPointProvider);

    testWidgets('the search box appears only for the any-point source and '
        'says it needs the internet', (tester) async {
      await open(
        tester,
        overrides: [placeSearchProvider.overrideWithValue(search)],
      );
      expect(find.byKey(const Key('qibla-place-field')), findsNothing);
      await chooseSource(tester, Icons.edit_location_alt_outlined);
      expect(find.byKey(const Key('qibla-place-notice')), findsOneWidget);
      expect(find.byKey(const Key('qibla-place-field')), findsOneWidget);
      expect(search.queries, isEmpty);
    });

    testWidgets('choosing a result centres the map on that place at city '
        'scale and measures from it', (tester) async {
      final h = await openSearch(tester);
      await find0(tester, 'Mumbai, India');
      expect(search.settlementFlags, [false], reason: 'any kind of place');
      expect(search.detailsCalls, 0, reason: 'no time zone is needed here');
      await tapKey(tester, 'qibla-place-result-0');
      final choice = pointOf(h);
      expect(choice.kind, QiblaSourceKind.custom);
      expect(choice.customName, 'Mumbai');
      expect(text(tester, 'qibla-map-lat'), startsWith('19.07'));
      final map = tester.widget<FlutterMap>(find.byKey(const Key('qibla-map')));
      expect(map.mapController!.camera.zoom, 12);
      expect(map.mapController!.camera.center.latitude, closeTo(19.0759, 1e-3));
      expect(
        map.mapController!.camera.center.longitude,
        closeTo(72.8777, 1e-3),
      );
      expect(text(tester, 'qibla-source-help'), 'Measuring from Mumbai.');
    });

    testWidgets('the semantic description names the found place', (
      tester,
    ) async {
      await openSearch(tester);
      await find0(tester, 'Mumbai');
      await tapKey(tester, 'qibla-place-result-0');
      expect(
        find.bySemanticsLabel(RegExp('Qibla map: from Mumbai to the Kaaba')),
        findsOneWidget,
      );
    });

    testWidgets('a tap on the map afterwards forgets the name', (tester) async {
      final h = await openSearch(tester);
      await find0(tester, 'Mumbai');
      await tapKey(tester, 'qibla-place-result-0');
      await tester.tapAt(tester.getCenter(find.byKey(const Key('qibla-map'))));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(pointOf(h).customName, isNull);
      expect(pointOf(h).kind, QiblaSourceKind.custom);
    });

    testWidgets('typed coordinates still work and clear the name', (
      tester,
    ) async {
      final h = await openSearch(tester);
      await find0(tester, 'Mumbai');
      await tapKey(tester, 'qibla-place-result-0');
      await tester.ensureVisible(find.byKey(const Key('qibla-coords-field')));
      await tester.enterText(
        find.byKey(const Key('qibla-coords-field')),
        '36.2133, 58.7958',
      );
      await tapKey(tester, 'qibla-coords-apply');
      expect(pointOf(h).customName, isNull);
      expect(text(tester, 'qibla-map-lat'), startsWith('36.2'));
    });

    testWidgets('going back to the city and to any point again keeps the '
        'found place', (tester) async {
      final h = await openSearch(tester);
      await find0(tester, 'Mumbai');
      await tapKey(tester, 'qibla-place-result-0');
      await chooseSource(tester, Icons.location_city_outlined);
      await chooseSource(tester, Icons.edit_location_alt_outlined);
      expect(pointOf(h).customName, 'Mumbai');
    });

    testWidgets('offline: the page explains and the map stays usable', (
      tester,
    ) async {
      search.failure = const PlaceSearchException(PlaceSearchFailure.offline);
      final h = await openSearch(tester);
      await find0(tester, 'Mumbai');
      expect(find.byKey(const Key('qibla-place-message')), findsOneWidget);
      expect(pointOf(h).customName, isNull);
      expect(find.byKey(const Key('qibla-map')), findsOneWidget);
    });

    testWidgets('the search box fits a narrow window and large text', (
      tester,
    ) async {
      search.failure = const PlaceSearchException(PlaceSearchFailure.timeout);
      await open(
        tester,
        size: const Size(400, 900),
        textScale: 2,
        overrides: [placeSearchProvider.overrideWithValue(search)],
      );
      await chooseSource(tester, Icons.edit_location_alt_outlined);
      await find0(tester, 'Mumbai');
      expect(tester.takeException(), isNull);
    });
  });

  group('map style: street or satellite', () {
    TileLayer tileLayer(WidgetTester tester) =>
        tester.widget<TileLayer>(find.byType(TileLayer));

    bool selected(WidgetTester tester, String key) =>
        tester.widget<ChoiceChip>(find.byKey(Key(key))).selected;

    testWidgets('starts on the street map', (tester) async {
      final h = await open(tester);
      expect(tileLayer(tester).urlTemplate, qiblaTileUrlTemplate);
      expect(selected(tester, 'qibla-style-street'), isTrue);
      expect(selected(tester, 'qibla-style-satellite'), isFalse);
      expect(
        h.container.read(settingsProvider).qibla.mapStyle,
        QiblaMapStyle.street,
      );
    });

    testWidgets('the satellite chip switches to aerial photographs, remembers '
        'the choice and the street chip returns', (tester) async {
      final h = await open(tester);
      await tapKey(tester, 'qibla-style-satellite');
      final layer = tileLayer(tester);
      expect(layer.urlTemplate, qiblaSatelliteTileUrlTemplate);
      expect(layer.maxNativeZoom, qiblaSatelliteNativeZoom);
      expect(selected(tester, 'qibla-style-satellite'), isTrue);
      expect(
        h.container.read(settingsProvider).qibla.mapStyle,
        QiblaMapStyle.satellite,
      );

      await tapKey(tester, 'qibla-style-street');
      expect(tileLayer(tester).urlTemplate, qiblaTileUrlTemplate);
      expect(
        h.container.read(settingsProvider).qibla.mapStyle,
        QiblaMapStyle.street,
      );
    });

    testWidgets('a saved satellite choice opens on satellite', (tester) async {
      await open(
        tester,
        settings: englishSettings.copyWith(
          qibla: const QiblaSettings(
            mapEnabled: true,
            mapStyle: QiblaMapStyle.satellite,
          ),
        ),
      );
      expect(tileLayer(tester).urlTemplate, qiblaSatelliteTileUrlTemplate);
      expect(selected(tester, 'qibla-style-satellite'), isTrue);
    });

    testWidgets('the line turns yellow with a dark outline on photographs', (
      tester,
    ) async {
      await open(tester);
      Polyline line() => tester
          .widget<PolylineLayer>(find.byType(PolylineLayer))
          .polylines
          .single;
      final streetColor = line().color;
      await tapKey(tester, 'qibla-style-satellite');
      expect(line().color, const Color(0xFFFFD60A));
      expect(line().color, isNot(streetColor));
      expect(line().borderColor, const Color(0xCC000000));
      await tapKey(tester, 'qibla-style-street');
      expect(line().color, streetColor);
      expect(line().borderColor, Colors.white);
    });

    testWidgets('the credit names the imagery provider on satellite', (
      tester,
    ) async {
      await open(tester);
      String credit() {
        final widget = tester.widget<RichAttributionWidget>(
          find.byType(RichAttributionWidget),
        );
        return (widget.attributions.single as TextSourceAttribution).text;
      }

      expect(credit(), contains('OpenStreetMap'));
      await tapKey(tester, 'qibla-style-satellite');
      expect(credit(), contains('Esri'));
    });

    testWidgets('the same line, pin and Kaaba stay on both styles', (
      tester,
    ) async {
      await open(tester);
      await tapKey(tester, 'qibla-style-satellite');
      expect(find.byKey(const Key('qibla-map-you')), findsOneWidget);
      expect(find.byKey(const Key('qibla-map-kaaba')), findsOneWidget);
      expect(find.byKey(const Key('qibla-map-arrow')), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);
    });

    testWidgets('the Persian labels', (tester) async {
      await open(tester, settings: withMap(persianSettings));
      expect(find.text('ماهواره'), findsOneWidget);
      expect(find.text('نقشه'), findsWidgets);
    });

    testWidgets('the consent text names both servers', (tester) async {
      await open(tester, settings: withMap(englishSettings, enabled: false));
      expect(find.textContaining('OpenStreetMap'), findsOneWidget);
      expect(find.textContaining('Esri'), findsOneWidget);
    });
  });

  group('the map without the internet', () {
    testWidgets('failing tiles show the banner, and the numbers stay', (
      tester,
    ) async {
      await open(tester, tiles: _FailingTileProvider());
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('qibla-map-offline')), findsOneWidget);
      expect(find.byKey(const Key('qibla-map-bearing')), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);
    });

    testWidgets('blank tiles never show the banner', (tester) async {
      await open(tester);
      expect(find.byKey(const Key('qibla-map-offline')), findsNothing);
    });
  });

  group('accessibility and texts', () {
    testWidgets('the map has a spoken description', (tester) async {
      await open(tester);
      expect(
        find.bySemanticsLabel(RegExp('Qibla map: from Tehran to the Kaaba')),
        findsOneWidget,
      );
    });

    testWidgets('Persian texts and digits', (tester) async {
      await open(tester, settings: withMap(persianSettings));
      expect(find.text('نقشه'), findsWidgets);
      expect(text(tester, 'qibla-map-bearing'), contains('۲۱۸'));
      expect(find.text('قبله را از کجا حساب کنم؟'), findsOneWidget);
    });
  });

  group('layout', () {
    for (final locale in ['fa', 'en']) {
      for (final dark in [false, true]) {
        for (final size in [const Size(1200, 800), const Size(800, 560)]) {
          for (final scale in [1.0, 2.0]) {
            for (final mapOn in [true, false]) {
              testWidgets('$locale ${dark ? 'dark' : 'light'} '
                  '${size.width.toInt()}x${size.height.toInt()} x$scale '
                  '${mapOn ? 'map' : 'consent'} has no overflow', (
                tester,
              ) async {
                gps.failure = const DeviceLocationException(
                  DeviceLocationFailure.timeout,
                );
                await open(
                  tester,
                  settings: withMap(
                    locale == 'fa' ? persianSettings : englishSettings,
                    enabled: mapOn,
                  ),
                  size: size,
                  textScale: scale,
                  brightness: dark ? Brightness.dark : Brightness.light,
                );
                // Show the longest content: a failure message and the
                // coordinate field.
                await chooseSource(tester, Icons.my_location);
                await chooseSource(tester, Icons.edit_location_alt_outlined);
                expect(tester.takeException(), isNull);
                expect(
                  find.byKey(const Key('qibla-map-panel')),
                  findsOneWidget,
                );
                expect(
                  find.byKey(Key(mapOn ? 'qibla-map' : 'qibla-map-consent')),
                  findsOneWidget,
                );
              });
            }
          }
        }
      }
    }
  });
}

class _OpenThrows extends FakeDeviceLocation {
  @override
  Future<bool> openSystemSettings() => Future.error(StateError('no shell'));
}

class _ThrowingLocation implements DeviceLocationService {
  @override
  Future<DeviceFix> currentPosition({
    Duration timeLimit = const Duration(seconds: 20),
  }) => Future.error(StateError('boom'));

  @override
  Future<bool> openSystemSettings() => Future.error(StateError('boom'));
}
