import 'package:owghat_lib/src/core/utils/json_value.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:prayer_core/prayer_core.dart';

/// Current version of the settings file layout.
const int settingsSchemaVersion = 1;

/// UI language.
enum AppLanguage {
  /// Persian, right-to-left.
  fa,

  /// English, left-to-right.
  en,
}

/// Theme choice.
enum ThemeSetting {
  /// Follow Windows.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// Digit style.
enum DigitStyle {
  /// Persian digits.
  persian,

  /// Latin digits.
  latin,
}

/// Clock style.
enum HourFormat {
  /// 24-hour clock.
  h24,

  /// 12-hour clock.
  h12,
}

/// Which time rows are shown (Fajr, Sunrise, Dhuhr, Maghrib and Midnight are
/// always shown).
class DisplaySettings extends JsonValue {
  /// Creates the settings.
  const DisplaySettings({
    this.showImsak = false,
    this.showAsr = true,
    this.showIsha = true,
    this.showSunset = true,
  });

  /// Reads the JSON form.
  factory DisplaySettings.fromJson(Object? raw) {
    final map = Json.map(raw);
    return DisplaySettings(
      showImsak: Json.boolean(map['showImsak'], fallback: false),
      showAsr: Json.boolean(map['showAsr'], fallback: true),
      showIsha: Json.boolean(map['showIsha'], fallback: true),
      showSunset: Json.boolean(map['showSunset'], fallback: true),
    );
  }

  /// Show the Imsak row.
  final bool showImsak;

  /// Show the Asr row.
  final bool showAsr;

  /// Show the Isha row.
  final bool showIsha;

  /// Show the Sunset row.
  final bool showSunset;

  /// Whether [prayer] is shown.
  bool shows(Prayer prayer) => switch (prayer) {
    Prayer.imsak => showImsak,
    Prayer.asr => showAsr,
    Prayer.isha => showIsha,
    Prayer.sunset => showSunset,
    _ => true,
  };

  /// Copy with changes.
  DisplaySettings copyWith({
    bool? showImsak,
    bool? showAsr,
    bool? showIsha,
    bool? showSunset,
  }) => DisplaySettings(
    showImsak: showImsak ?? this.showImsak,
    showAsr: showAsr ?? this.showAsr,
    showIsha: showIsha ?? this.showIsha,
    showSunset: showSunset ?? this.showSunset,
  );

  @override
  Map<String, Object?> toJson() => {
    'showImsak': showImsak,
    'showAsr': showAsr,
    'showIsha': showIsha,
    'showSunset': showSunset,
  };
}

/// Method, angles, rules and per-prayer minute offsets.
class CalculationSettings extends JsonValue {
  /// Creates the settings.
  const CalculationSettings({
    this.params = _tehran,
    this.offsetsMinutes = const {},
  });

  /// Reads the JSON form.
  factory CalculationSettings.fromJson(Object? raw) {
    final map = Json.map(raw);
    final preset = CalculationMethod.fromId(Json.string(map['methodId'], ''));
    final base = preset?.params ?? _tehran;
    final isha = Json.numberOrNull(map['ishaAngle'], base.ishaAngle);
    final ishaMinutes = Json.numberOrNull(map['ishaMinutes'], base.ishaMinutes);
    final hasParams = map.containsKey('fajrAngle');
    final CalculationParams params;
    if (!hasParams || (isha == null) == (ishaMinutes == null)) {
      params = base;
    } else {
      params = CalculationParams(
        fajrAngle: Json.number(map['fajrAngle'], base.fajrAngle).clamp(5, 30),
        ishaAngle: isha?.clamp(5, 30),
        ishaMinutes: ishaMinutes?.clamp(0, 240),
        maghribAngle: Json.numberOrNull(
          map['maghribAngle'],
          base.maghribAngle,
        )?.clamp(0, 10),
        midnight: Json.enumValue(
          MidnightRule.values,
          map['midnight'],
          base.midnight,
        ),
        asr: Json.enumValue(AsrRule.values, map['asr'], base.asr),
        highLatitude: Json.enumValue(
          HighLatitudeRule.values,
          map['highLatitude'],
          base.highLatitude,
        ),
        imsakMinutes: Json.number(
          map['imsakMinutes'],
          base.imsakMinutes,
        ).clamp(0, 60),
      );
    }
    final offsets = <Prayer, int>{};
    final rawOffsets = Json.map(map['offsetsMinutes']);
    for (final prayer in Prayer.values) {
      final value = rawOffsets[prayer.name];
      if (value is num && value != 0) {
        offsets[prayer] = value.toInt().clamp(
          -maxOffsetMinutes,
          maxOffsetMinutes,
        );
      }
    }
    return CalculationSettings(params: params, offsetsMinutes: offsets);
  }

  /// Largest per-prayer offset in either direction.
  static const maxOffsetMinutes = 60;

  static const CalculationParams _tehran = CalculationParams(
    fajrAngle: 17.7,
    ishaAngle: 14,
    maghribAngle: 4.5,
    midnight: MidnightRule.jafari,
  );

  /// The calculation parameters.
  final CalculationParams params;

  /// Per-prayer offsets in minutes (missing means 0).
  final Map<Prayer, int> offsetsMinutes;

  /// The built-in method these parameters equal, or custom.
  CalculationMethod get method => CalculationMethod.matching(params);

  /// Copy with changes.
  CalculationSettings copyWith({
    CalculationParams? params,
    Map<Prayer, int>? offsetsMinutes,
  }) => CalculationSettings(
    params: params ?? this.params,
    offsetsMinutes: offsetsMinutes ?? this.offsetsMinutes,
  );

  @override
  Map<String, Object?> toJson() => {
    'methodId': method.id,
    'fajrAngle': params.fajrAngle,
    'ishaAngle': params.ishaAngle,
    'ishaMinutes': params.ishaMinutes,
    'maghribAngle': params.maghribAngle,
    'midnight': params.midnight.name,
    'asr': params.asr.name,
    'highLatitude': params.highLatitude.name,
    'imsakMinutes': params.imsakMinutes,
    'offsetsMinutes': {
      for (final prayer in Prayer.values)
        if ((offsetsMinutes[prayer] ?? 0) != 0)
          prayer.name: offsetsMinutes[prayer],
    },
  };
}

/// Azan settings of one prayer.
class PrayerAzan extends JsonValue {
  /// Creates the settings.
  const PrayerAzan({
    this.enabled = false,
    this.sound = SoundRef.defaultAzan,
    this.volume = 1,
  });

  /// Reads the JSON form.
  factory PrayerAzan.fromJson(Object? raw, {required bool enabledByDefault}) {
    final map = Json.map(raw);
    return PrayerAzan(
      enabled: Json.boolean(map['enabled'], fallback: enabledByDefault),
      sound: SoundRef.parse(map['sound'] as String?),
      volume: Json.number(map['volume'], 1).clamp(0, 1),
    );
  }

  /// Whether the azan of this prayer plays.
  final bool enabled;

  /// What it plays.
  final SoundRef sound;

  /// Volume of this prayer, 0 to 1, multiplied by the master volume.
  final double volume;

  /// Copy with changes.
  PrayerAzan copyWith({bool? enabled, SoundRef? sound, double? volume}) =>
      PrayerAzan(
        enabled: enabled ?? this.enabled,
        sound: sound ?? this.sound,
        volume: volume ?? this.volume,
      );

  @override
  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'sound': sound.encoded,
    'volume': volume,
  };
}

/// The user quick-mute. Expiry is evaluated at read time and never written
/// back (rule T-5).
class MuteSetting extends JsonValue {
  /// Creates a mute setting.
  const MuteSetting({this.until, this.indefinite = false});

  /// Reads the JSON form.
  factory MuteSetting.fromJson(Object? raw) {
    final map = Json.map(raw);
    return MuteSetting(
      until: Json.utcDate(map['until']),
      indefinite: Json.boolean(map['indefinite'], fallback: false),
    );
  }

  /// Not muted.
  static const none = MuteSetting();

  /// Muted until this instant (UTC), if set.
  final DateTime? until;

  /// Muted until the user turns it off.
  final bool indefinite;

  /// Whether the azan is muted at [now].
  bool isActiveAt(DateTime now) =>
      indefinite || (until != null && now.isBefore(until!));

  @override
  Map<String, Object?> toJson() => {
    'until': until?.toUtc().toIso8601String(),
    'indefinite': indefinite,
  };
}

/// Azan settings.
class AzanSettings extends JsonValue {
  /// Creates the settings.
  const AzanSettings({
    this.enabled = true,
    this.masterVolume = 0.6,
    this.fadeIn = true,
    this.perPrayer = defaultPerPrayer,
    this.mute = MuteSetting.none,
  });

  /// Reads the JSON form.
  factory AzanSettings.fromJson(Object? raw) {
    final map = Json.map(raw);
    final perPrayer = Json.map(map['perPrayer']);
    return AzanSettings(
      enabled: Json.boolean(map['enabled'], fallback: true),
      masterVolume: Json.number(map['masterVolume'], 0.6).clamp(0, 1),
      fadeIn: Json.boolean(map['fadeIn'], fallback: true),
      perPrayer: {
        for (final prayer in azanPrayers)
          prayer: PrayerAzan.fromJson(
            perPrayer[prayer.name],
            enabledByDefault: defaultPerPrayer[prayer]!.enabled,
          ),
      },
      mute: MuteSetting.fromJson(map['mute']),
    );
  }

  /// The five prayers that can have an azan.
  static final List<Prayer> azanPrayers = Prayer.values
      .where((p) => p.hasAzan)
      .toList(growable: false);

  /// Defaults: on for Fajr, Dhuhr and Maghrib, off for Asr and Isha.
  static const Map<Prayer, PrayerAzan> defaultPerPrayer = {
    Prayer.fajr: PrayerAzan(enabled: true),
    Prayer.dhuhr: PrayerAzan(enabled: true),
    Prayer.asr: PrayerAzan(),
    Prayer.maghrib: PrayerAzan(enabled: true),
    Prayer.isha: PrayerAzan(),
  };

  /// Master switch.
  final bool enabled;

  /// Master volume, 0 to 1.
  final double masterVolume;

  /// Fade the azan in over two seconds.
  final bool fadeIn;

  /// Per-prayer settings (all five prayers present).
  final Map<Prayer, PrayerAzan> perPrayer;

  /// Quick mute.
  final MuteSetting mute;

  /// The set of prayers whose azan is switched on (ignores mute).
  Set<Prayer> get enabledPrayers => {
    if (enabled)
      for (final entry in perPrayer.entries)
        if (entry.value.enabled) entry.key,
  };

  /// Copy with changes.
  AzanSettings copyWith({
    bool? enabled,
    double? masterVolume,
    bool? fadeIn,
    Map<Prayer, PrayerAzan>? perPrayer,
    MuteSetting? mute,
  }) => AzanSettings(
    enabled: enabled ?? this.enabled,
    masterVolume: masterVolume ?? this.masterVolume,
    fadeIn: fadeIn ?? this.fadeIn,
    perPrayer: perPrayer ?? this.perPrayer,
    mute: mute ?? this.mute,
  );

  @override
  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'masterVolume': masterVolume,
    'fadeIn': fadeIn,
    'perPrayer': {
      for (final entry in perPrayer.entries)
        entry.key.name: entry.value.toJson(),
    },
    'mute': mute.toJson(),
  };
}

/// Reminder settings.
class ReminderSettings extends JsonValue {
  /// Creates the settings.
  const ReminderSettings({
    this.minutesBefore = defaultMinutes,
    this.chime = true,
  });

  /// Reads the JSON form.
  factory ReminderSettings.fromJson(Object? raw) {
    final map = Json.map(raw);
    final perPrayer = Json.map(map['perPrayer']);
    return ReminderSettings(
      minutesBefore: {
        for (final prayer in AzanSettings.azanPrayers)
          prayer: Json.integer(
            perPrayer[prayer.name],
            defaultMinutes[prayer]!,
          ).clamp(0, maxMinutes),
      },
      chime: Json.boolean(map['chime'], fallback: true),
    );
  }

  /// Largest lead time.
  static const maxMinutes = 60;

  /// Defaults: 10 minutes for the prayers that have an azan by default.
  static const Map<Prayer, int> defaultMinutes = {
    Prayer.fajr: 10,
    Prayer.dhuhr: 10,
    Prayer.asr: 0,
    Prayer.maghrib: 10,
    Prayer.isha: 0,
  };

  /// Lead time per prayer in minutes; 0 means no reminder.
  final Map<Prayer, int> minutesBefore;

  /// Play a soft chime with the reminder.
  final bool chime;

  /// Copy with changes.
  ReminderSettings copyWith({Map<Prayer, int>? minutesBefore, bool? chime}) =>
      ReminderSettings(
        minutesBefore: minutesBefore ?? this.minutesBefore,
        chime: chime ?? this.chime,
      );

  @override
  Map<String, Object?> toJson() => {
    'perPrayer': {
      for (final entry in minutesBefore.entries) entry.key.name: entry.value,
    },
    'chime': chime,
  };
}

/// Window and startup behaviour.
class WindowSettings extends JsonValue {
  /// Creates the settings.
  const WindowSettings({
    this.closeToTray = true,
    this.startMinimized = true,
    this.launchAtStartup = false,
  });

  /// Reads the JSON form.
  factory WindowSettings.fromJson(Object? raw) {
    final map = Json.map(raw);
    return WindowSettings(
      closeToTray: Json.boolean(map['closeToTray'], fallback: true),
      startMinimized: Json.boolean(map['startMinimized'], fallback: true),
      launchAtStartup: Json.boolean(map['launchAtStartup'], fallback: false),
    );
  }

  /// Closing the window hides it to the tray.
  final bool closeToTray;

  /// When started by Windows, stay hidden in the tray.
  final bool startMinimized;

  /// Start with Windows.
  final bool launchAtStartup;

  /// Copy with changes.
  WindowSettings copyWith({
    bool? closeToTray,
    bool? startMinimized,
    bool? launchAtStartup,
  }) => WindowSettings(
    closeToTray: closeToTray ?? this.closeToTray,
    startMinimized: startMinimized ?? this.startMinimized,
    launchAtStartup: launchAtStartup ?? this.launchAtStartup,
  );

  @override
  Map<String, Object?> toJson() => {
    'closeToTray': closeToTray,
    'startMinimized': startMinimized,
    'launchAtStartup': launchAtStartup,
  };
}

/// Optional network clock check.
class NetworkTimeSettings extends JsonValue {
  /// Creates the settings.
  const NetworkTimeSettings({
    this.enabled = false,
    this.host = 'pool.ntp.org',
    this.applyCorrection = false,
  });

  /// Reads the JSON form.
  factory NetworkTimeSettings.fromJson(Object? raw) {
    final map = Json.map(raw);
    final host = Json.string(map['host'], 'pool.ntp.org').trim();
    return NetworkTimeSettings(
      enabled: Json.boolean(map['enabled'], fallback: false),
      host: host.isEmpty ? 'pool.ntp.org' : host,
      applyCorrection: Json.boolean(map['applyCorrection'], fallback: false),
    );
  }

  /// Check the clock against NTP.
  final bool enabled;

  /// NTP server host name.
  final String host;

  /// Use the measured offset inside the app (never changes Windows).
  final bool applyCorrection;

  /// Copy with changes.
  NetworkTimeSettings copyWith({
    bool? enabled,
    String? host,
    bool? applyCorrection,
  }) => NetworkTimeSettings(
    enabled: enabled ?? this.enabled,
    host: host ?? this.host,
    applyCorrection: applyCorrection ?? this.applyCorrection,
  );

  @override
  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'host': host,
    'applyCorrection': applyCorrection,
  };
}

/// All user settings. The only writer is `SettingsController`.
class AppSettings extends JsonValue {
  /// Creates settings; prefer [AppSettings.defaults] and [copyWith].
  const AppSettings({
    this.language = AppLanguage.fa,
    this.theme = ThemeSetting.system,
    this.digits = DigitStyle.persian,
    this.hourFormat = HourFormat.h24,
    this.activeLocationId = defaultLocationId,
    this.locations = const [defaultLocation],
    this.calculation = const CalculationSettings(),
    this.display = const DisplaySettings(),
    this.azan = const AzanSettings(),
    this.reminders = const ReminderSettings(),
    this.hijriAdjustmentDays = 0,
    this.window = const WindowSettings(),
    this.networkTime = const NetworkTimeSettings(),
    this.wakeAlarms = const [],
    this.onboardingCompleted = false,
  });

  /// The factory defaults: Persian, Tehran, Tehran method.
  const AppSettings.defaults() : this();

  /// Reads the JSON form leniently; a broken part falls back to defaults.
  factory AppSettings.fromJson(Object? raw) {
    final map = Json.map(raw);
    final locations = <SavedLocation>[];
    for (final entry in Json.list(map['locations'])) {
      final location = SavedLocation.fromJson(entry);
      if (location != null && locations.every((l) => l.id != location.id)) {
        locations.add(location);
      }
    }
    if (locations.isEmpty) locations.add(defaultLocation);
    var active = Json.string(map['activeLocationId'], locations.first.id);
    if (locations.every((l) => l.id != active)) active = locations.first.id;

    final alarms = <WakeAlarm>[];
    for (final entry in Json.list(map['wakeAlarms'])) {
      final alarm = WakeAlarm.fromJson(entry);
      if (alarm != null && alarms.every((a) => a.id != alarm.id)) {
        alarms.add(alarm);
      }
    }

    return AppSettings(
      language: Json.enumValue(
        AppLanguage.values,
        map['locale'],
        AppLanguage.fa,
      ),
      theme: Json.enumValue(
        ThemeSetting.values,
        map['theme'],
        ThemeSetting.system,
      ),
      digits: Json.enumValue(
        DigitStyle.values,
        map['digits'],
        DigitStyle.persian,
      ),
      hourFormat: Json.enumValue(
        HourFormat.values,
        map['hourFormat'],
        HourFormat.h24,
      ),
      activeLocationId: active,
      locations: locations,
      calculation: CalculationSettings.fromJson(map['calculation']),
      display: DisplaySettings.fromJson(map['display']),
      azan: AzanSettings.fromJson(map['azan']),
      reminders: ReminderSettings.fromJson(map['reminders']),
      hijriAdjustmentDays: Json.integer(
        map['hijriAdjustmentDays'],
        0,
      ).clamp(-maxHijriAdjustment, maxHijriAdjustment),
      window: WindowSettings.fromJson(map['window']),
      networkTime: NetworkTimeSettings.fromJson(map['networkTime']),
      wakeAlarms: alarms,
      onboardingCompleted: Json.boolean(
        map['onboardingCompleted'],
        fallback: false,
      ),
    );
  }

  /// Largest Hijri date adjustment in either direction.
  static const maxHijriAdjustment = 2;

  /// Id of the default location (Tehran).
  static const defaultLocationId = 'city:1';

  /// Tehran from the built-in database, automatic time zone.
  static const defaultLocation = SavedLocation.builtin(
    id: defaultLocationId,
    cityId: 1,
  );

  /// UI language.
  final AppLanguage language;

  /// Theme choice.
  final ThemeSetting theme;

  /// Digit style.
  final DigitStyle digits;

  /// 12 or 24 hour clock.
  final HourFormat hourFormat;

  /// Id of the active saved location.
  final String activeLocationId;

  /// Saved locations (never empty).
  final List<SavedLocation> locations;

  /// Method, angles, offsets.
  final CalculationSettings calculation;

  /// Visible rows.
  final DisplaySettings display;

  /// Azan.
  final AzanSettings azan;

  /// Reminders.
  final ReminderSettings reminders;

  /// Hijri date adjustment in days, -2 to +2.
  final int hijriAdjustmentDays;

  /// Window and startup.
  final WindowSettings window;

  /// Network time check.
  final NetworkTimeSettings networkTime;

  /// Wake-up alarms.
  final List<WakeAlarm> wakeAlarms;

  /// Whether the first-run flow has been finished.
  final bool onboardingCompleted;

  /// The active saved location.
  SavedLocation get activeLocation =>
      locations.firstWhere((l) => l.id == activeLocationId);

  /// Copy with changes.
  AppSettings copyWith({
    AppLanguage? language,
    ThemeSetting? theme,
    DigitStyle? digits,
    HourFormat? hourFormat,
    String? activeLocationId,
    List<SavedLocation>? locations,
    CalculationSettings? calculation,
    DisplaySettings? display,
    AzanSettings? azan,
    ReminderSettings? reminders,
    int? hijriAdjustmentDays,
    WindowSettings? window,
    NetworkTimeSettings? networkTime,
    List<WakeAlarm>? wakeAlarms,
    bool? onboardingCompleted,
  }) => AppSettings(
    language: language ?? this.language,
    theme: theme ?? this.theme,
    digits: digits ?? this.digits,
    hourFormat: hourFormat ?? this.hourFormat,
    activeLocationId: activeLocationId ?? this.activeLocationId,
    locations: locations ?? this.locations,
    calculation: calculation ?? this.calculation,
    display: display ?? this.display,
    azan: azan ?? this.azan,
    reminders: reminders ?? this.reminders,
    hijriAdjustmentDays: hijriAdjustmentDays ?? this.hijriAdjustmentDays,
    window: window ?? this.window,
    networkTime: networkTime ?? this.networkTime,
    wakeAlarms: wakeAlarms ?? this.wakeAlarms,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
  );

  @override
  Map<String, Object?> toJson() => {
    'schemaVersion': settingsSchemaVersion,
    'locale': language.name,
    'theme': theme.name,
    'digits': digits.name,
    'hourFormat': hourFormat.name,
    'activeLocationId': activeLocationId,
    'locations': [for (final l in locations) l.toJson()],
    'calculation': calculation.toJson(),
    'display': display.toJson(),
    'azan': azan.toJson(),
    'reminders': reminders.toJson(),
    'hijriAdjustmentDays': hijriAdjustmentDays,
    'window': window.toJson(),
    'networkTime': networkTime.toJson(),
    'wakeAlarms': [for (final a in wakeAlarms) a.toJson()],
    'onboardingCompleted': onboardingCompleted,
  };
}
