# Architecture

Salaat | Aviny Prayer Times is a Windows desktop app written in Flutter. It shows prayer times, plays the
azan on time from the system tray and can wake the PC for an alarm. This document describes how the
code is organised and why. The maths and the scheduling rules are in [prayer-times.md](prayer-times.md).

## Packages

The repository is a pub workspace (`pubspec.yaml` at the root lists the members and holds no code).

| Package | Kind | What it contains |
|---|---|---|
| `packages/prayer_core` | pure Dart | Prayer-time calculator, qibla maths, schedule builder and catch-up policy. Depends only on `meta`. No Flutter, no I/O, no clock, no time zones. |
| `packages/owghat_lib` | Flutter library | Everything else that can be tested without Windows: UI, state, settings, scheduling engine, calendars, localisation, and the *interfaces* to the operating system together with in-memory fakes. |
| `app` | Flutter app | A thin Windows runner: `main.dart`, the plugin-based implementations of the platform interfaces, the native runner under `windows/`, the installer script, fonts, audio and icons. |

Why three packages:

- `prayer_core` is the part that must be exactly right and has the golden test vectors. Keeping it free
  of Flutter and of any notion of "now" or "zone" makes it a pure function that is trivial to test and
  to reason about.
- Several plugins the app needs (`audioplayers`, `tray_manager`, `window_manager`, `geolocator`, ...)
  run native build hooks or need a Windows toolchain. If `owghat_lib` depended on them, its tests
  would only run on a prepared Windows machine. So the library depends on interfaces, and **any
  plugin with a native build hook may only be used in `app/`**. `flutter test` in `owghat_lib` runs
  anywhere Flutter runs.
- `app` stays small enough to be checked by `flutter analyze` and the manual checklists instead of
  automated tests (it has no tests of its own).

Dependencies, from the `pubspec.yaml` files:

- `prayer_core`: `meta`; dev: `test`.
- `owghat_lib`: `flutter_riverpod`, `flutter_localizations` and `intl`, `clock`, `logging`, `timezone`,
  `shamsi_date`, `hijri`, `ntp_dart`, `flutter_map` and `latlong2` (qibla map); dev: `fake_async`,
  `mocktail`.
- `app`: `audioplayers`, `flutter_local_notifications`, `tray_manager`, `window_manager`,
  `windows_single_instance`, `file_selector`, `geolocator`, `path_provider`, `win32` and `ffi`.
- All three use `very_good_analysis`.

Data classes are written by hand (immutable classes with `copyWith`, `fromJson` and `toJson`); there is no
code generation apart from the localisation files.

## Folder layout

```
pubspec.yaml                      workspace root
packages/
  prayer_core/
    lib/src/astronomy/            Julian day, sun position, degree trigonometry
    lib/src/calculation/          Prayer, CalculationMethod, CalculationParams, PrayerCalculator,
                                  CivilDate, PrayerTimes, adjustments (offsets, rounding, UTC instants)
    lib/src/qibla/                bearing, distance, sun direction, sun-on-qibla, great-circle helpers
    lib/src/schedule/             ScheduledEvent, ScheduleBuilder, CatchUpPolicy
    test/                         unit tests and the golden test
  owghat_lib/
    assets/data/                  cities.json (566 Iranian cities), provinces.json (31)
    lib/l10n/                     ARB files; lib/l10n/gen/ holds the generated Dart
    lib/owghat_lib.dart           public API used by the runner
    lib/wake_alarm.dart           public API of the wake-up feature (interfaces to implement)
    lib/src/app/                  OwghatApp, bootstrap, theme, navigation shell
    lib/src/core/                 platform interfaces + fakes, time helpers, storage, logging, formatter
    lib/src/features/<feature>/   see below
    test/                         mirrors lib/src; test/support holds the shared test harness
app/
  lib/main.dart                   builds the Windows services and calls bootstrap
  lib/src/platform/               plugin implementations (+ wake/ for the FFI and Task Scheduler code)
  windows/runner/                 native runner (sends power and clock-change events to Dart)
  windows/installer/salaat.iss    Inno Setup script
  assets/                         audio, icons, Vazirmatn font
seed/golden/                      reference vectors for the calculator
tools/                            asset and icon generators, the Python reference implementation
```

Inside `owghat_lib/lib/src/features/` each feature is a folder with some of `domain/`, `application/`,
`data/` and `presentation/`. The features are: `azan`, `calendar`, `clock`, `diagnostics`, `locations`,
`notifications`, `onboarding`, `places` (online place search), `prayer_times`, `qibla`, `scheduler`,
`settings`, `tray`, `wake_alarm` and `window`.

- `domain`: immutable data classes and pure functions. No widgets, no plugins (a few files import
  `flutter/foundation.dart` for `@immutable`).
- `application`: Riverpod providers and notifiers that combine domain and data. No widgets.
- `data`: file, process and asset access (settings repository, handled-events store, `schtasks` wrapper,
  city database).
- `presentation`: widgets. They watch providers and call notifier methods. A few read a platform
  provider directly (link opener, device location, file dialogs); that is fine because those are
  interfaces.

`prayer_core` never depends on `owghat_lib`; `owghat_lib` never imports from `app`.

## State management

Riverpod 3 (`flutter_riverpod`). Notifiers and providers are written by hand, without
`riverpod_generator`.

- `SettingsController` (a `Notifier<AppSettings>`) is the only writer of user settings. Every change is
  a named method (`setLocationOffset`, `applyMethod`, `setMute`, ...) that validates its input and
  returns a `SettingsFailure` or null. A listener on the notifier hands each new state to
  `SettingsRepository`, which saves it.
- Derived state (the active location, the prayer day of a date, the next prayer, the current time) is
  computed in plain `Provider`s that watch the settings. `nowProvider` ticks once a second while the
  window is visible and once a minute while it is hidden in the tray.
- The schedule engine and the tray, window and wake-up controllers live in the provider container, not in
  widgets, so they keep running while the window is hidden.
- Navigation is one window with a rail. The six destinations are an enum
  (`home`, `timetable`, `calendar`, `qibla`, `wakeUp`, `settings`) held in a provider; dialogs use
  `Navigator`. There is no router package.
- The default value of every platform provider is an in-memory fake, so widget tests can read any
  provider without set-up. `bootstrap` overrides them with the real implementations.

### Rules that keep time handling safe

- Nothing but `SettingsController` methods, called from a user action, may change settings.
  Recalculation, date rollover, location loading and start-up only read them. The two background
  writes that exist are carrying out the user's own choice: a one-time wake-up alarm switches itself off
  after it fires, and a timed mute expires by being evaluated against the clock, not by being rewritten.
  A guard test in `owghat_lib/test/features/settings` simulates a location change, a rebuild and a day
  rollover and asserts that the serialised settings do not change. Do not weaken it.
- The current time comes from the injected `Clock` (`clockProvider`), never from `DateTime.now()`.
  The only allowed readers of the system time are `systemClock` and the file name of a quarantined
  settings file; they carry an `// allow-now` marker, and CI fails if the string `DateTime.now(` appears
  anywhere else in `app/lib`, `owghat_lib/lib` or `prayer_core/lib`.
- All UTC offsets come from `ZoneOffsetResolver`. There is no daylight-saving code in the project (see
  [prayer-times.md](prayer-times.md)).
- Prayer identity is the `Prayer` enum. Display strings are never compared.

## Platform services

`owghat_lib/lib/src/core/platform/` defines one interface per operating-system capability. Each has a fake
in `core/platform/fakes/` and a Windows implementation in `app/lib/src/platform/`.

| Interface | Windows implementation |
|---|---|
| `AudioOutput` (play a `SoundRef` with volume and fade-in, stop, playback state stream) | `audioplayers` |
| `AppNotifier` (show a notification, optional Stop/Open buttons, action stream) | `flutter_local_notifications`; only immediate notifications, the app's own engine does the timing |
| `TrayHost` (icon, tooltip, menu, event stream) | `tray_manager` |
| `WindowHost` (show, hide, focus, bounds, quit, `closeRequested` and `boundsChanged` events) | `window_manager`; the close button does not close the window by itself, `WindowController` decides between hide-to-tray and quit |
| `AutostartService` | `reg.exe` on `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`, value `Salaat` = `"<exe>" --minimized` (no admin rights) |
| `SingleInstance` (second launch forwards its arguments to the first) | `windows_single_instance` over a named pipe |
| `FileDialogs` (sound file, backup save/open) | `file_selector` |
| `PlatformPaths` (support directory, `settings.json`, `state.json`, `logs/`) | `path_provider`; `%APPDATA%\Salaat\Salaat` |
| `PowerEvents` (`suspending`, `resumed`, `timeChanged`) | the native runner watches `WM_POWERBROADCAST`, `WM_TIMECHANGE` and `WM_SETTINGCHANGE` and calls the `owghat/power` method channel |
| `DeviceLocationService` (qibla map, "find my position") | `geolocator` |
| `LinkOpener` (https and mailto links only; `isOpenableLink` is the check) | `ShellLinkOpener`: `rundll32 url.dll,FileProtocolHandler` with the address as one argument |
| `PlaceSearchService` (`search` by name, `details` = time zone and height of a point) | `OnlinePlaceSearch` (Nominatim and Open-Meteo over plain `dart:io` HTTP, `core/platform/http_get.dart`). It needs no plugin, so the class lives in the library (`features/places/data`) and the runner only creates it |
| `WakeTimerService`, `PowerControl` (wake-up feature, see below) | `app/lib/src/platform/wake/` |

`PlatformServices` bundles every row except the last: audio, notifier, window, tray, autostart, file
dialogs, paths, power events, single instance, the asset loader, device location, link opener and place
search. `PlatformServices.fake()` builds the bundle of fakes used by tests. `app/lib/main.dart` builds the
Windows bundle (`createWindowsPlatformServices`), creates the wake-up services and calls
`bootstrap(args, services, extraOverrides: [...])`; the extra overrides are the two wake-up providers.
Providers (`platform_providers.dart`) expose the interfaces and `bootstrap` overrides them. A new
capability is added as: interface, fake, a field in `PlatformServices` and its `fake()` factory, a
provider, the override in `prepareApp`, the Windows class.

Network time (`NetworkTimeSource`, over `ntp_dart`) and the Windows zone view (`SystemZone`) are interfaces
in `core/time` and are plain Dart, so they live in the library.

### Network use

The app talks to the network only for these things, each started by the user and announced first
(see [adr/0006-place-search-and-offline-use.md](adr/0006-place-search-and-offline-use.md)):

1. The optional clock check against an NTP server (`settings.networkTime`, off by default).
2. Map tiles of the qibla map, only after the user switched the map on (`settings.qibla.mapEnabled`):
   OpenStreetMap street tiles or Esri World Imagery for the satellite style, loaded by `flutter_map` with
   a bounded disk cache (`qiblaTileCacheBytes`, 16 MB).
3. Place search: one Nominatim request per press of Search, one Open-Meteo request when a place is chosen
   in onboarding or Settings. The result is saved as a custom location, so the app works offline after it.
4. Opening an `https` or `mailto` link through `LinkOpener`.

The device position (`DeviceLocationService`) is read once, on request, and is never stored or logged.
Tests never touch the network: the fakes and `BlankTileProvider` replace every service above.

## Settings and state storage

Two JSON files in the application-support directory, both written by `JsonFileStore`:

- `settings.json`: everything the user chose (language, theme, digit style, hour format, saved locations,
  calculation method and offsets, which rows are shown, azan and reminder settings, mute, Hijri
  adjustment, window and start-up options, network time, qibla map options, wake-up alarms,
  onboarding flag). It has a `schemaVersion`.
- `state.json`: things the app remembers that are not choices: the handled-event ids of the scheduler,
  window bounds, one-time hints. It can be deleted at any time without losing a user choice.

Behaviour:

- Writes are atomic: temporary file, flush, rename over the target. Settings saves are debounced
  (300 ms), state saves too (500 ms); both are flushed on quit.
- Reading is lenient. A missing file gives defaults; an unparseable file is renamed to
  `<name>.corrupt-<timestamp>.json`, defaults are used and the user is told; unknown fields are ignored and
  missing or out-of-range values fall back to defaults or are clamped.
- Migrations: `SettingsMigrations.steps` is a list of map-to-map upgrades, empty while the layout is still
  version 1. Changing the layout means bumping `settingsSchemaVersion`, appending a step and adding a
  fixture of the old file under `test/fixtures`.
- Backup export and import use the same JSON (`tryImport` requires a `locations` key).
- Built-in locations store only a city id and an offset rule; name and coordinates come from the bundled
  city database. Custom locations store name, coordinates, elevation, an IANA zone id and the offset rule.

## Start-up

`bootstrap()` in `owghat_lib/lib/src/app/bootstrap.dart`:

1. Initialise Flutter bindings and file logging (`salaat.log`, 1 MB per file, two rotated files kept); route
   Flutter and platform errors to the log.
2. Single-instance check. A second copy forwards its arguments (`--minimized`, `--wake <id>`) and exits.
3. `prepareApp()`: load the time-zone database, settings, `state.json` and the city database; build the
   `ProviderContainer` with the platform overrides.
4. Start the schedule engine (build events, run catch-up) before any UI exists.
5. Start the tray, then the window (hidden when `--minimized` was passed and "start minimised" is on), the
   autostart controller and the wake-up controller (which syncs the OS wake requests with the saved
   alarms and learns which alarm woke the PC).
6. `runApp` with the container.

`prepareApp` is `bootstrap` without `runApp`, so tests run it with fake services.

## Scheduling and wake-up

The scheduling engine and its catch-up rules are described in [prayer-times.md](prayer-times.md). The
wake-up feature (`features/wake_alarm`) works like this:

- Alarms are part of the settings. The next occurrence of each alarm is computed from the active location
  (`nextOccurrence`, `buildWakePlan`); alarms relative to a prayer follow the prayer time through the year.
  The schedule engine receives them as `wakeAlarm` events, so they get the same exactly-once and
  catch-up treatment as azans.
- To wake a sleeping PC, the controller asks `WakeTimerService` to wake the machine 30 seconds before the
  alarm. The Windows implementation uses two mechanisms together:
  1. a per-user Task Scheduler task `\Salaat\Wake-<id>` created with `schtasks /Create /XML`, with
     `WakeToRun`, a one-time UTC trigger, `InteractiveToken` and `LeastPrivilege`, and the action
     `salaat.exe --wake <id>`. It survives the app being closed; the single-instance guard forwards
     `--wake <id>` to a running copy;
  2. an in-process waitable timer (`SetWaitableTimer` with `fResume`) on a short-lived isolate, bound by
     hand with `dart:ffi` in `wake_ffi.dart`.
  An alarm is armed with both; it only counts as failed when both fail.
- After a wake the PC is kept awake with `SetThreadExecutionState`, otherwise Windows goes back to sleep
  after about two minutes. When the alarm has an "after sound" action (sleep or hibernate), a cancellable
  30-second countdown is shown first; the PC is never suspended without it. `SetSuspendState` runs on a
  short-lived isolate because it blocks.
- A capability self-test reads the wake-timer policy with `powercfg /query` and whether the PC uses Modern
  Standby. **The app never changes a power setting.** It can only open the Windows Power Options page.
- Uninstalling removes every `\Salaat\Wake-*` task (the installer script does it).

Behaviour on real hardware (standard accounts, Modern Standby laptops, hibernate) is covered by the manual
checklist, not by automated tests.

## Localisation

- Eight languages: `fa` (default), `en`, `ar`, `tr`, `ur`, `az`, `id`, `fr`.
- Messages live in ARB files in `packages/owghat_lib/lib/l10n/` (`app_<code>.arb`). The template is
  `app_fa.arb`; `l10n.yaml` points `flutter gen-l10n` at it and writes the generated Dart to
  `lib/l10n/gen/`, which is committed. Run `flutter gen-l10n` in `packages/owghat_lib` after editing an
  ARB file.
- The `AppLanguage` enum in `settings/domain/app_settings.dart` carries, for each language, its native name
  (never translated, so people can find their language), its text direction and the digit style that goes
  with it by default (Persian digits for Persian and Urdu, Arabic-Indic for Arabic, Latin otherwise). The
  digit style can then be changed on its own in the settings. Adding a language means: add an enum value,
  add `app_<code>.arb`, regenerate.
- `arb_consistency_test.dart` requires every `AppLanguage` to have an ARB file with the same messages,
  placeholders and select options as the template.
- All visible text comes from the ARB files. Numbers, times and durations go through `Formatter`, which
  applies the digit style, decimal separator, 12/24-hour clock and wraps times in a left-to-right isolate so
  they never render reversed inside right-to-left text. The font is Vazirmatn (SIL OFL 1.1), bundled in
  `app/assets/fonts`.
- Calendar month and weekday names come from the ARB files too; the Hijri package supplies none.

## Errors and logging

- Background failures (audio device, missing sound file, notification, wake request) are logged, shown as a
  non-modal notice where useful, and never stop the schedule engine. `ScheduleDispatcher` implementations
  must not throw for ordinary failures.
- A sound that cannot be played falls back to the bundled default azan; if that fails too, the failure is
  reported and the engine continues.
- Errors reaching `FlutterError.onError` or `PlatformDispatcher.onError` go to the log file.

## Testing

Run from the repository root unless noted (this is what CI does on Windows):

```
dart format --output=none --set-exit-if-changed .
flutter analyze
dart test            # in packages/prayer_core
flutter test         # in packages/owghat_lib
flutter build windows --release   # in app
```

| Level | What | Where |
|---|---|---|
| Golden vectors | 300 vectors from the Python reference, every time within 1 s, displayed minute exactly equal; qibla bearings within 0.01 degree | `prayer_core/test/golden_test.dart`, data in `seed/golden/` |
| Unit | Astronomy, adjustments, schedule builder, catch-up policy, geodesy, zone offsets, calendars, settings parsing and migrations, formatter, ARB consistency | next to each area under `test/` |
| No-DST regression | `Asia/Tehran` is exactly UTC+03:30 on every day 2023 to 2040 | `owghat_lib/test/core/time/iran_has_no_dst_test.dart` |
| Engine simulation | `fake_async` with a controllable wall clock and fake platform services: 30 simulated days give exactly one azan per enabled prayer per day; sleep and resume gaps; clock jumps; restart mid-day; cold start | `owghat_lib/test/features/scheduler/`, harness in `test/support/` |
| Widget | Screens with fake services | `owghat_lib/test/features/**` |
| Manual | Real audio, tray, autostart, wake from sleep, toast actions, qibla map | [manual-test-checklist.md](manual-test-checklist.md), [manual-test-checklist-wake.md](manual-test-checklist-wake.md) |

Never edit `seed/golden/prayer_times_golden.json` to make a test pass, and do not weaken the no-DST test or
the settings guard test.

Gotcha: `owghat_lib` tests need no native toolchain, but they do need the assets and ARB files relative to
the package directory, so run `flutter test` inside `packages/owghat_lib`.

## Coding rules

- `very_good_analysis` with `public_member_api_docs`, `lines_longer_than_80_chars` and
  `unnecessary_type_name_in_constructor` switched off. The analyzer must report no issues.
- `dart format` is enforced.
- Dart 3 features are used freely: sealed classes, records, exhaustive `switch`, enhanced enums.
- No `DateTime.now()`; use the injected clock.
- No daylight-saving logic of our own; offsets come from `ZoneOffsetResolver`.
- Only `SettingsController` methods called from user actions write settings.
- No user-visible string outside the ARB files.
- Public APIs in `prayer_core` document their units (degrees, minutes east of UTC, hours).
- Plugins with native build hooks go in `app/`, behind an interface defined in `owghat_lib`.
