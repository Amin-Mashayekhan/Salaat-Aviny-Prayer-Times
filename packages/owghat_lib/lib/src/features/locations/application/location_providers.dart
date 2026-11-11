import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// The bundled city database. Injected at start-up (and by tests).
final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => throw StateError('locationRepositoryProvider was not overridden'),
);

/// Every saved location that can be resolved, in saved order.
final savedLocationsProvider = Provider<List<ResolvedLocation>>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  final saved = ref.watch(settingsProvider.select((s) => s.locations));
  return [
    for (final location in saved) ?ResolvedLocation.from(location, repository),
  ];
});

/// The active location. Falls back to the first resolvable one, then to
/// Tehran, so the app always has somewhere to calculate for.
final activeLocationProvider = Provider<ResolvedLocation>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final all = ref.watch(savedLocationsProvider);
  for (final location in all) {
    if (location.id == settings.activeLocationId) return location;
  }
  if (all.isNotEmpty) return all.first;
  return ResolvedLocation.from(AppSettings.defaultLocation, repository)!;
});
