import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/domain/city.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/places/application/place_location.dart';
import 'package:owghat_lib/src/features/places/application/place_search_model.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';

/// Number of steps of the first-run flow: language, city, azan.
const int onboardingStepCount = 3;

/// Plays the bundled azan for the third step through the shared azan player,
/// so `azanPlaybackProvider` reports `playing` and the button turns into
/// "stop".
///
/// This used to be a no-op that the platform layer was supposed to override;
/// nobody did, so the button did nothing. It now works by default and tests
/// can still override it.
final onboardingPreviewProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    await ref.read(azanPlaybackProvider.notifier).preview(SoundRef.defaultAzan);
  },
);

/// Where the first-run flow is.
@immutable
class OnboardingState {
  /// Creates a state.
  const OnboardingState({this.step = 0, this.query = '', this.provinceId});

  /// Zero-based step.
  final int step;

  /// Text in the city search field.
  final String query;

  /// Province chip selected, or null for all provinces.
  final int? provinceId;

  /// Copy with changes ([clearProvince] removes the province filter).
  OnboardingState copyWith({
    int? step,
    String? query,
    int? provinceId,
    bool clearProvince = false,
  }) => OnboardingState(
    step: step ?? this.step,
    query: query ?? this.query,
    provinceId: clearProvince ? null : (provinceId ?? this.provinceId),
  );
}

/// Drives the first-run flow. Every change of a setting goes through
/// `SettingsController` and only after the user acted.
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Goes to the next step (the last step finishes instead).
  void next() {
    if (state.step >= onboardingStepCount - 1) {
      finish();
    } else {
      state = state.copyWith(step: state.step + 1);
    }
  }

  /// Goes back one step.
  void back() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  /// Chooses the UI language together with the digit style that goes with it
  /// (`AppLanguage.digits`: Persian digits for Persian and Urdu, Arabic-Indic
  /// for Arabic, Latin for the rest). The digit style can be changed on its
  /// own later in the settings.
  void chooseLanguage(AppLanguage language) {
    ref.read(settingsProvider.notifier)
      ..setLanguage(language)
      ..setDigits(language.digits);
  }

  /// Sets the search text.
  void setQuery(String query) => state = state.copyWith(query: query);

  /// Filters the cities by province (null: all).
  void setProvince(int? provinceId) => state = provinceId == null
      ? state.copyWith(clearProvince: true)
      : state.copyWith(provinceId: provinceId);

  /// Makes [city] the active location, adding it to the saved ones if it is
  /// not there yet.
  void selectCity(City city) {
    final settings = ref.read(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    for (final saved in settings.locations) {
      if (saved.kind == LocationKind.builtin && saved.cityId == city.id) {
        controller.setActiveLocation(saved.id);
        return;
      }
    }
    controller.addLocation(
      SavedLocation.builtin(id: 'city:${city.id}', cityId: city.id),
    );
  }

  /// Makes a place found by an online search the active location (a custom
  /// location with the time zone and height that came with it). Returns
  /// false when the place cannot be used, for example because its time zone
  /// is not in the bundled database.
  bool selectPlace(PickedPlace picked) {
    final settings = ref.read(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final same = sameSavedPlace(picked, settings.locations);
    if (same != null) {
      controller.setActiveLocation(same.id);
      return true;
    }
    final location = savedLocationFromPlace(
      picked,
      existingIds: [for (final l in settings.locations) l.id],
      resolver: ref.read(zoneOffsetResolverProvider),
    );
    if (location == null) return false;
    return controller.addLocation(location) == null;
  }

  /// Ends the flow (also used by "skip": every default stays).
  void finish() {
    ref.read(settingsProvider.notifier).completeOnboarding();
    state = const OnboardingState();
  }
}

/// Provider of the first-run flow.
final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

/// The cities listed in step 2: the search result (province centres for an
/// empty search), narrowed to the chosen province.
final onboardingCitiesProvider = Provider<List<City>>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  final state = ref.watch(onboardingProvider);
  final province = state.provinceId;
  if (state.query.trim().isEmpty) {
    return province == null
        ? repository.provinceCentres
        : repository.citiesOf(province);
  }
  final found = repository.search(state.query, limit: 500);
  return province == null
      ? found.take(50).toList()
      : [
          for (final city in found)
            if (city.provinceId == province) city,
        ];
});
