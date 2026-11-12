# Progress

Status as of 2026-11-12. Version in `app/pubspec.yaml`: 1.0.0. Nothing is tagged or released yet.

This page says what exists, how far each part has been verified, what is known to be missing and what
the owner still has to decide. Keep it honest: when you change something that is only verified by tests,
do not write that it works on a real PC.

## What exists

- **Prayer times** for nine events (Imsak, Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha, Islamic
  midnight): the Tehran (Institute of Geophysics) and Jafari (Leva, Qom) methods, five international
  methods, custom angles, per-prayer offsets, Asr and high-latitude rules. The calculator is checked
  against 300 reference vectors. UTC offsets come only from the bundled time-zone database or a fixed
  offset; there is no daylight-saving logic of our own ([docs/prayer-times.md](docs/prayer-times.md)).
- **Schedule engine** with exactly-once delivery, catch-up after sleep or clock changes, reminders, mute,
  azan playback with per-prayer sound and volume.
- **Screens:** Home, Timetable, Calendar with converter, Qibla (compass tab and map tab), Wake-up alarms,
  Settings (location, calculation, azan, reminders, time, display, app, about and diagnostics),
  first-run onboarding ([docs/product.md](docs/product.md), [docs/ui-guidelines.md](docs/ui-guidelines.md)).
- **Qibla map** (opt-in): OpenStreetMap street tiles or Esri satellite imagery, the great-circle line and
  arrow to the Kaaba, measuring from the city, the device position (asked on request) or any point
  (tap, coordinates, place search).
- **Places:** the offline list of 566 verified Iranian cities, or an online search of any city (Nominatim
  plus Open-Meteo, saved as a custom location so the app then works offline;
  [docs/adr/0006-place-search-and-offline-use.md](docs/adr/0006-place-search-and-offline-use.md)).
- **Windows integration:** tray icon and menu, toast notifications, close to tray, start with Windows,
  single instance, backup and restore of settings, a rotating log file, About page with developer
  information, support and contribution cards.
- **Wake-up alarms:** a per-user Task Scheduler task plus an in-process timer, a cancellable countdown
  before sleep or hibernate ([docs/adr/0005-wake-timers.md](docs/adr/0005-wake-timers.md)).
- **Eight languages:** fa (template), en, ar, tr, ur, az, id, fr, with right-to-left layout and three
  digit styles.
- **Packaging and release files:** the Inno Setup script `app/windows/installer/salaat.iss`, GitHub
  workflows for CI (`ci.yml`), a draft release on a version tag (`release.yml`: tests, build, bundles the
  Visual C++ runtime DLLs, portable zip, installer, checksums) and the download page (`pages.yml`
  publishing `site/`), `CHANGELOG.md` for the release notes.
- **Download page:** `site/` is a static page in Persian, English and Arabic with per-OS detection,
  install steps, screenshots of the real app (Windows 10) and a FAQ. Its screenshots are retaken by
  running the release build with `--page <name>` (see below) against a temporary settings file.
- **Launch arguments:** `--minimized`, `--wake <id>` and `--page <home|timetable|calendar|qibla|wakeup|settings>`.

## What is verified, and how

| Area | By automated tests | On real hardware |
|---|---|---|
| Calculation, qibla, schedule builder, catch-up policy | Yes (golden vectors, unit tests in `prayer_core`) | n/a |
| Time zones, no-DST guard, settings never rewritten, schedule engine simulations | Yes (`owghat_lib`) | n/a |
| All screens, all eight languages at 1200x800 and 800x560, text scale 2x in the feature tests | Yes (widget tests, test font) | Looked at: the start window and the Persian onboarding. Not looked at with Vazirmatn on every screen |
| Place search, qibla map logic | Yes (fake servers, blank tile provider) | Map overview with real OpenStreetMap tiles and the satellite style (Esri imagery) seen in the release build. Not checked in the app: street-level zoom, a search against the real Nominatim and Open-Meteo servers from inside the app, a real device position (on the development PC Windows answers "permission denied" to desktop apps, which the page explains) |
| Audio | Yes (fake output) | A probe against the real audio plugin reproduced a stale "completed" status bug, which is now fixed. Azan on time through a real day not observed |
| Tray, toasts and their Stop button, close to tray, start minimised | Controllers only (fakes) | **Not verified** |
| Start with Windows (registry value), single instance, power and clock-change events | Controllers only (fakes) | **Not verified** |
| Wake-up alarms (task creation without administrator rights, waking from sleep and hibernate, Modern Standby, suspend) | Logic only (fakes) | **Not verified**; the list of open questions is in [docs/adr/0005-wake-timers.md](docs/adr/0005-wake-timers.md) |
| `flutter build windows --release` | n/a | Succeeds on the development PC; first launch of the built app checked for ten seconds |
| Installer, uninstall clean-up, release workflow, Pages workflow | n/a | **Not verified**: Inno Setup is not installed on the development PC, so the installer script has never been compiled, and neither workflow has run |
| Download page `site/` | n/a | Opened over a local web server: language switch, right-to-left layout, per-OS download links and screenshots load without errors |

`app/` has no automated tests; the manual checklists in [docs/](docs) are the acceptance tests for tray,
toasts, sound, autostart, installer and wake-up alarms.

## Known limitations

- City names exist only in Persian and English; other languages show the English name.
- The translations for Arabic, Turkish, Urdu, Azerbaijani, Indonesian and French have not been reviewed by
  native speakers.
- The public Nominatim and Esri servers are meant for light use. For a wide release, a keyed or
  self-hosted provider is advisable (one constant for the map tiles, `qiblaTileUrlTemplate`, and the
  `OnlinePlaceSearch` class for names).
- No surveyed coordinates of the Kaaba gutter (Mizab al-Rahma) are available, so the qibla line ends at
  the Kaaba reference point (21.422487, 39.826206). The difference does not change the direction.
- Windows only. `app/` has only a Windows runner, and the library imports `dart:io` (files, HTTP,
  processes), so a web build is not possible without changing it. No macOS, Linux, Android or iOS build
  exists.
- The project is under the MIT licence (`LICENSE`, 2026). The city database was decoded from the files of the previous Aviny program; the owner should be comfortable that those place names and coordinates (facts, not creative work) may be republished, or replace them over time.
- The developer's mobile number (`+9892128870991`) and Telegram are on the About page; the number has 11 digits after +98 where an Iranian mobile number normally has 10, so the owner should confirm it. Calls and texts work only from Iran, which the page says.
- The bundled azan and chime are generated placeholders, not recordings; users choose their own sound.
- No holidays or religious occasions in the calendar, and no in-app update check.

## Open decisions for the owner

| Question | State |
|---|---|
| Licence of the project | Decided: MIT (2026-11-12). |
| Azan recordings that may be shipped (the legacy files have no known licence) | Open. Only generated placeholders ship. |
| Map tile and place-search provider for a wide release | Open. Public servers in use, opt-in and light. |
| Surveyed Kaaba gutter coordinates | Open. Add a second target only from a cited source. |
| Sources for holidays and religious occasions | Open; the feature is not built. |
| Where releases are published, and whether the app checks for updates | Partly decided: GitHub Releases through `release.yml`. An update check is not built. |
| Review the 175 legacy cities that have no verified province and add them | Open; the 566 verified cities ship. |
| Author's mobile number on the About page | Decided; the owner should confirm the number (see Known limitations). |

Decided: the product name is "Salaat | Aviny Prayer Times" (2026-11-12).

## Next steps

1. **First public release.** Run [docs/manual-test-checklist.md](docs/manual-test-checklist.md) and
   [docs/manual-test-checklist-wake.md](docs/manual-test-checklist-wake.md) on Windows 10 and 11; choose a
   make sure `CHANGELOG.md` and the `app/pubspec.yaml` version agree; push the
   work, then a `v1.0.0` tag so the release workflow builds the installer and the portable zip as a draft
   (fix the workflow if its first run fails: Inno Setup via Chocolatey is the likeliest place); set
   Pages > Source to "GitHub Actions" so `pages.yml` publishes `site/`; read the draft and publish. The
   installer is not code-signed, so Windows SmartScreen warns on first run (the page explains how to
   continue); signing needs a certificate.
2. **Native-speaker review** of the six unreviewed translations (ar, tr, ur, az, id, fr), including the
   texts that explain network use and location permission.
3. **Hardware verification** of tray, toasts, sound, autostart, single instance, power events and
   wake-up alarms on several PCs (standard account, battery, Modern Standby), then update the table above.
4. **Wide-release readiness:** a keyed or self-hosted tile and place-search provider; city names in the
   other languages.
5. **Other platforms:** mobile and other desktop runners. The platform interfaces and fakes are already in
   `packages/owghat_lib`; each platform needs a runner and its own implementations, and the `dart:io`
   dependency of the library must be handled for web.
6. **Later ideas:** mini always-on-top widget, holidays and occasions, Ramadan mode, timetable export
   (PDF, CSV), global hotkeys, a prayer-time display mode for mosques.
