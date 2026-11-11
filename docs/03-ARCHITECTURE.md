# 03 — Architecture

## 1. Stack

Versions below were checked on pub.dev / the Flutter release index on 2026-11-11. **Do not type
version numbers by hand.** Add packages with `flutter pub add <name>` (or `dart pub add` in the
pure-Dart package) so the resolver picks compatible versions, then commit `pubspec.lock`.

| Concern | Choice | Known-good on 2026-11-11 | Notes |
|---|---|---|---|
| SDK | Flutter stable | 3.47.x (Dart 3.13.x) | Minimum for the packages below. Pin with `.fvmrc` or document the exact version in `README`. |
| Prayer math | **In-house**, `packages/prayer_core` | — | Port of `tools/reference/prayer_times_reference.py`. `adhan_dart` was evaluated and rejected: its midnight is Maghrib→Fajr, not sunset→Fajr, and it applies the Maghrib angle conditionally. |
| State and DI | `flutter_riverpod` | 3.5.0 | `Notifier` / `AsyncNotifier` classes, written by hand (no `riverpod_generator`). Do not use the `legacy.dart` providers. |
| Models | `freezed` + `json_serializable` (+ `build_runner`) | 4.0.3 / 6.15.2 | For settings, locations, alarms. `prayer_core` uses plain immutable classes and has no code generation. |
| Lints | `very_good_analysis` | 11.0.0 | Zero analyzer warnings is a merge requirement. |
| Settings storage | One versioned JSON file via `path_provider` | — | See §5. Not `shared_preferences`: settings are nested and must be written atomically. |
| City data | Bundled JSON asset, loaded once, held in memory | — | 567 rows. Behind `LocationRepository`, so P1 (25k world cities) can switch to SQLite (`drift`) without touching callers. |
| Window | `window_manager` | 0.6.0 | Hide to tray, size, min size, show/focus. |
| Tray | `tray_manager` | 0.8.3 | |
| Single instance | `windows_single_instance` | 1.2.0 | |
| Autostart | `launch_at_startup` | 0.5.1 | Registry `Run` key with `--minimized`. |
| Notifications | `flutter_local_notifications` | 23.0.1 | Windows toasts. Only **immediate** notifications: on an unpackaged app `cancel` does not work and OS-side scheduling is undocumented, so our own engine does the timing. |
| Audio | `audioplayers` | 6.8.1 | First-party Windows backend; assets, file paths, volume. |
| Time zones | `timezone` | 0.11.2 (tzdb 2026e) | The only source of UTC offsets in automatic mode. |
| Network time | `ntp_dart` | 1.5.2 | Behind `NetworkTimeSource`; if it proves unsuitable, replace with a 60-line SNTP client on `RawDatagramSocket`. |
| Jalali | `shamsi_date` | 1.1.1 | |
| Hijri | `hijri` | 3.0.1 | Umm al-Qura; Persian month names are ours. |
| Win32 calls | `win32` + `ffi` | 6.4.0 / 2.2.0 | `SetWaitableTimer`, `CreateWaitableTimer`, `SetSuspendState` are not in `win32`; bind them by hand with `dart:ffi`. |
| Localisation | `flutter_localizations` + `intl`, ARB files, `flutter gen-l10n` | — | `fa` (default) and `en`. |
| Clock injection | `clock` | — | `clock.now()` everywhere; never `DateTime.now()`. |
| Logging | `logging` | — | Rotating file in the app-support directory, 1 MB × 3. |
| Tests | `flutter_test`, `mocktail`, `fake_async` | mocktail 1.0.5 | |
| Font | Vazirmatn (OFL-1.1), bundled | v33.003 | Persian and Latin. Include the licence file. |
| Installer | Inno Setup | 7.1.x | Per-user install, no admin. MSIX is not used (tray + autostart + wake are simpler unpackaged). |
| Routing | None | — | One window with a navigation rail; destinations are an enum in a provider. Dialogs and sub-pages use `Navigator`. Add `go_router` only if deep links become a need. |

Not used, with reasons: `system_tray`, `local_notifier`, `flutter_acrylic`, `isar` (stale or
abandoned); `just_audio` (no first-party Windows backend); `sqlite3_flutter_libs` (end of life).

## 2. Repository layout

A pub workspace (root `pubspec.yaml` with `workspace:`) holding one app and one pure-Dart package.

```
/
├─ pubspec.yaml                  workspace root
├─ analysis_options.yaml         very_good_analysis + project rules
├─ CLAUDE.md  README.md  PROGRESS.md
├─ docs/                         these documents (+ docs/adr/ for decisions made later)
├─ seed/                         source data and golden vectors (inputs, not shipped as-is)
├─ tools/                        Python reference + data scripts
├─ packages/
│  └─ prayer_core/               PURE DART. No Flutter, no I/O, no clock, no plugins.
│     ├─ lib/
│     │  ├─ prayer_core.dart                 public exports
│     │  └─ src/
│     │     ├─ astronomy/        julian_day.dart, solar_position.dart, trig.dart
│     │     ├─ calculation/      prayer.dart (enum), calculation_method.dart, calculation_params.dart,
│     │     │                    prayer_calculator.dart, prayer_times.dart, adjustments.dart
│     │     ├─ qibla/            qibla.dart, sun_on_qibla.dart
│     │     └─ schedule/         scheduled_event.dart, schedule_builder.dart, catch_up_policy.dart
│     └─ test/                   golden_test.dart (reads ../../seed/golden), unit tests per file
└─ app/                          the Flutter application
   ├─ pubspec.yaml
   ├─ assets/  data/ (cities, provinces, countries)  audio/  fonts/  icons/
   ├─ lib/
   │  ├─ main.dart               bootstrap only
   │  ├─ l10n/                   app_fa.arb, app_en.arb
   │  └─ src/
   │     ├─ app/                 app.dart, theme/, shell/ (window shell, nav rail), bootstrap.dart
   │     ├─ core/
   │     │  ├─ time/             clock_provider.dart, zone_offset_resolver.dart, network_time/…
   │     │  ├─ platform/         INTERFACES + implementations (see §4)
   │     │  ├─ storage/          json_store.dart (atomic file), migrations.dart
   │     │  ├─ logging/  errors/  utils/ (persian_digits.dart, text_normalizer.dart)
   │     │  └─ widgets/          shared UI atoms
   │     └─ features/
   │        ├─ settings/         domain (AppSettings…), data (SettingsRepository), application (SettingsController), presentation
   │        ├─ locations/        domain, data (LocationRepository, asset loader, search), application, presentation
   │        ├─ prayer_times/     application (todayTimesProvider, nextPrayerProvider…), presentation (home, timetable)
   │        ├─ scheduler/        application (ScheduleEngine, EventDispatcher), data (HandledEventsStore)
   │        ├─ azan/             application (AzanPlayer, MuteController), presentation (now-playing bar, sound picker)
   │        ├─ reminders/        application (ReminderNotifier)
   │        ├─ calendar/         domain (TriDate), application, presentation (date header, converter)
   │        ├─ qibla/            application, presentation
   │        ├─ wake_alarm/       domain, application (WakeAlarmController), presentation
   │        ├─ tray/             application (TrayController)
   │        ├─ onboarding/       presentation
   │        └─ diagnostics/      application, presentation
   ├─ test/                      mirrors lib/src
   ├─ integration_test/
   └─ windows/                   runner + installer/ (Inno Setup script)
```

## 3. Layering rules

Inside a feature: `presentation → application → domain ← data`.

1. **`prayer_core` depends on nothing** except the Dart SDK (and `meta`). It never reads a clock, a
   file, a setting or a time zone. Everything is passed in.
2. **`domain`** = immutable models and pure functions. No Flutter imports, no plugins.
3. **`data`** = repositories and platform adapters. The only layer that touches files, assets,
   plugins, FFI or the network.
4. **`application`** = Riverpod notifiers / services that orchestrate domain + data. No widgets.
5. **`presentation`** = widgets. They read providers and call notifier methods. No business logic,
   no direct repository, plugin or `prayer_core` calls.
6. Features may depend on `core/` and on another feature's `domain` and `application` public API
   (exported from `<feature>/<feature>.dart`). Never on another feature's `data` or `presentation`.
7. No plugin type appears outside `core/platform/**/impl` or a feature's `data/`.
8. No `DateTime.now()`, no `Timer` created outside `core/time` and `scheduler` (lint rule + grep check in CI).
9. Prayer identity is the `Prayer` enum everywhere. A display string is never compared.

## 4. Platform interfaces (`app/lib/src/core/platform/`)

Each has an abstract class, a Windows implementation, and a fake for tests. Providers expose the
interface; `bootstrap.dart` overrides them per platform.

| Interface | Methods (essence) | Windows implementation |
|---|---|---|
| `AudioOutput` | `play(SoundRef, {volume, fadeIn})`, `stop()`, `Stream<PlaybackState>`, `Duration? duration` | `audioplayers` |
| `Notifier` | `show(NotificationSpec)` with optional actions (`stop`, `open`), `Stream<NotificationAction>` | `flutter_local_notifications` |
| `TrayHost` | `setIcon`, `setTooltip`, `setMenu(TrayMenu)`, `Stream<TrayEvent>` | `tray_manager` |
| `WindowHost` | `show`, `hide`, `focus`, `isVisible`, `setPreventClose`, `Stream<WindowEvent>` | `window_manager` |
| `AutostartService` | `isEnabled`, `enable`, `disable` | `launch_at_startup` |
| `PowerEvents` | `Stream<PowerEvent>` (`suspending`, `resumed`, `timeChanged`) | `WM_POWERBROADCAST` / `WM_TIMECHANGE` via the runner's message handler + a method channel |
| `WakeTimerService` | `Future<WakeCapability> probe()`, `scheduleWake(DateTime utc, id)`, `cancel(id)`, `keepAwake(Duration)` | See §6 |
| `PowerControl` | `sleep()`, `hibernate()` | `SetSuspendState` via FFI |
| `NetworkTimeSource` | `Future<Duration> measureOffset(String host)` | `ntp_dart` |
| `SystemZone` | `Duration currentLocalOffset()`, `String? zoneId()` | `DateTime.now().timeZoneOffset` + registry / `flutter_timezone` |

## 5. Settings

One file: `<app support dir>/settings.json`.

```json
{ "schemaVersion": 1, "locale": "fa", "theme": "system", "digits": "persian", "hourFormat": "h24",
  "activeLocationId": "city:1",
  "locations": [ { "id": "city:1", "kind": "builtin", "cityId": 1, "offset": { "mode": "automatic" } },
                 { "id": "custom:…", "kind": "custom", "name": "…", "latitude": 0, "longitude": 0,
                   "elevationM": 0, "zoneId": "Asia/Tehran", "offset": { "mode": "fixed", "minutes": 210 } } ],
  "calculation": { "methodId": "tehran", "fajrAngle": 17.7, "maghribAngle": 4.5, "ishaAngle": 14, "ishaMinutes": null,
                   "midnight": "jafari", "asr": "standard", "highLatitude": "nightMiddle", "imsakMinutes": 10,
                   "offsetsMinutes": { "fajr": 0, "…": 0 } },
  "display": { "showImsak": false, "showAsr": true, "showIsha": true, "showSunset": true },
  "azan": { "enabled": true, "masterVolume": 0.6, "fadeIn": true,
            "perPrayer": { "fajr": { "enabled": true, "sound": "asset:azan_default", "volume": 1.0 }, "…": {} },
            "mute": { "until": null } },
  "reminders": { "perPrayer": { "fajr": 10, "dhuhr": 10, "asr": 0, "maghrib": 10, "isha": 0 }, "chime": true },
  "hijriAdjustmentDays": 0,
  "window": { "closeToTray": true, "startMinimized": true, "launchAtStartup": false },
  "networkTime": { "enabled": false, "host": "pool.ntp.org", "applyCorrection": false },
  "wakeAlarms": [] }
```

Rules:

- `AppSettings` is one immutable `freezed` tree. `SettingsController` (a `Notifier<AppSettings>`)
  is the **only** writer. Every mutation is a named method (`setOffsetMode`, `setAzanEnabled`, …).
- Writes are atomic: write `settings.json.tmp`, flush, rename over the original. Debounce 300 ms.
- Load: missing file → defaults. Unparseable file → rename to `settings.corrupt-<timestamp>.json`,
  start from defaults, show a notice. Unknown fields are ignored; missing fields take defaults.
- `schemaVersion` + `migrations.dart` (a list of `Map → Map` steps). A test loads a fixture of
  every past version.
- **Guard for T-5**: a unit test asserts that after `ScheduleEngine.rebuild()`, a date rollover and
  a location reload, the serialised settings are byte-for-byte unchanged.
- A second small file, `state.json`, holds non-user state: handled event ids, window bounds, last
  NTP result. It may be deleted at any time without losing user choices.

## 6. Wake from sleep (the riskiest part — build it as a spike first)

Two mechanisms, both used:

1. **Task Scheduler task with "wake the computer to run this task"**, created per user with
   `schtasks /Create /TN "Owghat\Wake-<id>" /XML <file> /F` from generated task XML
   (`<WakeToRun>true</WakeToRun>`, a one-time `<TimeTrigger>`, `<LogonType>InteractiveToken</LogonType>`,
   `<RunLevel>LeastPrivilege</RunLevel>`, action = our exe with `--wake <id>`). It survives the app
   being closed. The single-instance handler forwards `--wake <id>` to the running app.
2. **In-process waitable timer** (`CreateWaitableTimerW` + `SetWaitableTimer(…, fResume = TRUE)`)
   as a second line while the app is running.

On wake the app calls `SetThreadExecutionState(ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED |
ES_CONTINUOUS)` for the duration of the sound, otherwise Windows goes back to sleep after about two
minutes with the display off; it clears the state afterwards.

`probe()` reports: wake timers allowed on AC / on battery (read with
`powercfg /query SCHEME_CURRENT SUB_SLEEP RTCWAKE`), task creation succeeded, last error. The UI
explains and offers to open the Windows power options. **The app never runs `powercfg -set…`
itself.**

Unverified and therefore the first thing to test on real hardware (M7 spike): per-user task
creation without elevation on a standard account; behaviour on Modern Standby (S0) laptops;
`SetSuspendState` needing the shutdown privilege enabled (`AdjustTokenPrivileges`). Each has a
written fallback in the plan.

## 7. Startup sequence (`bootstrap.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()`; parse args (`--minimized`, `--wake <id>`).
2. Single-instance check; if a second instance, forward args and exit.
3. Init logging; load settings and state; initialise the tz database.
4. Create the `ProviderContainer` with platform overrides.
5. Start `ScheduleEngine` (build events, run catch-up) — **before** any UI.
6. Init tray; show the window unless `--minimized`.

The schedule engine lives in the container, not in a widget, so it keeps running with the window
hidden.

## 8. Errors and logging

- Domain failures are typed results (`sealed class Failure`), not exceptions crossing layers.
- A background failure (audio, notification, wake) is logged, surfaced as a non-modal notice, and
  never stops the engine.
- `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.onError` → log file.
- No personal data in logs; coordinates rounded to 2 decimals.

## 9. Testing strategy

| Level | What | Where |
|---|---|---|
| Golden vectors | 300 vectors, ±1 s, plus qibla bearings | `packages/prayer_core/test/golden_test.dart` |
| Unit | Every pure function; schedule builder; catch-up policy; settings migrations; search normaliser; tri-calendar conversions; Iran no-DST test | next to each unit |
| Engine simulation | `fake_async` + fake `Clock` + fake platform services: 30 simulated days → exactly one azan per enabled prayer per day; sleep/resume gaps; clock jumps of ±1 h; restart mid-day | `app/test/features/scheduler/` |
| Widget | Each screen in `fa` (RTL) and `en`, light and dark, at 800×560 and 1280×800; no overflow | `app/test/features/**/presentation` |
| Integration | App boots, onboarding, change city, preview azan (fake audio), hide to tray | `app/integration_test/` |
| Manual checklist | Real audio, real tray, autostart after reboot, wake from sleep, toast actions | `docs/manual-test-checklist.md` (written in M9) |

Coverage targets: `prayer_core` ≥ 95 % lines; `app` domain + application layers ≥ 80 %.

## 10. Conventions

- Dart 3 features: sealed classes, records, exhaustive `switch`, enhanced enums.
- Files `snake_case.dart`, one public type per file, no `utils.dart` dumping grounds.
- No `!` on nullable values without a comment explaining why it cannot be null; no `dynamic`.
- Public APIs in `prayer_core` have dartdoc with units ("degrees", "minutes east of UTC").
- UI strings only in ARB files. No hard-coded user-visible text, in either language.
- Widgets: small, `const` where possible, no logic in `build`; no widget file over about 250 lines.
- Commits: Conventional Commits (`feat(scheduler): …`), one task per commit, tests in the same commit.
- A decision that changes anything in these documents gets a short ADR in `docs/adr/NNNN-title.md`
  and the document is updated in the same commit.
