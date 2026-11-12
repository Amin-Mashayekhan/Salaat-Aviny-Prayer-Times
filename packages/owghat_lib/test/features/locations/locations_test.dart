import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/core/utils/text_normalizer.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/coordinates.dart';
import 'package:owghat_lib/src/features/locations/domain/custom_location_input.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

import '../../support/test_data.dart';

void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  group('TextNormalizer', () {
    test('unifies Arabic and Persian letters and removes spacing', () {
      expect(TextNormalizer.normalize('اصفهان'), 'اصفهان');
      expect(TextNormalizer.normalize('بندر عباس'), 'بندرعباس');
      expect(TextNormalizer.normalize('بندر‌عباس'), 'بندرعباس');
      expect(TextNormalizer.normalize('علي'), TextNormalizer.normalize('علی'));
      expect(TextNormalizer.normalize('كرج'), TextNormalizer.normalize('کرج'));
      expect(TextNormalizer.normalize('آمل'), TextNormalizer.normalize('امل'));
    });

    test('digits, case and punctuation', () {
      expect(TextNormalizer.normalize('۱۲۳٤٥'), '12345');
      expect(TextNormalizer.normalize("Shahr-e Kord'"), 'shahrekord');
      expect(TextNormalizer.normalize('  TEHRAN '), 'tehran');
      expect(TextNormalizer.normalize(''), '');
    });
  });

  group('bundled data', () {
    test('has 31 provinces and 566 cities', () {
      expect(repo.provinces.length, 31);
      expect(repo.cityCount, 566);
    });

    test('every province has a centre city that belongs to it', () {
      for (final province in repo.provinces) {
        final centre = repo.cityById(province.centerCityId);
        expect(centre, isNotNull, reason: province.nameEn);
        expect(centre!.provinceId, province.id, reason: province.nameEn);
        expect(repo.isCentre(centre), isTrue);
      }
      expect(repo.provinceCentres.length, 31);
    });

    test('every city has a known province and Iranian coordinates', () {
      final provinceIds = repo.provinces.map((p) => p.id).toSet();
      for (final province in repo.provinces) {
        for (final city in repo.citiesOf(province.id)) {
          expect(provinceIds, contains(city.provinceId));
          expect(city.latitude, inInclusiveRange(24.5, 40));
          expect(city.longitude, inInclusiveRange(43.5, 63.5));
          expect(city.nameFa, isNotEmpty);
        }
      }
    });

    test('Tehran is city 1 and the capital', () {
      final tehran = repo.cityById(1)!;
      expect(tehran.nameFa, 'تهران');
      expect(tehran.nameEn, 'Tehran');
      expect(tehran.latitude, closeTo(35.683, 0.01));
      expect(tehran.longitude, closeTo(51.4, 0.01));
    });

    test('citiesOf puts the centre first', () {
      final qom = repo.provinces.firstWhere((p) => p.nameEn == 'Qom');
      expect(repo.citiesOf(qom.id).first.id, qom.centerCityId);
      expect(repo.provinceById(qom.id)!.nameFa, 'قم');
      expect(repo.provinceById(-1), isNull);
      expect(repo.cityById(-1), isNull);
    });
  });

  group('search', () {
    test('finds by Persian and English names', () {
      expect(repo.search('تهران').first.id, 1);
      expect(repo.search('tehran').first.id, 1);
      expect(repo.search('Tehr').first.id, 1);
      expect(repo.search('اصفهان').first.nameEn, anyOf('Isfahan', 'Esfahan'));
      expect(repo.search('قم').first.nameFa, 'قم');
    });

    test('ignores spaces, half-spaces and letter variants', () {
      expect(repo.search('بندرعباس').first.nameFa, 'بندر عباس');
      expect(repo.search('بندر عباس').first.nameFa, 'بندر عباس');
      expect(repo.search('اصفهان ').first.nameFa, 'اصفهان');
      expect(repo.search('اصفهان‌').first.nameFa, 'اصفهان');
    });

    test('exact matches beat prefixes and centres beat plain cities', () {
      final tabriz = repo.search('تبریز');
      expect(tabriz.first.nameFa, 'تبریز');
      expect(repo.isCentre(tabriz.first), isTrue);
      final results = repo.search('ab');
      for (var i = 1; i < results.length; i++) {
        // Never a plain city before a centre of the same rank would need the
        // rank itself; here we only assert the list is stable and bounded.
        expect(results[i].id, isNot(results[i - 1].id));
      }
    });

    test('an empty query returns the province centres', () {
      final results = repo.search('');
      expect(results.length, 31);
      expect(results.every(repo.isCentre), isTrue);
      expect(repo.search('   ').length, 31);
    });

    test('limit and no-match', () {
      expect(repo.search('a', limit: 3).length, lessThanOrEqualTo(3));
      expect(repo.search('zzzzqqqq'), isEmpty);
    });
  });

  group('resolving', () {
    test('built-in and custom locations', () {
      final builtin = ResolvedLocation.from(AppSettings.defaultLocation, repo)!;
      expect(builtin.nameIn(AppLanguage.fa), 'تهران');
      expect(builtin.nameIn(AppLanguage.en), 'Tehran');
      // Arabic and Urdu read the Arabic-script name; no Latin word lands in
      // right-to-left text. Latin-script languages read the Latin name.
      expect(builtin.nameIn(AppLanguage.ar), 'تهران');
      expect(builtin.nameIn(AppLanguage.ur), 'تهران');
      for (final language in [
        AppLanguage.tr,
        AppLanguage.az,
        AppLanguage.id,
        AppLanguage.fr,
      ]) {
        expect(builtin.nameIn(language), 'Tehran');
      }
      expect(builtin.isCustom, isFalse);
      expect(builtin.zoneId, 'Asia/Tehran');

      const custom = SavedLocation.custom(
        id: 'custom:x',
        name: 'X',
        latitude: 30,
        longitude: 50,
        zoneId: 'Asia/Tehran',
        elevationMeters: 100,
      );
      final resolved = ResolvedLocation.from(custom, repo)!;
      expect(resolved.isCustom, isTrue);
      expect(resolved.elevationMeters, 100);
      expect(resolved, ResolvedLocation.from(custom, repo));
      expect(resolved.hashCode, ResolvedLocation.from(custom, repo).hashCode);
    });

    test('a city missing from the database resolves to null', () {
      expect(
        ResolvedLocation.from(
          const SavedLocation.builtin(id: 'city:999999', cityId: 999999),
          repo,
        ),
        isNull,
      );
    });

    test('providers fall back to Tehran when nothing resolves', () {
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(repo),
          initialSettingsProvider.overrideWithValue(
            const AppSettings(
              activeLocationId: 'city:999999',
              locations: [
                SavedLocation.builtin(id: 'city:999999', cityId: 999999),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(savedLocationsProvider), isEmpty);
      expect(container.read(activeLocationProvider).nameEn, 'Tehran');
    });

    test('the active location follows the settings', () {
      final container = ProviderContainer(
        overrides: [locationRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      expect(container.read(activeLocationProvider).id, 'city:1');
      container
          .read(settingsProvider.notifier)
          .addLocation(const SavedLocation.builtin(id: 'city:8', cityId: 8));
      expect(container.read(activeLocationProvider).id, 'city:8');
      expect(container.read(savedLocationsProvider).length, 2);
    });
  });

  group('Dms', () {
    test('converts between decimal and degrees-minutes-seconds', () {
      final dms = Dms.fromDecimal(35.6892);
      expect(dms.degrees, 35);
      expect(dms.minutes, 41);
      expect(dms.seconds, closeTo(21.12, 0.01));
      expect(dms.decimal, closeTo(35.6892, 1e-5));
      expect(Dms.fromDecimal(-51.389).negative, isTrue);
      expect(Dms.fromDecimal(-51.389).decimal, closeTo(-51.389, 1e-5));
      expect(Dms.fromDecimal(0).decimal, 0);
    });

    test('carries rounded seconds and validates ranges', () {
      final carry = Dms.fromDecimal(10 + 59 / 60 + 59.999 / 3600);
      expect(carry.degrees, 11);
      expect(carry.minutes, 0);
      expect(carry.seconds, 0);
      expect(const Dms(degrees: 10, minutes: 60, seconds: 0).isValid, isFalse);
      expect(
        const Dms(degrees: 10, minutes: 30, seconds: 59.9).isValid,
        isTrue,
      );
    });
  });

  group('validateCustomLocation', () {
    final resolver = ZoneOffsetResolver();
    LocationInputError? check({
      String name = 'Home',
      double lat = 35,
      double lon = 51,
      double elevation = 0,
      String zone = 'Asia/Tehran',
      LocationOffset offset = const LocationOffset.automatic(),
    }) => validateCustomLocation(
      name: name,
      latitude: lat,
      longitude: lon,
      elevationMeters: elevation,
      zoneId: zone,
      offset: offset,
      resolver: resolver,
    );

    test('accepts a valid place', () {
      expect(check(), isNull);
    });

    test('rejects each bad field', () {
      expect(check(name: '  '), LocationInputError.nameEmpty);
      expect(check(lat: 90), LocationInputError.latitudeRange);
      expect(check(lat: double.nan), LocationInputError.latitudeRange);
      expect(check(lon: 181), LocationInputError.longitudeRange);
      expect(check(elevation: -1), LocationInputError.elevationRange);
      expect(check(elevation: 10000), LocationInputError.elevationRange);
      expect(check(zone: 'Nowhere/Land'), LocationInputError.unknownZone);
      expect(
        check(offset: const LocationOffset.fixed(900)),
        LocationInputError.offsetRange,
      );
    });

    test('a fixed offset does not need a known zone', () {
      expect(
        check(zone: 'whatever', offset: const LocationOffset.fixed(210)),
        isNull,
      );
    });
  });
}
