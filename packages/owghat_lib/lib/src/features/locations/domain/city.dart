import 'package:flutter/foundation.dart';

/// Kind of a city in the bundled database.
enum CityKind {
  /// The national capital.
  capital,

  /// A province centre.
  provinceCenter,

  /// Any other city.
  normal,
}

/// A province of Iran.
@immutable
class Province {
  /// Creates a province.
  const Province({
    required this.id,
    required this.nameFa,
    required this.nameEn,
    required this.centerCityId,
  });

  /// Reads the compact bundled form.
  factory Province.fromJson(Map<String, Object?> json) => Province(
    id: json['id']! as int,
    nameFa: json['fa']! as String,
    nameEn: json['en']! as String,
    centerCityId: json['center']! as int,
  );

  /// Database id.
  final int id;

  /// Persian name.
  final String nameFa;

  /// English name.
  final String nameEn;

  /// Id of the centre city.
  final int centerCityId;
}

/// A city of the bundled database.
@immutable
class City {
  /// Creates a city.
  const City({
    required this.id,
    required this.provinceId,
    required this.nameFa,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
    required this.kind,
  });

  /// Reads the compact bundled form.
  factory City.fromJson(Map<String, Object?> json) => City(
    id: json['id']! as int,
    provinceId: json['p']! as int,
    nameFa: json['fa']! as String,
    nameEn: json['en']! as String,
    latitude: (json['lat']! as num).toDouble(),
    longitude: (json['lon']! as num).toDouble(),
    kind: switch (json['t']) {
      'c' => CityKind.capital,
      's' => CityKind.provinceCenter,
      _ => CityKind.normal,
    },
  );

  /// Database id.
  final int id;

  /// Province id.
  final int provinceId;

  /// Persian name.
  final String nameFa;

  /// English name.
  final String nameEn;

  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  /// Capital, province centre or normal.
  final CityKind kind;

  /// Whether this city is a capital or a province centre.
  bool get isCentre => kind != CityKind.normal;
}
