import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_place_search.dart';
import 'package:owghat_lib/src/core/platform/place_search.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/city.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

import '../../support/app_harness.dart';
import '../../support/settings_rig.dart';
import '../../support/test_data.dart';

/// Section 1: saved locations, adding from the database and by hand, the
/// time-zone row with the live offset line.
void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  Future<SettingsRig> open(
    WidgetTester tester, {
    AppSettings? settings,
    Size size = const Size(1200, 800),
    List<Override> overrides = const [],
  }) => SettingsRig.open(
    tester,
    repository: repo,
    section: SettingsSection.location,
    settings: settings,
    size: size,
    overrides: overrides,
  );

  SavedLocation? saved(SettingsRig rig, String id) {
    for (final l in rig.settings.locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  City city(String englishName) => repo.search(englishName).first;

  group('add by searching online', () {
    late FakePlaceSearch search;

    setUp(() => search = FakePlaceSearch());

    Future<SettingsRig> openSearch(WidgetTester tester) async {
      final rig = await open(
        tester,
        overrides: [placeSearchProvider.overrideWithValue(search)],
      );
      await tapKey(tester, 'set-loc-add-mode-1');
      return rig;
    }

    Future<void> find0(WidgetTester tester, String text) async {
      await typeKey(tester, 'set-place-field', text, submit: false);
      await tapKey(tester, 'set-place-button');
    }

    testWidgets('the third way shows the notice and searches only on request', (
      tester,
    ) async {
      await openSearch(tester);
      expect(k('set-place-notice'), findsOneWidget);
      expect(search.queries, isEmpty);
      await find0(tester, 'Mumbai, India');
      expect(search.queries, ['Mumbai, India']);
      expect(search.settlementFlags, [true], reason: 'cities only');
      expect(k('set-place-result-0'), findsOneWidget);
    });

    testWidgets('choosing a result adds a custom location with its zone and '
        'height, and keeps the active one', (tester) async {
      final rig = await openSearch(tester);
      await find0(tester, 'Mumbai');
      await tapKey(tester, 'set-place-result-0');
      final added = rig.settings.locations.last;
      expect(added.kind, LocationKind.custom);
      expect(added.name, 'Mumbai');
      expect(added.zoneId, 'Asia/Kolkata');
      expect(added.elevationMeters, 9);
      expect(added.latitude, closeTo(19.0759, 1e-4));
      expect(rig.settings.activeLocationId, isNot(added.id));
      expect(textOf(tester, 'set-place-added'), 'Mumbai was added.');
    });

    testWidgets('choosing the same place again does not add it twice', (
      tester,
    ) async {
      final rig = await openSearch(tester);
      await find0(tester, 'Mumbai');
      await tapKey(tester, 'set-place-result-0');
      final count = rig.settings.locations.length;
      await tapKey(tester, 'set-place-result-0');
      expect(rig.settings.locations.length, count);
      // It says so instead of claiming it was added again.
      expect(k('set-place-added'), findsNothing);
      expect(
        textOf(tester, 'set-place-already'),
        'Mumbai is already in your saved locations.',
      );
    });

    testWidgets('the notice also names Open-Meteo, which gets the coordinates '
        'of the chosen place', (tester) async {
      await openSearch(tester);
      expect(textOf(tester, 'set-place-notice-text'), contains('Open-Meteo'));
    });

    testWidgets('a zone the app does not know is refused with an explanation', (
      tester,
    ) async {
      search.detailsResult = const PlaceDetails(zoneId: 'Mars/Olympus');
      final rig = await openSearch(tester);
      final before = rig.settings.locations.length;
      await find0(tester, 'Mumbai');
      await tapKey(tester, 'set-place-result-0');
      expect(rig.settings.locations.length, before);
      expect(k('set-place-unusable'), findsOneWidget);
    });

    testWidgets('offline: a message, and nothing changes', (tester) async {
      search.failure = const PlaceSearchException(PlaceSearchFailure.offline);
      final rig = await openSearch(tester);
      final before = rig.settings.locations.length;
      await find0(tester, 'Mumbai');
      expect(k('set-place-message'), findsOneWidget);
      expect(rig.settings.locations.length, before);
    });

    testWidgets('switching the way clears the notes', (tester) async {
      await openSearch(tester);
      await find0(tester, 'Mumbai');
      await tapKey(tester, 'set-place-result-0');
      expect(k('set-place-added'), findsOneWidget);
      await tapKey(tester, 'set-loc-add-mode-0');
      await tapKey(tester, 'set-loc-add-mode-1');
      expect(k('set-place-added'), findsNothing);
    });
  });

  group('saved locations', () {
    testWidgets('lists them with the active one marked', (tester) async {
      await open(tester);
      expect(textOf(tester, 'set-loc-name-city:1'), 'Tehran');
      expect(k('set-loc-active-city:1'), findsOneWidget);
      expect(k('set-loc-activate-city:1'), findsNothing);
    });

    testWidgets('set active, then delete the other one', (tester) async {
      final mashhad = city('Mashhad');
      final rig = await open(
        tester,
        settings: englishSettings.copyWith(
          locations: [
            AppSettings.defaultLocation,
            SavedLocation.builtin(id: 'city:${mashhad.id}', cityId: mashhad.id),
          ],
        ),
      );
      await tapKey(tester, 'set-loc-activate-city:${mashhad.id}');
      expect(rig.settings.activeLocationId, 'city:${mashhad.id}');
      expect(k('set-loc-active-city:${mashhad.id}'), findsOneWidget);

      // Delete asks first.
      await tapKey(tester, 'set-loc-delete-city:1');
      expect(find.text('Delete Tehran?'), findsOneWidget);
      await tapKey(tester, 'set-dialog-cancel');
      expect(rig.settings.locations, hasLength(2));

      await tapKey(tester, 'set-loc-delete-city:1');
      await tapKey(tester, 'set-loc-delete-confirm');
      expect(rig.settings.locations.map((l) => l.id), ['city:${mashhad.id}']);
      expect(rig.settings.activeLocationId, 'city:${mashhad.id}');
    });

    testWidgets('deleting the active location activates the first other', (
      tester,
    ) async {
      final mashhad = city('Mashhad');
      final rig = await open(
        tester,
        settings: englishSettings.copyWith(
          locations: [
            AppSettings.defaultLocation,
            SavedLocation.builtin(id: 'city:${mashhad.id}', cityId: mashhad.id),
          ],
          activeLocationId: 'city:${mashhad.id}',
        ),
      );
      await tapKey(tester, 'set-loc-delete-city:${mashhad.id}');
      await tapKey(tester, 'set-loc-delete-confirm');
      expect(rig.settings.activeLocationId, 'city:1');
    });

    testWidgets('the last location cannot be deleted', (tester) async {
      final rig = await open(tester);
      expect(
        tester.widget<IconButton>(k('set-loc-delete-city:1')).onPressed,
        isNull,
      );
      expect(find.text('The last location cannot be deleted.'), findsOneWidget);
      await tester.tap(k('set-loc-delete-city:1'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(rig.settings.locations, hasLength(1));
    });
  });

  group('add from the database', () {
    testWidgets('search by English or Persian name, then add', (tester) async {
      final rig = await open(tester);
      final mashhad = city('Mashhad');
      await typeKey(tester, 'set-loc-search', 'Mashhad', submit: false);
      expect(k('set-loc-result-${mashhad.id}'), findsOneWidget);
      await tapKey(tester, 'set-loc-add-${mashhad.id}');
      final added = saved(rig, 'city:${mashhad.id}')!;
      expect(added.kind, LocationKind.builtin);
      expect(added.cityId, mashhad.id);
      expect(added.offset.mode, OffsetMode.automatic);
      // Adding does not move the active location.
      expect(rig.settings.activeLocationId, 'city:1');
      expect(find.text('Mashhad was added.'), findsOneWidget);
      // The row now says it is saved.
      expect(k('set-loc-add-${mashhad.id}'), findsNothing);
      expect(find.text('Already saved'), findsOneWidget);

      await tapKey(tester, 'set-loc-activate-city:${mashhad.id}');
      expect(rig.settings.activeLocationId, 'city:${mashhad.id}');

      // Persian, with a different yeh and kaf, finds the same kind of city.
      await typeKey(tester, 'set-loc-search', 'شيراز', submit: false);
      final shiraz = repo.search('شيراز').first;
      expect(k('set-loc-result-${shiraz.id}'), findsOneWidget);
    });

    testWidgets('an empty search lists the province centres', (tester) async {
      await open(tester);
      final first = repo.provinceCentres.first;
      expect(k('set-loc-result-${first.id}'), findsOneWidget);
    });

    testWidgets('browse by province', (tester) async {
      await open(tester);
      final first = repo.provinces[0];
      final second = repo.provinces[1];
      // Unfiltered, the first row is the centre of the first province.
      expect(k('set-loc-result-${first.centerCityId}'), findsOneWidget);

      // The menu is long, so its entries are chosen by their text.
      await tapKey(tester, 'set-loc-province');
      await tester.tap(find.text(second.nameEn).last);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: k('set-loc-province'),
          matching: find.text(second.nameEn),
        ),
        findsOneWidget,
      );
      final cities = repo.citiesOf(second.id);
      expect(k('set-loc-result-${cities.first.id}'), findsOneWidget);
      expect(k('set-loc-result-${first.centerCityId}'), findsNothing);
      await tapKey(tester, 'set-loc-add-${cities.first.id}');

      // Search and province combine: a city of another province is hidden.
      final elsewhere = repo.citiesOf(first.id).first;
      await typeKey(tester, 'set-loc-search', elsewhere.nameEn, submit: false);
      expect(k('set-loc-result-${elsewhere.id}'), findsNothing);
      // The search still works inside the province.
      await typeKey(
        tester,
        'set-loc-search',
        cities.last.nameEn,
        submit: false,
      );
      expect(k('set-loc-result-${cities.last.id}'), findsWidgets);
    });

    testWidgets('no match shows a message', (tester) async {
      await open(tester);
      await typeKey(tester, 'set-loc-search', 'zzzzqqqq', submit: false);
      expect(find.text('No city found.'), findsOneWidget);
    });
  });

  group('add a custom location', () {
    Future<void> fill(
      WidgetTester tester, {
      String name = 'Test place',
      String lat = '36.3',
      String lon = '59.6',
      String elevation = '985',
      String prefix = 'set-loc',
    }) async {
      await typeKey(tester, '$prefix-name', name, submit: false);
      await typeKey(tester, '$prefix-lat', lat, submit: false);
      await typeKey(tester, '$prefix-lon', lon, submit: false);
      await typeKey(tester, '$prefix-elevation', elevation, submit: false);
    }

    testWidgets('a valid location with a chosen zone is saved', (tester) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-loc-add-mode-2');
      await fill(tester);
      // Search the zone list and choose one.
      await typeKey(tester, 'set-loc-zone-search', 'berlin', submit: false);
      expect(k('set-loc-zone-Europe/Berlin'), findsOneWidget);
      expect(k('set-loc-zone-Asia/Tehran'), findsNothing);
      await tapKey(tester, 'set-loc-zone-Europe/Berlin');
      expect(
        textOf(tester, 'set-loc-zone-selected'),
        contains('Europe/Berlin'),
      );
      await tapKey(tester, 'set-loc-submit');

      final added = saved(rig, 'custom:1')!;
      expect(added.kind, LocationKind.custom);
      expect(added.name, 'Test place');
      expect(added.latitude, 36.3);
      expect(added.longitude, 59.6);
      expect(added.elevationMeters, 985);
      expect(added.zoneId, 'Europe/Berlin');
      expect(added.offset.mode, OffsetMode.automatic);
      expect(textOf(tester, 'set-loc-name-custom:1'), 'Test place');
      expect(k('set-loc-custom-added'), findsOneWidget);
      // The form is empty again for the next one.
      expect(
        tester.widget<TextField>(fieldOf('set-loc-name')).controller!.text,
        isEmpty,
      );
    });

    testWidgets('every kind of mistake shows its own message', (tester) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-loc-add-mode-2');
      final before = rig.settings;

      await tapKey(tester, 'set-loc-submit');
      expect(find.text('Enter a name.'), findsOneWidget);

      await typeKey(tester, 'set-loc-name', 'Somewhere', submit: false);
      await tapKey(tester, 'set-loc-submit');
      expect(
        find.text('Latitude must be a number between −89.9 and 89.9.'),
        findsOneWidget,
      );
      await typeKey(tester, 'set-loc-lat', '95', submit: false);
      await tapKey(tester, 'set-loc-submit');
      expect(
        find.text('Latitude must be a number between −89.9 and 89.9.'),
        findsOneWidget,
      );

      await typeKey(tester, 'set-loc-lat', '35', submit: false);
      await typeKey(tester, 'set-loc-lon', '190', submit: false);
      await tapKey(tester, 'set-loc-submit');
      expect(
        find.text('Longitude must be a number between −180 and 180.'),
        findsOneWidget,
      );

      await typeKey(tester, 'set-loc-lon', '51', submit: false);
      await typeKey(tester, 'set-loc-elevation', '-5', submit: false);
      await tapKey(tester, 'set-loc-submit');
      expect(
        find.text('Elevation must be between 0 and 9000 metres.'),
        findsOneWidget,
      );
      // Nothing was saved by any of those.
      expect(rig.settings, before);

      await typeKey(tester, 'set-loc-elevation', '', submit: false);
      await tapKey(tester, 'set-loc-submit');
      expect(saved(rig, 'custom:1')!.elevationMeters, 0);
    });

    testWidgets('degrees, minutes and seconds are accepted', (tester) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-loc-add-mode-2');
      await typeKey(tester, 'set-loc-name', 'DMS place', submit: false);
      await typeKey(tester, 'set-loc-lat', '35.6892', submit: false);
      await typeKey(tester, 'set-loc-lon', '51.389', submit: false);
      // Switching the format converts what is typed.
      await tapKey(tester, 'set-loc-format-1');
      expect(
        tester.widget<TextField>(fieldOf('set-loc-lat-deg')).controller!.text,
        '35',
      );
      expect(
        tester.widget<TextField>(fieldOf('set-loc-lat-min')).controller!.text,
        '41',
      );
      // South and west hemispheres.
      await typeKey(tester, 'set-loc-lat-deg', '33', submit: false);
      await typeKey(tester, 'set-loc-lat-min', '52', submit: false);
      await typeKey(tester, 'set-loc-lat-sec', '4.5', submit: false);
      await tapKey(tester, 'set-loc-lat-hemisphere-1');
      await typeKey(tester, 'set-loc-lon-deg', '151', submit: false);
      await typeKey(tester, 'set-loc-lon-min', '12', submit: false);
      await typeKey(tester, 'set-loc-lon-sec', '33', submit: false);
      await tapKey(tester, 'set-loc-lon-hemisphere-0');
      await tapKey(tester, 'set-loc-submit');
      final added = saved(rig, 'custom:1')!;
      expect(added.latitude, closeTo(-(33 + 52 / 60 + 4.5 / 3600), 1e-9));
      expect(added.longitude, closeTo(151 + 12 / 60 + 33 / 3600, 1e-9));
    });

    testWidgets('minutes out of range are a latitude error', (tester) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-loc-add-mode-2');
      await tapKey(tester, 'set-loc-format-1');
      await typeKey(tester, 'set-loc-name', 'Bad DMS', submit: false);
      await typeKey(tester, 'set-loc-lat-deg', '35', submit: false);
      await typeKey(tester, 'set-loc-lat-min', '75', submit: false);
      await typeKey(tester, 'set-loc-lon-deg', '51', submit: false);
      await tapKey(tester, 'set-loc-submit');
      expect(find.textContaining('Latitude must be'), findsOneWidget);
      expect(saved(rig, 'custom:1'), isNull);
    });

    testWidgets('a custom location can use a fixed offset', (tester) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-loc-add-mode-2');
      await fill(tester);
      await tapKey(tester, 'set-loc-offset-mode-1');
      // Starts at the zone offset now (Tehran +03:30).
      expect(textOf(tester, 'set-loc-offset-fixed-value'), contains('+03:30'));
      await tapKey(tester, 'set-loc-offset-fixed-quarter-inc');
      expect(textOf(tester, 'set-loc-offset-fixed-value'), contains('+03:45'));
      await tapKey(tester, 'set-loc-submit');
      expect(saved(rig, 'custom:1')!.offset, const LocationOffset.fixed(225));
    });

    testWidgets('edit a custom location', (tester) async {
      final rig = await open(
        tester,
        settings: englishSettings.copyWith(
          locations: [
            AppSettings.defaultLocation,
            const SavedLocation.custom(
              id: 'custom:1',
              name: 'Old name',
              latitude: 10,
              longitude: 20,
              zoneId: 'Asia/Tehran',
              offset: LocationOffset.fixed(120),
            ),
          ],
        ),
      );
      await tapKey(tester, 'set-loc-edit-custom:1');
      const p = 'set-loc-custom:1-form';
      expect(
        tester.widget<TextField>(fieldOf('$p-name')).controller!.text,
        'Old name',
      );
      await typeKey(tester, '$p-name', 'New name', submit: false);
      await typeKey(tester, '$p-lat', '11.5', submit: false);
      await tapKey(tester, '$p-submit');
      final edited = saved(rig, 'custom:1')!;
      expect(edited.name, 'New name');
      expect(edited.latitude, 11.5);
      expect(edited.longitude, 20);
      // The offset rule is edited in the time-zone row, and kept here.
      expect(edited.offset, const LocationOffset.fixed(120));
      expect(textOf(tester, 'set-loc-name-custom:1'), 'New name');

      // An invalid edit is refused.
      await typeKey(tester, '$p-name', ' ', submit: false);
      await tapKey(tester, '$p-submit');
      expect(find.text('Enter a name.'), findsOneWidget);
      expect(saved(rig, 'custom:1')!.name, 'New name');
    });
  });

  group('time zone row', () {
    testWidgets('automatic: shows the offset in effect today', (tester) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-loc-edit-city:1');
      expect(
        textOf(tester, 'set-zone-now-city:1'),
        'Offset in effect today: UTC+03:30',
      );
      // Iran has no further change planned.
      expect(
        textOf(tester, 'set-zone-next-city:1'),
        'No further change is planned for this time zone.',
      );
      expect(saved(rig, 'city:1')!.offset.mode, OffsetMode.automatic);
    });

    testWidgets('a zone with a planned change names it', (tester) async {
      await open(
        tester,
        settings: englishSettings.copyWith(
          locations: [
            AppSettings.defaultLocation,
            const SavedLocation.custom(
              id: 'custom:1',
              name: 'Berlin',
              latitude: 52.5,
              longitude: 13.4,
              zoneId: 'Europe/Berlin',
            ),
          ],
        ),
      );
      await tapKey(tester, 'set-loc-edit-custom:1');
      expect(
        textOf(tester, 'set-zone-now-custom:1'),
        'Offset in effect today: UTC+01:00',
      );
      // 2027-03-28 01:00 UTC, in Berlin 02:00 local, to UTC+02:00.
      expect(
        textOf(tester, 'set-zone-next-custom:1'),
        allOf(
          contains('Next change:'),
          contains('02:00'),
          contains('UTC+02:00'),
        ),
      );
    });

    testWidgets('choosing a fixed offset persists and shows the line', (
      tester,
    ) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-loc-edit-city:1');
      await tapKey(tester, 'set-loc-city:1-offset-mode-1');
      // Starts from the offset the zone has now.
      expect(saved(rig, 'city:1')!.offset, const LocationOffset.fixed(210));
      expect(
        textOf(tester, 'set-zone-now-city:1'),
        'Offset in effect today: UTC+03:30',
      );
      expect(
        textOf(tester, 'set-zone-next-city:1'),
        contains('stays the same on every day of the year'),
      );

      // Steps of an hour and of a quarter of an hour.
      await tapKey(tester, 'set-loc-city:1-offset-fixed-hour-inc');
      expect(saved(rig, 'city:1')!.offset, const LocationOffset.fixed(270));
      await tapKey(tester, 'set-loc-city:1-offset-fixed-quarter-dec');
      expect(saved(rig, 'city:1')!.offset, const LocationOffset.fixed(255));
      expect(
        textOf(tester, 'set-zone-now-city:1'),
        'Offset in effect today: UTC+04:15',
      );

      // It survives closing and reopening the panel.
      await tapKey(tester, 'set-loc-edit-city:1');
      await tapKey(tester, 'set-loc-edit-city:1');
      expect(
        textOf(tester, 'set-loc-city:1-offset-fixed-value'),
        contains('+04:15'),
      );

      // And the prayer times follow it (an hour later than Tehran's).
      expect(
        rig.container
            .read(settingsProvider)
            .locations
            .first
            .offset
            .fixedMinutes,
        255,
      );

      // Back to automatic.
      await tapKey(tester, 'set-loc-city:1-offset-mode-0');
      expect(saved(rig, 'city:1')!.offset.mode, OffsetMode.automatic);
      expect(
        textOf(tester, 'set-zone-now-city:1'),
        'Offset in effect today: UTC+03:30',
      );
    });

    testWidgets('the fixed offset stays within -12:00 and +14:00', (
      tester,
    ) async {
      final rig = await open(
        tester,
        settings: englishSettings.copyWith(
          locations: [
            const SavedLocation.builtin(
              id: 'city:1',
              cityId: 1,
              offset: LocationOffset.fixed(825),
            ),
          ],
        ),
      );
      await tapKey(tester, 'set-loc-edit-city:1');
      await tapKey(tester, 'set-loc-city:1-offset-fixed-quarter-inc');
      expect(saved(rig, 'city:1')!.offset, const LocationOffset.fixed(840));
      expect(
        tester
            .widget<IconButton>(k('set-loc-city:1-offset-fixed-quarter-inc'))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(k('set-loc-city:1-offset-fixed-hour-inc'))
            .onPressed,
        isNull,
      );
      for (var i = 0; i < 9; i++) {
        await tapKey(tester, 'set-loc-city:1-offset-fixed-hour-dec');
      }
      expect(saved(rig, 'city:1')!.offset, const LocationOffset.fixed(300));
      // Down to the lower bound with steps of 15 minutes and an hour.
      for (var i = 0; i < 14; i++) {
        await tapKey(tester, 'set-loc-city:1-offset-fixed-hour-dec');
      }
      expect(saved(rig, 'city:1')!.offset, const LocationOffset.fixed(-540));
      for (var i = 0; i < 3; i++) {
        await tapKey(tester, 'set-loc-city:1-offset-fixed-hour-dec');
      }
      expect(saved(rig, 'city:1')!.offset, const LocationOffset.fixed(-720));
      expect(
        tester
            .widget<IconButton>(k('set-loc-city:1-offset-fixed-hour-dec'))
            .onPressed,
        isNull,
      );
      expect(
        textOf(tester, 'set-loc-city:1-offset-fixed-value'),
        contains('−12:00'),
      );
    });

    testWidgets('the fixed offset changes the active prayer times', (
      tester,
    ) async {
      final rig = await open(tester);
      await tapKey(tester, 'set-loc-edit-city:1');
      await tapKey(tester, 'set-loc-city:1-offset-mode-1');
      await tapKey(tester, 'set-loc-city:1-offset-fixed-hour-inc');
      // The calculation preview shows the new local times (one hour later).
      await rig.show(tester, SettingsSection.calculation);
      expect(textOf(tester, 'set-preview-sunrise'), '07:36');
      expect(textOf(tester, 'set-preview-maghrib'), '18:20');
      expect(rig.settings.locations.first.offset.fixedMinutes, 270);
    });
  });
}
