import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_place_search.dart';
import 'package:owghat_lib/src/core/platform/http_get.dart';
import 'package:owghat_lib/src/core/platform/place_search.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/places/application/place_location.dart';
import 'package:owghat_lib/src/features/places/application/place_search_model.dart';
import 'package:owghat_lib/src/features/places/data/online_place_search.dart';
import 'package:owghat_lib/src/features/places/presentation/place_search_panel.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

const String _nominatimMumbai = '''
[
  {"place_id": 1, "lat": "19.0549990", "lon": "72.8692035", "name": "ممبئی",
   "display_name": "ممبئی, Mumbai Suburban District, مهاراشترا, 400051, هند",
   "type": "city", "address": {"country": "هند", "country_code": "in"}},
  {"place_id": 2, "lat": "19.0550100", "lon": "72.8692100", "name": "ممبئی",
   "display_name": "ممبئی, هند", "type": "city", "address": {"country": "هند"}},
  {"place_id": 3, "lat": "19.0368", "lon": "73.0158", "name": "",
   "display_name": "Navi Mumbai, Thane, Maharashtra, India", "address": {"country": "India"}},
  {"place_id": 4, "lat": "abc", "lon": "72", "name": "Bad"},
  {"place_id": 5, "lat": "95", "lon": "72", "name": "Too far north"},
  "not a map"
]
''';

const String _openMeteo =
    '{"latitude":19.08,"longitude":72.85,"timezone":"Asia/Kolkata",'
    '"elevation":9.0,"current":{"temperature_2m":33.3}}';

void main() {
  group('parsing', () {
    test('Nominatim: names, short region line, duplicates and bad rows', () {
      final places = parseNominatim(_nominatimMumbai);
      expect(
        places.length,
        2,
        reason: 'the near-identical second row is dropped',
      );
      expect(places[0].name, 'ممبئی');
      expect(places[0].country, 'هند');
      // The postcode (400051) is not shown; the rest is joined short.
      expect(places[0].region, 'Mumbai Suburban District · مهاراشترا · هند');
      expect(places[0].latitude, closeTo(19.055, 1e-4));
      expect(places[0].longitude, closeTo(72.8692, 1e-4));
      // No "name": the first part of the display name is used.
      expect(places[1].name, 'Navi Mumbai');
      expect(places[1].region, 'Thane · Maharashtra · India');
    });

    test('Nominatim: an empty list and wrong shapes', () {
      expect(parseNominatim('[]'), isEmpty);
      expect(
        () => parseNominatim('{"a":1}'),
        throwsA(
          isA<PlaceSearchException>().having(
            (e) => e.failure,
            'failure',
            PlaceSearchFailure.badResponse,
          ),
        ),
      );
      expect(
        () => parseNominatim('<html>'),
        throwsA(isA<PlaceSearchException>()),
      );
    });

    test('Nominatim: a long address keeps two parts and the country', () {
      final places = parseNominatim(
        jsonEncode([
          {
            'lat': '1',
            'lon': '2',
            'name': 'X',
            'display_name': 'X, A, B, C, D, Land',
            'address': {'country': 'Land'},
          },
        ]),
      );
      expect(places.single.region, 'A · B · Land');
    });

    test('Open-Meteo details: zone and height, height clamped', () {
      final d = parseOpenMeteoDetails(_openMeteo);
      expect(d.zoneId, 'Asia/Kolkata');
      expect(d.elevationMeters, 9);
      expect(
        parseOpenMeteoDetails('{"timezone":"UTC","elevation":-12}')
            .elevationMeters,
        0,
      );
      expect(
        parseOpenMeteoDetails('{"timezone":"UTC","elevation":99999}')
            .elevationMeters,
        9000,
      );
      expect(parseOpenMeteoDetails('{"timezone":"UTC"}').elevationMeters, 0);
      expect(
        () => parseOpenMeteoDetails('{"elevation":3}'),
        throwsA(isA<PlaceSearchException>()),
      );
      expect(
        () => parseOpenMeteoDetails('[]'),
        throwsA(isA<PlaceSearchException>()),
      );
      expect(
        () => parseOpenMeteoDetails('nope'),
        throwsA(isA<PlaceSearchException>()),
      );
    });
  });

  group('OnlinePlaceSearch requests', () {
    late List<Uri> uris;
    late List<Map<String, String>> sentHeaders;

    HttpGetText answer(int status, String body) =>
        (
          uri, {
          headers = const {},
          timeout = const Duration(seconds: 1),
        }) async {
          uris.add(uri);
          sentHeaders.add(headers);
          return HttpTextResponse(status, body);
        };

    setUp(() {
      uris = [];
      sentHeaders = [];
    });

    test(
      'the search goes to Nominatim with the language and an identifying agent',
      () async {
        final service = OnlinePlaceSearch(answer(200, _nominatimMumbai));
        final places = await service.search(
          '  بمبئی هند ',
          language: 'fa',
          settlementsOnly: true,
        );
        expect(places, isNotEmpty);
        final uri = uris.single;
        expect(uri.scheme, 'https');
        expect(uri.host, 'nominatim.openstreetmap.org');
        expect(uri.queryParameters['q'], 'بمبئی هند');
        expect(uri.queryParameters['accept-language'], 'fa');
        expect(uri.queryParameters['featureType'], 'settlement');
        expect(uri.queryParameters['format'], 'jsonv2');
        expect(sentHeaders.single['User-Agent'], placeSearchUserAgent);
        expect(placeSearchUserAgent, isNot(contains('@')));
      },
    );

    test(
      'a search of any kind of place does not restrict the feature type',
      () async {
        final service = OnlinePlaceSearch(answer(200, '[]'));
        await service.search('Haram', language: 'en');
        expect(uris.single.queryParameters.containsKey('featureType'), isFalse);
      },
    );

    test('the same query is not sent twice', () async {
      final service = OnlinePlaceSearch(answer(200, _nominatimMumbai));
      await service.search('Mumbai', language: 'en');
      await service.search('mumbai ', language: 'en');
      expect(uris.length, 1);
      await service.search('Mumbai', language: 'fa');
      expect(uris.length, 2, reason: 'another language is another answer');
    });

    test('details ask Open-Meteo for the zone of the point', () async {
      final service = OnlinePlaceSearch(answer(200, _openMeteo));
      final details = await service.details(19.07283, 72.88261);
      expect(details.zoneId, 'Asia/Kolkata');
      final uri = uris.single;
      expect(uri.host, 'api.open-meteo.com');
      expect(uri.queryParameters['timezone'], 'auto');
      expect(uri.queryParameters['latitude'], '19.0728');
      expect(uri.queryParameters['longitude'], '72.8826');
    });

    Future<PlaceSearchFailure> failureOf(HttpGetText get) async {
      try {
        await OnlinePlaceSearch(get).search('Mumbai', language: 'en');
      } on PlaceSearchException catch (error) {
        return error.failure;
      }
      fail('expected a PlaceSearchException');
    }

    test('errors are sorted into the kinds the page explains', () async {
      expect(await failureOf(answer(429, '')), PlaceSearchFailure.busy);
      expect(await failureOf(answer(503, '')), PlaceSearchFailure.busy);
      expect(await failureOf(answer(500, '')), PlaceSearchFailure.failed);
      expect(await failureOf(answer(200, 'x')), PlaceSearchFailure.badResponse);
      expect(
        await failureOf(
          (u, {headers = const {}, timeout = Duration.zero}) =>
              throw const SocketException('down'),
        ),
        PlaceSearchFailure.offline,
      );
      expect(
        await failureOf(
          (u, {headers = const {}, timeout = Duration.zero}) =>
              throw const HandshakeException('tls'),
        ),
        PlaceSearchFailure.offline,
      );
      expect(
        await failureOf(
          (u, {headers = const {}, timeout = Duration.zero}) =>
              throw TimeoutException('slow'),
        ),
        PlaceSearchFailure.timeout,
      );
      expect(
        await failureOf(
          (u, {headers = const {}, timeout = Duration.zero}) =>
              throw StateError('boom'),
        ),
        PlaceSearchFailure.failed,
      );
    });

    test('the unsupported service refuses both calls', () async {
      const service = UnsupportedPlaceSearch();
      await expectLater(
        service.search('x', language: 'en'),
        throwsA(isA<PlaceSearchException>()),
      );
      await expectLater(
        service.details(1, 2),
        throwsA(isA<PlaceSearchException>()),
      );
    });
  });

  group('PlaceSearchModel', () {
    late FakePlaceSearch service;
    late PlaceSearchModel model;

    PlaceSearchModel make({bool resolve = false, String lang = 'en'}) =>
        PlaceSearchModel(
          service: service,
          language: () => lang,
          settlementsOnly: true,
          resolveDetails: resolve,
        );

    setUp(() {
      service = FakePlaceSearch();
      model = make();
    });

    tearDown(() => model.dispose());

    test('starts idle', () {
      expect(model.status, PlaceSearchStatus.idle);
      expect(model.results, isEmpty);
      expect(model.busy, isFalse);
    });

    test('too short a text is not sent', () async {
      await model.search(' a ');
      expect(model.status, PlaceSearchStatus.tooShort);
      expect(service.queries, isEmpty);
    });

    test(
      'a search shows results and sends the language and the flag',
      () async {
        await model.search('Mumbai, India');
        expect(model.status, PlaceSearchStatus.results);
        expect(model.results.length, 2);
        expect(service.queries, ['Mumbai, India']);
        expect(service.languages, ['en']);
        expect(service.settlementFlags, [true]);
        expect(model.query, 'Mumbai, India');
      },
    );

    test('no result is reported as empty', () async {
      service.places = const [];
      await model.search('zzzz');
      expect(model.status, PlaceSearchStatus.empty);
    });

    test('every failure kind is kept', () async {
      for (final kind in [
        PlaceSearchFailure.offline,
        PlaceSearchFailure.timeout,
        PlaceSearchFailure.busy,
        PlaceSearchFailure.badResponse,
      ]) {
        service.failure = PlaceSearchException(kind);
        await model.search('Mumbai');
        expect(model.status, PlaceSearchStatus.failed);
        expect(model.failure, kind);
        expect(model.detailsFailed, isFalse);
      }
    });

    test('an unexpected error counts as a plain failure', () async {
      final broken = PlaceSearchModel(
        service: _Throwing(),
        language: () => 'en',
      );
      addTearDown(broken.dispose);
      await broken.search('Mumbai');
      expect(broken.failure, PlaceSearchFailure.failed);
    });

    test('a second press while waiting is ignored', () async {
      final gate = Completer<void>();
      service.gate = gate.future;
      final first = model.search('Mumbai');
      expect(model.busy, isTrue);
      await model.search('Delhi');
      expect(service.queries, ['Mumbai']);
      gate.complete();
      await first;
      expect(model.status, PlaceSearchStatus.results);
    });

    test('choosing without details returns the place at once', () async {
      await model.search('Mumbai');
      final picked = await model.pick(model.results.first);
      expect(picked!.place.name, 'Mumbai');
      expect(picked.details, isNull);
      expect(service.detailsCalls, 0);
    });

    test('choosing with details fetches the zone first', () async {
      model.dispose();
      model = make(resolve: true);
      await model.search('Mumbai');
      final picked = await model.pick(model.results.first);
      expect(picked!.details!.zoneId, 'Asia/Kolkata');
      expect(service.detailsCalls, 1);
      expect(model.status, PlaceSearchStatus.results);
    });

    test(
      'a failed lookup keeps the results so another place can be chosen',
      () async {
        model.dispose();
        model = make(resolve: true);
        await model.search('Mumbai');
        service.detailsFailure = const PlaceSearchException(
          PlaceSearchFailure.offline,
        );
        expect(await model.pick(model.results.first), isNull);
        expect(model.status, PlaceSearchStatus.failed);
        expect(model.detailsFailed, isTrue);
        expect(model.results.length, 2);
        service.detailsFailure = null;
        expect(await model.pick(model.results.last), isNotNull);
        expect(model.detailsFailed, isFalse);
      },
    );

    test('clear forgets everything and drops a late answer', () async {
      final gate = Completer<void>();
      service.gate = gate.future;
      final pending = model.search('Mumbai');
      model.clear();
      gate.complete();
      await pending;
      expect(model.status, PlaceSearchStatus.idle);
      expect(model.results, isEmpty);
    });

    test('an answer that arrives after dispose does nothing', () async {
      final gate = Completer<void>();
      service.gate = gate.future;
      final pending = model.search('Mumbai');
      model.dispose();
      gate.complete();
      await pending;
      model = make(); // for tearDown
    });
  });

  group('saved location of a place', () {
    final resolver = ZoneOffsetResolver();
    const mumbai = FoundPlace(
      name: 'Mumbai',
      latitude: 19.07,
      longitude: 72.87,
    );

    test('a place with details becomes a custom location', () {
      final saved = savedLocationFromPlace(
        const PickedPlace(
          mumbai,
          PlaceDetails(zoneId: 'Asia/Kolkata', elevationMeters: 9),
        ),
        existingIds: const ['city:1'],
        resolver: resolver,
      )!;
      expect(saved.kind, LocationKind.custom);
      expect(saved.name, 'Mumbai');
      expect(saved.zoneId, 'Asia/Kolkata');
      expect(saved.elevationMeters, 9);
      expect(saved.id, isNot('city:1'));
    });

    test(
      'a place without details, in an unknown zone, or at a pole is refused',
      () {
        expect(
          savedLocationFromPlace(
            const PickedPlace(mumbai),
            existingIds: const [],
            resolver: resolver,
          ),
          isNull,
        );
        expect(
          savedLocationFromPlace(
            const PickedPlace(mumbai, PlaceDetails(zoneId: 'Mars/Olympus')),
            existingIds: const [],
            resolver: resolver,
          ),
          isNull,
        );
        expect(
          savedLocationFromPlace(
            const PickedPlace(
              FoundPlace(name: 'Pole', latitude: 90, longitude: 0),
              PlaceDetails(zoneId: 'UTC'),
            ),
            existingIds: const [],
            resolver: resolver,
          ),
          isNull,
        );
      },
    );

    test('the same place is recognised again', () {
      final saved = savedLocationFromPlace(
        const PickedPlace(mumbai, PlaceDetails(zoneId: 'Asia/Kolkata')),
        existingIds: const [],
        resolver: resolver,
      )!;
      const again = FoundPlace(
        name: 'Mumbai',
        latitude: 19.071,
        longitude: 72.872,
      );
      expect(sameSavedPlace(const PickedPlace(again), [saved]), saved);
      const elsewhere = FoundPlace(
        name: 'Mumbai',
        latitude: 40,
        longitude: 72.87,
      );
      expect(sameSavedPlace(const PickedPlace(elsewhere), [saved]), isNull);
      const renamed = FoundPlace(
        name: 'Bombay',
        latitude: 19.07,
        longitude: 72.87,
      );
      expect(sameSavedPlace(const PickedPlace(renamed), [saved]), isNull);
      expect(
        sameSavedPlace(const PickedPlace(again), [
          const SavedLocation.builtin(id: 'city:1', cityId: 1),
        ]),
        isNull,
      );
    });
  });

  group('PlaceSearchPanel', () {
    late FakePlaceSearch service;
    late List<PickedPlace> picked;

    setUp(() {
      service = FakePlaceSearch();
      picked = [];
    });

    Future<void> pump(
      WidgetTester tester, {
      AppLanguage language = AppLanguage.en,
      bool resolve = true,
      Size size = const Size(420, 900),
      double textScale = 1,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            placeSearchProvider.overrideWithValue(service),
            initialSettingsProvider.overrideWithValue(
              const AppSettings.defaults().copyWith(language: language),
            ),
          ],
          child: MaterialApp(
            locale: Locale(language.name),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: buildTheme(Brightness.light),
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: PlaceSearchPanel(
                  settlementsOnly: true,
                  resolveDetails: resolve,
                  onPicked: picked.add,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> search(WidgetTester tester, String text) async {
      await tester.enterText(find.byKey(const Key('place-field')), text);
      await tester.tap(find.byKey(const Key('place-button')));
      await tester.pumpAndSettle();
    }

    String message(WidgetTester tester) => tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const Key('place-message')),
            matching: find.byType(Text),
          ),
        )
        .data!;

    testWidgets(
      'says before anything is sent that it needs the internet once',
      (tester) async {
        await pump(tester);
        expect(find.byKey(const Key('place-notice')), findsOneWidget);
        expect(find.textContaining('only this once'), findsOneWidget);
        expect(find.textContaining('Nominatim'), findsWidgets);
        expect(
          service.queries,
          isEmpty,
          reason: 'nothing is sent by showing it',
        );
      },
    );

    testWidgets('typing sends nothing; Search and Enter do', (tester) async {
      await pump(tester);
      await tester.enterText(
        find.byKey(const Key('place-field')),
        'Mumbai, India',
      );
      await tester.pump(const Duration(seconds: 2));
      expect(service.queries, isEmpty);
      await tester.tap(find.byKey(const Key('place-button')));
      await tester.pumpAndSettle();
      expect(service.queries, ['Mumbai, India']);
      await tester.enterText(find.byKey(const Key('place-field')), 'Delhi');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(service.queries, ['Mumbai, India', 'Delhi']);
    });

    testWidgets('results list names and regions and a tap chooses', (
      tester,
    ) async {
      await pump(tester);
      await search(tester, 'Mumbai');
      expect(find.byKey(const Key('place-results')), findsOneWidget);
      Finder inResults(String text) => find.descendant(
        of: find.byKey(const Key('place-results')),
        matching: find.text(text),
      );
      expect(inResults('Mumbai'), findsOneWidget);
      expect(inResults('Navi Mumbai'), findsOneWidget);
      expect(find.text('Maharashtra · India'), findsNWidgets(2));
      await tester.tap(find.byKey(const Key('place-result-0')));
      await tester.pumpAndSettle();
      expect(picked.single.place.name, 'Mumbai');
      expect(picked.single.details!.zoneId, 'Asia/Kolkata');
    });

    testWidgets('a short text and no result are explained', (tester) async {
      await pump(tester);
      await search(tester, 'a');
      expect(message(tester), 'Type at least two letters, then press Search.');
      service.places = const [];
      await search(tester, 'zzzz');
      expect(message(tester), contains('No place found for “zzzz”'));
    });

    for (final entry in {
      PlaceSearchFailure.offline: 'no internet connection',
      PlaceSearchFailure.timeout: 'did not answer in time',
      PlaceSearchFailure.busy: 'is busy',
      PlaceSearchFailure.failed: 'did not work',
    }.entries) {
      testWidgets('${entry.key.name}: says what to do', (tester) async {
        service.failure = PlaceSearchException(entry.key);
        await pump(tester);
        await search(tester, 'Mumbai');
        expect(message(tester).toLowerCase(), contains(entry.value));
        // Search can simply be pressed again.
        service.failure = null;
        await tester.tap(find.byKey(const Key('place-button')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('place-message')), findsNothing);
      });
    }

    testWidgets('a failed time-zone lookup keeps the list and says so', (
      tester,
    ) async {
      await pump(tester);
      await search(tester, 'Mumbai');
      service.detailsFailure = const PlaceSearchException(
        PlaceSearchFailure.offline,
      );
      await tester.tap(find.byKey(const Key('place-result-0')));
      await tester.pumpAndSettle();
      expect(picked, isEmpty);
      expect(message(tester), contains('time zone could not be fetched'));
      expect(find.byKey(const Key('place-result-1')), findsOneWidget);
    });

    testWidgets('without details a tap hands over the place at once', (
      tester,
    ) async {
      await pump(tester, resolve: false);
      await search(tester, 'Mumbai');
      await tester.tap(find.byKey(const Key('place-result-1')));
      await tester.pumpAndSettle();
      expect(picked.single.place.name, 'Navi Mumbai');
      expect(picked.single.details, isNull);
      expect(service.detailsCalls, 0);
    });

    testWidgets('while it waits the button is off and a progress line shows', (
      tester,
    ) async {
      final gate = Completer<void>();
      service.gate = gate.future;
      await pump(tester);
      await tester.enterText(find.byKey(const Key('place-field')), 'Mumbai');
      await tester.tap(find.byKey(const Key('place-button')));
      await tester.pump();
      expect(find.byKey(const Key('place-progress')), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('place-button')))
            .onPressed,
        isNull,
      );
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('place-progress')), findsNothing);
    });

    testWidgets('the notice names Open-Meteo only when the coordinates of '
        'the chosen place are sent there', (tester) async {
      await pump(tester);
      String notice() =>
          tester.widget<Text>(find.byKey(const Key('place-notice-text'))).data!;
      expect(notice(), contains('Open-Meteo'));
      await pump(tester, resolve: false);
      expect(notice(), isNot(contains('Open-Meteo')));
    });

    testWidgets('the credit names both services', (tester) async {
      await pump(tester);
      final credit = tester
          .widget<Text>(find.byKey(const Key('place-attribution')))
          .data!;
      expect(credit, contains('OpenStreetMap'));
      expect(credit, contains('Open-Meteo'));
    });

    testWidgets('the search language follows the app language', (tester) async {
      await pump(tester, language: AppLanguage.ar);
      await search(tester, 'مومباي');
      expect(service.languages, ['ar']);
    });

    for (final language in AppLanguage.values) {
      for (final size in const [Size(360, 800), Size(900, 800)]) {
        testWidgets(
          '${language.name} ${size.width.toInt()}px x2: every state fits',
          (tester) async {
            await pump(tester, language: language, size: size, textScale: 2);
            await search(tester, 'a');
            expect(tester.takeException(), isNull);
            await search(tester, 'Mumbai');
            expect(tester.takeException(), isNull);
            expect(find.byKey(const Key('place-results')), findsOneWidget);
            service.places = const [];
            await search(tester, 'zzzz');
            expect(tester.takeException(), isNull);
            service.failure = const PlaceSearchException(
              PlaceSearchFailure.offline,
            );
            await search(tester, 'Mumbai');
            expect(tester.takeException(), isNull);
            final l10n = AppLocalizations.of(
              tester.element(find.byKey(const Key('place-notice'))),
            );
            expect(l10n.localeName, language.name);
            expect(l10n.placeSearchNotice.trim(), isNotEmpty);
          },
        );
      }
    }
  });
}

class _Throwing implements PlaceSearchService {
  @override
  Future<List<FoundPlace>> search(
    String query, {
    required String language,
    bool settlementsOnly = false,
    int limit = 8,
  }) => Future.error(StateError('boom'));

  @override
  Future<PlaceDetails> details(double latitude, double longitude) =>
      Future.error(StateError('boom'));
}
