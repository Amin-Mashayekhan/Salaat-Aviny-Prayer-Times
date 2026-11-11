import 'dart:convert';

import 'package:owghat_lib/src/core/utils/text_normalizer.dart';
import 'package:owghat_lib/src/features/locations/domain/city.dart';

/// Loads a bundled text asset by path. In the app it is `rootBundle`; tests
/// read the file from disk.
typedef AssetTextLoader = Future<String> Function(String path);

/// Path of the bundled city list inside the library package.
const String citiesAssetPath = 'packages/owghat_lib/assets/data/cities.json';

/// Path of the bundled province list inside the library package.
const String provincesAssetPath =
    'packages/owghat_lib/assets/data/provinces.json';

/// The bundled database of Iranian provinces and cities (read-only).
class LocationRepository {
  LocationRepository._(this.provinces, this._cities)
    : _byId = {for (final c in _cities) c.id: c},
      _centreIds = {for (final p in provinces) p.centerCityId},
      _searchKeys = {
        for (final c in _cities)
          c.id: (
            TextNormalizer.normalize(c.nameFa),
            TextNormalizer.normalize(c.nameEn),
          ),
      };

  /// Builds a repository from decoded data; used by tests and [load].
  factory LocationRepository.fromData({
    required List<Province> provinces,
    required List<City> cities,
  }) => LocationRepository._(
    List.unmodifiable(provinces),
    List.unmodifiable(cities),
  );

  /// Loads the bundled data through [loader].
  static Future<LocationRepository> load(AssetTextLoader loader) async {
    final provinces = (jsonDecode(await loader(provincesAssetPath)) as List)
        .map((e) => Province.fromJson((e as Map).cast<String, Object?>()))
        .toList();
    final cities = (jsonDecode(await loader(citiesAssetPath)) as List)
        .map((e) => City.fromJson((e as Map).cast<String, Object?>()))
        .toList();
    return LocationRepository.fromData(provinces: provinces, cities: cities);
  }

  /// All provinces, in database order.
  final List<Province> provinces;

  final List<City> _cities;
  final Map<int, City> _byId;
  final Set<int> _centreIds;
  final Map<int, (String, String)> _searchKeys;

  /// Whether [city] is the capital or a province centre.
  bool isCentre(City city) => city.isCentre || _centreIds.contains(city.id);

  /// Number of cities.
  int get cityCount => _cities.length;

  /// The city with [id], or null.
  City? cityById(int id) => _byId[id];

  /// The province with [id], or null.
  Province? provinceById(int id) {
    for (final p in provinces) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Cities of a province: the centre first, then alphabetically (Persian).
  List<City> citiesOf(int provinceId) {
    final result = _cities.where((c) => c.provinceId == provinceId).toList()
      ..sort((a, b) {
        if (isCentre(a) != isCentre(b)) return isCentre(a) ? -1 : 1;
        return a.nameFa.compareTo(b.nameFa);
      });
    return result;
  }

  /// The province centres, in province order (the empty-search result).
  List<City> get provinceCentres => [
    for (final p in provinces)
      if (_byId[p.centerCityId] != null) _byId[p.centerCityId]!,
  ];

  /// Searches Persian and English names.
  ///
  /// Ranking: exact match, then prefix, then contained anywhere; inside a
  /// rank, capitals and province centres first, then Persian name order.
  /// An empty query returns the province centres.
  List<City> search(String query, {int limit = 50}) {
    final q = TextNormalizer.normalize(query);
    if (q.isEmpty) return provinceCentres.take(limit).toList();
    final scored = <(int, City)>[];
    for (final city in _cities) {
      final keys = _searchKeys[city.id]!;
      final rank = [
        _rank(keys.$1, q),
        _rank(keys.$2, q),
      ].reduce((a, b) => a < b ? a : b);
      if (rank < 3) scored.add((rank, city));
    }
    scored.sort((a, b) {
      if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
      if (isCentre(a.$2) != isCentre(b.$2)) return isCentre(a.$2) ? -1 : 1;
      return a.$2.nameFa.compareTo(b.$2.nameFa);
    });
    return [for (final entry in scored.take(limit)) entry.$2];
  }

  static int _rank(String key, String q) {
    if (key == q) return 0;
    if (key.startsWith(q)) return 1;
    if (key.contains(q)) return 2;
    return 3;
  }
}
