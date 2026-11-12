import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/places/application/place_search_model.dart';
import 'package:owghat_lib/src/features/settings/application/location_draft.dart';

/// The saved location that a chosen place makes, or null when it cannot be
/// used: the details are missing, the latitude is too close to a pole or the
/// time zone is not in the bundled database (prayer times need an offset
/// that works offline).
SavedLocation? savedLocationFromPlace(
  PickedPlace picked, {
  required Iterable<String> existingIds,
  required ZoneOffsetResolver resolver,
}) {
  final details = picked.details;
  if (details == null) return null;
  final place = picked.place;
  if (place.latitude.abs() > SavedLocation.maxLatitude) return null;
  if (!resolver.knowsZone(details.zoneId)) return null;
  return SavedLocation.custom(
    id: nextCustomLocationId(existingIds),
    name: place.name,
    latitude: place.latitude,
    longitude: place.longitude,
    zoneId: details.zoneId,
    elevationMeters: details.elevationMeters,
  );
}

/// The already saved custom location that is the same place as [picked]
/// (same name, within about two kilometres), so choosing it twice does not
/// add it twice.
SavedLocation? sameSavedPlace(
  PickedPlace picked,
  Iterable<SavedLocation> saved,
) {
  for (final location in saved) {
    if (location.kind != LocationKind.custom) continue;
    if (location.name != picked.place.name) continue;
    if ((location.latitude! - picked.place.latitude).abs() < 0.02 &&
        (location.longitude! - picked.place.longitude).abs() < 0.02) {
      return location;
    }
  }
  return null;
}
