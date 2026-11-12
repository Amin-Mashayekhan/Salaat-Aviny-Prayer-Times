import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/data/settings_repository.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:prayer_core/prayer_core.dart';

/// Why a settings change was refused. The state is left unchanged.
enum SettingsFailure {
  /// A number outside its allowed range.
  outOfRange,

  /// The thing to change does not exist.
  notFound,

  /// An id that is already taken.
  duplicate,

  /// The last saved location cannot be removed.
  lastLocation,

  /// Anything else that makes the input unusable.
  invalid,
}

/// The loaded settings, injected at start-up by `bootstrap` (and by tests).
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings.defaults(),
);

/// The settings repository, injected at start-up.
final settingsRepositoryProvider = Provider<SettingsRepository?>((ref) => null);

/// The single writer of user settings.
///
/// Every change is a named method called from a user action. Nothing else
/// writes settings: recalculation, date rollover, location loading and app
/// start only read them.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final initial = ref.read(initialSettingsProvider);
    listenSelf((previous, next) {
      if (previous != null && previous != next) {
        ref.read(settingsRepositoryProvider)?.save(next);
      }
    });
    return initial;
  }

  // ---- appearance -----------------------------------------------------

  /// Sets the UI language.
  void setLanguage(AppLanguage value) =>
      state = state.copyWith(language: value);

  /// Sets the theme.
  void setTheme(ThemeSetting value) => state = state.copyWith(theme: value);

  /// Sets the digit style.
  void setDigits(DigitStyle value) => state = state.copyWith(digits: value);

  /// Sets the clock style.
  void setHourFormat(HourFormat value) =>
      state = state.copyWith(hourFormat: value);

  // ---- locations ------------------------------------------------------

  /// Adds [location] and optionally makes it active.
  SettingsFailure? addLocation(SavedLocation location, {bool activate = true}) {
    if (state.locations.any((l) => l.id == location.id)) {
      return SettingsFailure.duplicate;
    }
    state = state.copyWith(
      locations: [...state.locations, location],
      activeLocationId: activate ? location.id : null,
    );
    return null;
  }

  /// Replaces the saved location with the same id.
  SettingsFailure? updateLocation(SavedLocation location) {
    if (state.locations.every((l) => l.id != location.id)) {
      return SettingsFailure.notFound;
    }
    state = state.copyWith(
      locations: [
        for (final l in state.locations)
          if (l.id == location.id) location else l,
      ],
    );
    return null;
  }

  /// Sets the offset rule of a saved location (the only way it changes).
  SettingsFailure? setLocationOffset(String id, LocationOffset offset) {
    final index = state.locations.indexWhere((l) => l.id == id);
    if (index < 0) return SettingsFailure.notFound;
    final fixed = offset.fixedMinutes;
    if (offset.mode == OffsetMode.fixed &&
        (fixed == null ||
            fixed < LocationOffset.minFixedMinutes ||
            fixed > LocationOffset.maxFixedMinutes)) {
      return SettingsFailure.outOfRange;
    }
    return updateLocation(state.locations[index].withOffset(offset));
  }

  /// Removes a saved location; the active one falls back to the first.
  SettingsFailure? removeLocation(String id) {
    if (state.locations.every((l) => l.id != id)) {
      return SettingsFailure.notFound;
    }
    if (state.locations.length == 1) return SettingsFailure.lastLocation;
    final remaining = [
      for (final l in state.locations)
        if (l.id != id) l,
    ];
    state = state.copyWith(
      locations: remaining,
      activeLocationId: state.activeLocationId == id
          ? remaining.first.id
          : state.activeLocationId,
    );
    return null;
  }

  /// Makes the saved location [id] the active one.
  SettingsFailure? setActiveLocation(String id) {
    if (state.locations.every((l) => l.id != id)) {
      return SettingsFailure.notFound;
    }
    state = state.copyWith(activeLocationId: id);
    return null;
  }

  // ---- calculation ----------------------------------------------------

  /// Applies a built-in method: copies its numbers into the parameters while
  /// keeping the user own Asr rule, high-latitude rule and Imsak minutes.
  void applyMethod(CalculationMethod method) {
    final current = state.calculation.params;
    state = state.copyWith(
      calculation: state.calculation.copyWith(
        params: method.params.copyWith(
          asr: current.asr,
          highLatitude: current.highLatitude,
          imsakMinutes: current.imsakMinutes,
        ),
      ),
    );
  }

  /// Sets all calculation parameters (the method then reads as custom if it
  /// matches no built-in one).
  SettingsFailure? setParams(CalculationParams params) {
    if (params.fajrAngle < 5 || params.fajrAngle > 30) {
      return SettingsFailure.outOfRange;
    }
    final isha = params.ishaAngle;
    if (isha != null && (isha < 5 || isha > 30)) {
      return SettingsFailure.outOfRange;
    }
    final maghrib = params.maghribAngle;
    if (maghrib != null && (maghrib < 0 || maghrib > 10)) {
      return SettingsFailure.outOfRange;
    }
    if (params.imsakMinutes < 0 || params.imsakMinutes > 60) {
      return SettingsFailure.outOfRange;
    }
    state = state.copyWith(
      calculation: state.calculation.copyWith(params: params),
    );
    return null;
  }

  /// Sets the minute offset of one prayer (-60 to 60).
  SettingsFailure? setPrayerOffset(Prayer prayer, int minutes) {
    if (minutes.abs() > CalculationSettings.maxOffsetMinutes) {
      return SettingsFailure.outOfRange;
    }
    final next = {...state.calculation.offsetsMinutes};
    if (minutes == 0) {
      next.remove(prayer);
    } else {
      next[prayer] = minutes;
    }
    state = state.copyWith(
      calculation: state.calculation.copyWith(offsetsMinutes: next),
    );
    return null;
  }

  /// Clears every per-prayer offset.
  void resetPrayerOffsets() => state = state.copyWith(
    calculation: state.calculation.copyWith(offsetsMinutes: const {}),
  );

  /// Chooses which rows are shown.
  void setDisplay(DisplaySettings value) =>
      state = state.copyWith(display: value);

  // ---- azan and reminders --------------------------------------------

  /// Master azan switch.
  void setAzanEnabled({required bool enabled}) =>
      state = state.copyWith(azan: state.azan.copyWith(enabled: enabled));

  /// Master azan volume, 0 to 1.
  SettingsFailure? setMasterVolume(double volume) {
    if (volume < 0 || volume > 1) return SettingsFailure.outOfRange;
    state = state.copyWith(azan: state.azan.copyWith(masterVolume: volume));
    return null;
  }

  /// Two-second fade-in switch.
  void setFadeIn({required bool enabled}) =>
      state = state.copyWith(azan: state.azan.copyWith(fadeIn: enabled));

  /// Settings of one prayer azan.
  SettingsFailure? setPrayerAzan(Prayer prayer, PrayerAzan value) {
    if (!prayer.hasAzan) return SettingsFailure.invalid;
    if (value.volume < 0 || value.volume > 1) return SettingsFailure.outOfRange;
    state = state.copyWith(
      azan: state.azan.copyWith(
        perPrayer: {...state.azan.perPrayer, prayer: value},
      ),
    );
    return null;
  }

  /// Sets or clears the quick mute.
  void setMute(MuteSetting mute) =>
      state = state.copyWith(azan: state.azan.copyWith(mute: mute));

  /// Reminder lead time of one prayer in minutes (0 = off).
  SettingsFailure? setReminderMinutes(Prayer prayer, int minutes) {
    if (!prayer.hasAzan) return SettingsFailure.invalid;
    if (minutes < 0 || minutes > ReminderSettings.maxMinutes) {
      return SettingsFailure.outOfRange;
    }
    state = state.copyWith(
      reminders: state.reminders.copyWith(
        minutesBefore: {...state.reminders.minutesBefore, prayer: minutes},
      ),
    );
    return null;
  }

  /// Reminder chime switch.
  void setReminderChime({required bool enabled}) => state = state.copyWith(
    reminders: state.reminders.copyWith(chime: enabled),
  );

  // ---- dates ---------------------------------------------------------

  /// Hijri date adjustment in days (-2 to +2).
  SettingsFailure? setHijriAdjustment(int days) {
    if (days.abs() > AppSettings.maxHijriAdjustment) {
      return SettingsFailure.outOfRange;
    }
    state = state.copyWith(hijriAdjustmentDays: days);
    return null;
  }

  // ---- window, startup, network time ---------------------------------

  /// Close-to-tray switch.
  void setCloseToTray({required bool enabled}) => state = state.copyWith(
    window: state.window.copyWith(closeToTray: enabled),
  );

  /// Start-minimised switch.
  void setStartMinimized({required bool enabled}) => state = state.copyWith(
    window: state.window.copyWith(startMinimized: enabled),
  );

  /// Start-with-Windows switch.
  void setLaunchAtStartup({required bool enabled}) => state = state.copyWith(
    window: state.window.copyWith(launchAtStartup: enabled),
  );

  /// Network time settings.
  void setNetworkTime(NetworkTimeSettings value) =>
      state = state.copyWith(networkTime: value);

  /// Agrees (or stops agreeing) to load qibla map tiles from the internet.
  void setQiblaMapEnabled({required bool enabled}) =>
      state = state.copyWith(qibla: state.qibla.copyWith(mapEnabled: enabled));

  /// Chooses the street map or the satellite photographs for the qibla map.
  void setQiblaMapStyle(QiblaMapStyle style) =>
      state = state.copyWith(qibla: state.qibla.copyWith(mapStyle: style));

  // ---- wake-up alarms ------------------------------------------------

  /// Adds or replaces a wake-up alarm.
  void upsertWakeAlarm(WakeAlarm alarm) {
    final exists = state.wakeAlarms.any((a) => a.id == alarm.id);
    state = state.copyWith(
      wakeAlarms: exists
          ? [
              for (final a in state.wakeAlarms)
                if (a.id == alarm.id) alarm else a,
            ]
          : [...state.wakeAlarms, alarm],
    );
  }

  /// Removes a wake-up alarm.
  SettingsFailure? removeWakeAlarm(String id) {
    if (state.wakeAlarms.every((a) => a.id != id)) {
      return SettingsFailure.notFound;
    }
    state = state.copyWith(
      wakeAlarms: [
        for (final a in state.wakeAlarms)
          if (a.id != id) a,
      ],
    );
    return null;
  }

  // ---- whole-file operations ----------------------------------------

  /// Marks the first-run flow as finished.
  void completeOnboarding() =>
      state = state.copyWith(onboardingCompleted: true);

  /// Replaces everything (backup import).
  // A method matches the other mutations better than a setter.
  // ignore: use_setters_to_change_properties
  void replaceAll(AppSettings settings) => state = settings;

  /// Restores factory defaults but keeps the onboarding flag set.
  void resetToDefaults() =>
      state = const AppSettings.defaults().copyWith(onboardingCompleted: true);
}

/// Provider of the user settings.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
