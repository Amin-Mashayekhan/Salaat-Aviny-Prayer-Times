# Working agreement

For anyone who changes this repository: contributors and AI coding assistants (Claude Code reads this
file automatically). It is short on purpose. Read it, then read the documents it points to.

## What this is

**Salaat | Aviny Prayer Times**: a Windows desktop app (Flutter/Dart) that shows prayer times, plays the
azan from the system tray, has a qibla compass and map, calendar tools and wake-up alarms. Offline first,
no account, no ads, no tracking. Eight languages (fa is the template, then en, ar, tr, ur, az, id, fr).
Persian, Arabic and Urdu are right-to-left.

Where things are written down:

- [README.md](README.md): what the app does, how to build it.
- [CONTRIBUTING.md](CONTRIBUTING.md): setup, checks, translations, pull requests.
- [docs/architecture.md](docs/architecture.md): packages, state, platform services, start-up, storage.
- [docs/prayer-times.md](docs/prayer-times.md): time handling, the calculation, the schedule engine.
- [docs/product.md](docs/product.md): what the product does and its principles.
- [docs/ui-guidelines.md](docs/ui-guidelines.md): the UI/UX rules every screen must follow.
- [docs/adr/](docs/adr/README.md): the design decisions and why they were taken.
- [PROGRESS.md](PROGRESS.md): status, what is verified on real hardware, open decisions, next steps.
- [docs/manual-test-checklist.md](docs/manual-test-checklist.md) and
  [docs/manual-test-checklist-wake.md](docs/manual-test-checklist-wake.md): what only a real PC can check.

## Repository layout

| Path | Contents |
|---|---|
| `packages/prayer_core` | Pure Dart: calculator, qibla maths, schedule builder, catch-up policy. No Flutter, no I/O, no clock. |
| `packages/owghat_lib` | Everything testable: UI, state, settings, scheduling engine, localisation, platform *interfaces* with fakes. Must not depend on a plugin that has a native build hook. |
| `app` | The thin Windows runner: `main.dart`, plugin-based implementations in `lib/src/platform`, native code in `windows/`, the installer script, fonts, audio, icons. **No automated tests.** |
| `seed/` | `golden/prayer_times_golden.json` (300 reference vectors) and the source city data. |
| `tools/` | Asset and icon generators, `arb_merge.py`, the Python reference implementation of the calculation. |

The root `pubspec.yaml` is a pub workspace; run `flutter pub get` once at the root.

## Build, test, format, analyze

From the repository root unless noted (CI runs the same on Windows):

```
dart format --output=none --set-exit-if-changed .     # use `dart format .` to fix
flutter analyze                                       # must report no issues
dart test                       # in packages/prayer_core
flutter test                    # in packages/owghat_lib (run it inside the package: tests read assets by relative path)
flutter analyze                 # in app (there are no tests there)
cd app && flutter run -d windows        # or: flutter build windows --release
```

Library tests need no Visual Studio. Building or running the app needs Flutter 3.47.x with Windows
desktop support and Visual Studio with "Desktop development with C++". Widget tests render with the test
font, not Vazirmatn, so they prove layout and logic, not how the real font looks.

Reference tools (run them only when the owner asks; they rewrite checked-in data):

```
python -I tools/reference/prayer_times_reference.py show 2026-11-11 35.6892 51.3890 210 tehran
python -I tools/reference/prayer_times_reference.py generate seed/golden/prayer_times_golden.json
python -I tools/build_assets.py            # seed/locations -> packages/owghat_lib/assets/data
```

Seeing the real app: run the release build with `--page <home|timetable|calendar|qibla|wakeup|settings>`
to open on a screen (the script `tools/take_screenshots.ps1` that retakes the download-page screenshots does this against a
temporary copy of `%APPDATA%\Salaat\Salaat\settings.json`; back the user's file up first and restore it).
Releases: `.github/workflows/release.yml` builds the installer and zip for a `vX.Y.Z` tag (the tag must
equal `version:` in `app/pubspec.yaml`) and fills a draft release from `CHANGELOG.md`; `pages.yml`
publishes `site/` (Persian, English, Arabic). Update `CHANGELOG.md` with every user-visible change.

Before you finish a change: format, analyze, run both test suites, add or update tests in the same
commit, and update [PROGRESS.md](PROGRESS.md) when the status or a known limitation changes. Commit
messages follow Conventional Commits (`feat(scheduler): ...`, `fix(qibla): ...`). If a test fails, the
code is wrong, not the test.

## Rules that must never be broken

1. **No daylight-saving logic of our own.** No switch, table, date range or "+1 hour" in code, data or
   UI. UTC offsets come only from `ZoneOffsetResolver` (the bundled IANA database, or the fixed offset
   the user typed). This is the bug the whole rewrite exists to fix; see
   [docs/prayer-times.md](docs/prayer-times.md).
2. **Code never changes a setting the user did not just change.** Only `SettingsController` methods,
   called from a user action, write settings. Opening a screen, recalculating, a date rollover or a timer
   firing only read them. (The two existing background effects carry out the user's own choice: a
   one-time wake-up alarm switches itself off after it rings, and a timed mute expires by being compared
   with the clock, never rewritten.)
3. **Never edit `seed/golden/prayer_times_golden.json`**, and never weaken the golden test
   (`packages/prayer_core/test/golden_test.dart`), the Iran no-DST test
   (`packages/owghat_lib/test/core/time/iran_has_no_dst_test.dart`) or the settings-never-rewritten test
   (`packages/owghat_lib/test/features/settings/settings_never_rewritten_test.dart`).
4. **No `DateTime.now()`**; use the injected `Clock` (`clockProvider`). The only exceptions carry an
   `// allow-now` marker and CI fails on any other occurrence. No new `Timer` outside `core/time`, the
   clock providers and the scheduler: other code reacts to the providers they publish.
5. **`packages/prayer_core` stays pure**: no Flutter, no plugins, no I/O, no clock, no globals, no
   mutable static state.
6. **Layering.** Widgets hold no business logic: they watch providers and call notifier methods. Inside
   a feature, `domain` is pure, `application` holds the providers, `data` touches files, processes and
   assets, `presentation` holds widgets. `prayer_core` never imports `owghat_lib`; `owghat_lib` never
   imports `app`; no plugin type appears in `owghat_lib`.
7. **Prayer identity is the `Prayer` enum.** Never compare or branch on a display string.
8. **Background events never open a modal dialog** and never throw into the schedule engine. Failures
   are logged and shown as non-modal notices.
9. **No user-visible string outside the ARB files**, and a new string is added to **all eight** ARB
   files in the same change (`packages/owghat_lib/lib/l10n/`: `app_fa.arb` is the template, then
   `app_en`, `app_ar`, `app_tr`, `app_ur`, `app_az`, `app_id`, `app_fr`). The validation test
   `packages/owghat_lib/test/l10n/arb_consistency_test.dart` fails when a file misses a message or
   changes a placeholder or select option.
10. **Never** set the Windows clock, change power settings (the app may only read them and open the
    Windows Power Options page), or register anything that needs administrator rights. **The network is
    used for exactly four things, and nothing else:**
    1. the optional NTP clock check (off by default; the server name is editable);
    2. map tiles, only after the user has switched the qibla map on: OpenStreetMap street tiles, or Esri
       World Imagery for the satellite style, with a small bounded disk cache (16 MB);
    3. place search: a Nominatim name search plus an Open-Meteo lookup of the time zone and height, only
       when the user presses Search (never while typing, never in the background);
    4. opening web and mail links through `LinkOpener` (`https` and `mailto` only).

    The device position is read once, on request, and is never stored or logged. Every network use is
    announced in plain words before anything is sent. A new network call needs the owner's decision and
    a new decision record in `docs/adr/`.
11. Do not copy code from the legacy program or from LGPL sources. The calculation is ported only from
    `tools/reference/prayer_times_reference.py`.
12. Do not ship audio of unknown licence. The bundled sounds are generated placeholders
    (`tools/make_placeholder_audio.py`); users choose their own azan file.

## Platforms

`app/lib/main.dart` calls `runOnPlatform` from `src/platform/entry.dart`, a conditional export: the
browser build gets `entry_web.dart` (no `dart:io`, no Win32/FFI), everything else `entry_native.dart`,
which picks Windows (`windows_platform_services.dart`, wake timers through Win32), phones
(`mobile/mobile_platform_services.dart`, Android and iOS) or Linux/macOS
(`desktop/desktop_platform_services.dart`). On the web the settings live in `localStorage`
(`web/browser_json_store.dart` through `PlatformServices.storeFor`) and place search uses
`package:http`. Never import `dart:ffi` or Win32 code from anything the web entry can reach. `PlatformCapabilities` says
what exists (tray, autostart, wake timers, OS-scheduled notices); screens hide what does not exist, and
`visibleDestinationsProvider` drops the Wake-up screen. On phones the system schedules the azan
(`NoticePlanner` hands ten days of `PlannedNotice`s to `NoticeScheduler`), and the in-app dispatcher
does not sound them, so nothing plays twice. Every screen is tested at 390 and 360 px wide with the
phone capabilities in all languages (`test/app/all_languages_test.dart`).

Android tooling on the development PC: JDK 17 at `E:\Ermile\tools\jdk-17`, SDK at
`E:\Ermile\tools\android-sdk` (platforms 36 and 37, NDK 28.2; `flutter_local_notifications` needs
compileSdk 37 and core-library desugaring), emulator AVD `salaat_phone` in `E:\Ermile\tools\android-avd`.

## Pitfalls that cost time

- **Translations.** Edit the messages in the ARB files, then run `flutter gen-l10n` inside
  `packages/owghat_lib`; the generated Dart in `lib/l10n/gen/` is committed. `tools/arb_merge.py`
  (`python -I tools/arb_merge.py snippet.json`, with a snippet like `{"key": ["persian", "english"]}` or
  `{"key": {"fa": "...", "en": "...", "ph": ["name"]}}`) merges into `app_fa.arb` and `app_en.arb`
  **only** and re-sorts those two files. The other six languages must be edited directly or with your
  own script. Keep `{placeholders}` and select option names identical in every language.
- **Adding a language:** a value in the `AppLanguage` enum
  (`features/settings/domain/app_settings.dart`: native name, direction, default digits), a new
  `app_<code>.arb`, then `flutter gen-l10n`. City names exist only in Persian and English, so other
  languages show the English city name.
- **Platform services pattern.** An OS capability is an interface in
  `packages/owghat_lib/lib/src/core/platform/` with an in-memory fake in `fakes/`; its Windows
  implementation lives in `app/lib/src/platform/`. The runner builds a `PlatformServices` bundle
  (`createWindowsPlatformServices`) and passes it to `bootstrap`, which overrides the matching providers
  from `platform_providers.dart` (their defaults are the fakes, so widget tests need no set-up). A new
  service means: interface, fake, a field in `PlatformServices` (and its `fake()` factory), a provider,
  the override in `prepareApp`, the Windows class. The wake-up services are the exception: the runner
  hands them to `bootstrap` as `extraOverrides`.
- **Riverpod timing.** A derived provider read inside a listener callback can still be stale. The
  schedule engine and the wake-up controller therefore react to root sources and read derived values one
  microtask later; keep that when you touch them.
- **Plugins with a native build hook** (`window_manager` and `tray_manager` pull in `nativeapi`, which
  compiles C++) may only be used in `app/`; otherwise `flutter test` in the library would need Visual
  Studio. Build notes recorded from earlier Windows builds: the `audioplayers_windows` plugin fetches WIL
  through NuGet, so a NuGet source (nuget.org) must be configured; `flutter_local_notifications_windows`
  needs the ATL component; after a failed configure step, or after renaming `BINARY_NAME` in
  `app/windows/CMakeLists.txt`, delete `app/build/windows/x64/CMakeCache.txt` (it keeps a stale install
  prefix).
- **`app/` has no automated tests.** Check it with `flutter analyze` and the manual checklists, and keep
  logic out of it: put logic in `owghat_lib` behind an interface so it can be tested.
- **Tray, toasts, sound, autostart, single instance and wake-up alarms are not yet verified on real
  hardware** ([PROGRESS.md](PROGRESS.md)). Say so when you change them; do not claim they work.
- Line endings are LF (`.gitattributes`). Python tools are run with `python -I`.
