import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/core/platform/place_search.dart';

/// Where a place search stands.
enum PlaceSearchStatus {
  /// Nothing searched yet.
  idle,

  /// The text was too short to search for.
  tooShort,

  /// Waiting for the search service.
  searching,

  /// There are results to choose from.
  results,

  /// The search worked but found nothing.
  empty,

  /// The search (or the lookup of the chosen place) failed.
  failed,

  /// A place was chosen and its time zone and height are being fetched.
  resolving,
}

/// A place the person chose, with its time zone and height when they were
/// asked for.
@immutable
class PickedPlace {
  /// Creates it.
  const PickedPlace(this.place, [this.details]);

  /// The place.
  final FoundPlace place;

  /// Its time zone and height, or null when they were not requested.
  final PlaceDetails? details;
}

/// The state and logic of one place search box: type, press Search, choose.
///
/// Searching sends the typed text to the search service, once per press; the
/// choice of a place may send its coordinates to look up the time zone. Only
/// one request runs at a time and a late answer to an old request is dropped.
class PlaceSearchModel extends ChangeNotifier {
  /// Creates the model.
  PlaceSearchModel({
    required this.service,
    required this.language,
    this.settlementsOnly = false,
    this.resolveDetails = false,
  });

  /// The search service.
  final PlaceSearchService service;

  /// Language code of the names to ask for; read at each search so that a
  /// change of the app language applies to the next one.
  final String Function() language;

  /// Restrict the answer to cities, towns and villages.
  final bool settlementsOnly;

  /// Whether choosing a place also fetches its time zone and height.
  final bool resolveDetails;

  PlaceSearchStatus _status = PlaceSearchStatus.idle;
  List<FoundPlace> _results = const [];
  String _query = '';
  PlaceSearchFailure? _failure;
  bool _detailsFailed = false;
  FoundPlace? _resolving;
  int _request = 0;
  bool _disposed = false;

  /// Where the search stands.
  PlaceSearchStatus get status => _status;

  /// The places found by the last search.
  List<FoundPlace> get results => _results;

  /// The text of the last search.
  String get query => _query;

  /// Why the last request failed, when [status] is
  /// [PlaceSearchStatus.failed].
  PlaceSearchFailure? get failure => _failure;

  /// Whether the failure was in fetching the time zone of a chosen place
  /// rather than in the search itself.
  bool get detailsFailed => _detailsFailed;

  /// The place whose details are being fetched.
  FoundPlace? get resolving => _resolving;

  /// Whether a request is running.
  bool get busy =>
      _status == PlaceSearchStatus.searching ||
      _status == PlaceSearchStatus.resolving;

  void _set(PlaceSearchStatus status) {
    _status = status;
    if (!_disposed) notifyListeners();
  }

  /// Searches for [text]. Does nothing while another request runs.
  Future<void> search(String text) async {
    if (busy) return;
    final trimmed = text.trim();
    _query = trimmed;
    _failure = null;
    _detailsFailed = false;
    if (trimmed.runes.length < 2) {
      _results = const [];
      _set(PlaceSearchStatus.tooShort);
      return;
    }
    final request = ++_request;
    _set(PlaceSearchStatus.searching);
    try {
      final found = await service.search(
        trimmed,
        language: language(),
        settlementsOnly: settlementsOnly,
      );
      if (request != _request || _disposed) return;
      _results = found;
      _set(found.isEmpty ? PlaceSearchStatus.empty : PlaceSearchStatus.results);
    } on PlaceSearchException catch (error) {
      if (request != _request || _disposed) return;
      _results = const [];
      _failure = error.failure;
      _set(PlaceSearchStatus.failed);
    } on Object {
      if (request != _request || _disposed) return;
      _results = const [];
      _failure = PlaceSearchFailure.failed;
      _set(PlaceSearchStatus.failed);
    }
  }

  /// Chooses [place]. With [resolveDetails] this fetches the time zone and
  /// height first; on failure it returns null and [detailsFailed] is true, so
  /// the person can choose again.
  Future<PickedPlace?> pick(FoundPlace place) async {
    if (busy) return null;
    if (!resolveDetails) return PickedPlace(place);
    final request = ++_request;
    _resolving = place;
    _failure = null;
    _detailsFailed = false;
    _set(PlaceSearchStatus.resolving);
    try {
      final details = await service.details(place.latitude, place.longitude);
      if (request != _request || _disposed) return null;
      _resolving = null;
      _set(PlaceSearchStatus.results);
      return PickedPlace(place, details);
    } on PlaceSearchException catch (error) {
      if (request != _request || _disposed) return null;
      _fail(error.failure);
    } on Object {
      if (request != _request || _disposed) return null;
      _fail(PlaceSearchFailure.failed);
    }
    return null;
  }

  void _fail(PlaceSearchFailure failure) {
    _resolving = null;
    _failure = failure;
    _detailsFailed = true;
    _set(PlaceSearchStatus.failed);
  }

  /// Forgets the results (for example when the page is left).
  void clear() {
    _request++;
    _results = const [];
    _query = '';
    _failure = null;
    _detailsFailed = false;
    _resolving = null;
    _set(PlaceSearchStatus.idle);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
