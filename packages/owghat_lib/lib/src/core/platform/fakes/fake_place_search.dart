import 'dart:async';

import 'package:owghat_lib/src/core/platform/place_search.dart';

/// A [PlaceSearchService] for tests: answers from [places], throws
/// [failure], or waits for [gate] first.
class FakePlaceSearch implements PlaceSearchService {
  /// Creates the fake; by default it knows Mumbai and Nishapur.
  FakePlaceSearch({List<FoundPlace>? places})
    : places =
          places ??
          const [
            FoundPlace(
              name: 'Mumbai',
              region: 'Maharashtra · India',
              country: 'India',
              latitude: 19.0759,
              longitude: 72.8777,
            ),
            FoundPlace(
              name: 'Navi Mumbai',
              region: 'Maharashtra · India',
              country: 'India',
              latitude: 19.0368,
              longitude: 73.0158,
            ),
          ];

  /// What a search returns.
  List<FoundPlace> places;

  /// What `details` returns.
  PlaceDetails detailsResult = const PlaceDetails(
    zoneId: 'Asia/Kolkata',
    elevationMeters: 9,
  );

  /// When set, `search` throws it.
  PlaceSearchException? failure;

  /// When set, `details` throws it.
  PlaceSearchException? detailsFailure;

  /// When set, `search` waits for it before answering.
  Future<void>? gate;

  /// The queries received, in order.
  final List<String> queries = [];

  /// The languages received, in order.
  final List<String> languages = [];

  /// The `settlementsOnly` flags received, in order.
  final List<bool> settlementFlags = [];

  /// Number of `details` calls.
  int detailsCalls = 0;

  @override
  Future<List<FoundPlace>> search(
    String query, {
    required String language,
    bool settlementsOnly = false,
    int limit = 8,
  }) async {
    queries.add(query);
    languages.add(language);
    settlementFlags.add(settlementsOnly);
    final waiting = gate;
    if (waiting != null) await waiting;
    final error = failure;
    if (error != null) throw error;
    return places;
  }

  @override
  Future<PlaceDetails> details(double latitude, double longitude) async {
    detailsCalls++;
    final error = detailsFailure;
    if (error != null) throw error;
    return detailsResult;
  }
}
