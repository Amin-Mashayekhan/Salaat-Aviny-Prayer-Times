import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/domain/city.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// Number of steps of the first-run flow: language, city, azan.
const int onboardingStepCount = 3;

/// INJECTION POINT: plays a short sample of the azan for the third step.
///
/// The default does nothing. The platform layer overrides this provider with
/// a function that starts the preview through the audio output (and
/// `azanPlaybackProvider` then reports `playing`).
final onboardingPreviewProvider = Provider<Future<void> Function()>(
  (ref) => () async {},
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

  /// Chooses the UI language. English also switches to Latin digits and
  /// Persian to Persian digits, which is the sensible pairing; the digit
  /// style can be changed independently later in the settings.
  void chooseLanguage(AppLanguage language) {
    ref.read(settingsProvider.notifier)
      ..setLanguage(language)
      ..setDigits(
        language == AppLanguage.fa ? DigitStyle.persian : DigitStyle.latin,
      );
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
