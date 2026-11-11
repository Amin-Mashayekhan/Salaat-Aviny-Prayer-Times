# 06 — Implementation Plan

Ten milestones, each a set of small tasks. Do them in order; inside a milestone, do tasks in order
unless marked *(parallel-safe)*. One task = one commit. Tick tasks off in `PROGRESS.md`.

Each task lists **Do** (what to build), **Files** (where), and **Done when** (how to prove it).
"Checks pass" always means, from the repo root:

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test            (in app/)        and        dart test   (in packages/prayer_core/)
```

Difficulty tags tell you which model to give a task to: **[S]** simple and mechanical,
**[M]** normal, **[H]** hard — correctness-critical or needs real-hardware testing.

## Open questions for the owner (do not block on these; defaults are stated)

| ID | Question | Default used until answered |
|---|---|---|
| Q-1 | Final product name, Persian and English, and the icon. | "اوقات" / "Owghat", a simple crescent-and-sun glyph. |
| Q-2 | Azan recordings. The two MP3s in the legacy app have no known licence. Which recordings may be shipped? | Ship none of the legacy files. Bundle one short, clearly licensed placeholder (`azan_default`) and a chime; the user can pick any audio file of their own. |
| Q-3 | Sources for the occasions data (F-21). | Deferred to P1. |
| Q-4 | Where releases are published (for the update check, F-28). | Deferred to P1. |
| Q-5 | Should the 175 unverified legacy cities be reviewed and added? | No; ship the 566 verified ones that have a province. |

---

## M0 — Repository and toolchain  [S]

**M0.1 Install and pin the toolchain.** Do: install Flutter stable (3.47.x or newer stable) with
Windows desktop support and the Visual Studio "Desktop development with C++" workload; run
`flutter doctor`; record the exact versions in `README.md`. Done when: `flutter doctor` shows no
errors for Windows desktop. *(Flutter is not installed on the owner's machine yet.)*

**M0.2 Create the workspace.** Do: `git init`; root `pubspec.yaml` with `workspace: [app,
packages/prayer_core]`; `dart create -t package packages/prayer_core`; `flutter create
--platforms=windows --org <org> app`; add `resolution: workspace` to both; `.gitignore`;
`analysis_options.yaml` with `very_good_analysis` plus: `avoid_print`, `prefer_const_constructors`,
`public_member_api_docs` for `prayer_core` only. Keep `docs/`, `seed/`, `tools/` untouched.
Done when: `flutter run -d windows` shows the counter app; checks pass.

**M0.3 CI.** Do: `.github/workflows/ci.yml` on `windows-latest`: checkout, `subosito/flutter-action`,
`flutter pub get`, the three checks, `flutter build windows --release`, upload the build as an
artifact; plus a grep step that fails on `DateTime.now(` anywhere under `app/lib` or
`packages/prayer_core/lib`. Done when: the workflow file is valid (run locally with the same
commands).

**M0.4 App skeleton.** Do: the folder tree of `03-ARCHITECTURE.md` §2 with empty barrel files;
`main.dart` → `bootstrap()`; `ProviderScope`; l10n set up (`l10n.yaml`, `app_fa.arb`, `app_en.arb`
with the glossary of `05-UI-UX-SPEC.md` §6); Vazirmatn in `assets/fonts` with its licence file;
theme tokens as a `ThemeExtension`; a shell with the navigation rail and six placeholder pages;
`fa` default and RTL. Done when: the app shows the rail in Persian, RTL, switches destination;
a widget test pumps the shell in `fa` and `en`.

---

## M1 — `prayer_core`: the calculator  [H]

Read `04-DOMAIN-SPEC.md` §2–§4 and `tools/reference/prayer_times_reference.py` first. Port; do not
redesign. No Flutter, no `DateTime.now`, no I/O in `lib/`.

**M1.1 Math helpers.** `trig.dart` (degree-based sin/cos/tan/asin/acos/atan2/acot, `fix`),
`julian_day.dart`, `solar_position.dart` (returns a record `({double declination, double
equationOfTime})`). Done when: unit tests match values printed by the Python functions for 5
sample inputs each (generate them with the reference and paste as test constants).

**M1.2 Types.** `Prayer` enum (`imsak, fajr, sunrise, dhuhr, asr, sunset, maghrib, isha,
midnight`), `CivilDate` (year, month, day; `addDays`; validation; no time), `CalculationParams`
(immutable, `copyWith`, equality), `CalculationMethod` (the 7 built-ins as constants + `custom`),
`AsrRule`, `HighLatitudeRule`, `MidnightRule`, `PrayerTimes` (nine `Duration?` + `operator []`
by `Prayer`). Done when: tests cover equality, the method table values, and that a built-in
method's params equal the table in the domain spec.

**M1.3 `PrayerCalculator.compute`.** Port `_compute_day` and `compute` exactly (3 refinement
passes, high-latitude block, midnight from the next day). Done when: `golden_test.dart` loads
`seed/golden/prayer_times_golden.json` and all 300 vectors pass within ±1 s. **Do not edit the
golden file to make a test pass.** If a vector fails, the port is wrong.

**M1.4 Adjustments and rounding.** `applyOffsets(PrayerTimes, Map<Prayer,int> minutes)`,
`roundToMinute(Duration)` (half up), `toUtcInstants(date, utcOffset, PrayerTimes)` →
`Map<Prayer, DateTime>` (UTC). Done when: every vector's rounded `HH:mm` equals `display`; tests
for 23:59:30 → 00:00 wrap, negative offsets crossing midnight, and null propagation.

**M1.5 Qibla and sun.** `qiblaBearing`, `distanceToKaabaKm`, `sunAzimuthAltitude(utcInstant, lat,
lon)`, `sunOnQibla(date, lat, lon, utcOffset)` (domain spec §4). Done when: golden `qibla`
bearings match within 0.01°; Tehran sun-on-qibla exists on 2026-06-21 and the sun azimuth at the
returned instant equals the bearing (or bearing + 180) within 0.05°.

**M1.6 Schedule builder (pure).** `ScheduledEvent`, `EventKind`, `ScheduleBuilder.build({dates,
instantsPerDate, enabled azans, reminder minutes, alarms})` → sorted `List<ScheduledEvent>` with
the id format of the domain spec; `CatchUpPolicy.decide(event, now, graceMinutes, handledIds)` →
`fire | fireLate | notifyMissed | drop`. Done when: unit tests for ids, ordering, disabled
items, reminder = azan − N, and every branch of the catch-up table (including "only the most
recent missed azan may play").

Milestone gate: `dart test` in `packages/prayer_core` green; line coverage ≥ 95 %; `dart doc`
builds without warnings.

---

## M2 — Settings and storage  [M]

**M2.1 Models.** `AppSettings` and children as `freezed` classes with `json_serializable`,
matching `03-ARCHITECTURE.md` §5; defaults from `01-PRODUCT-SPEC.md` (§5 F-06/F-07 defaults, §6).
Done when: `AppSettings.defaults()` round-trips through JSON unchanged.

**M2.2 `JsonStore`.** Atomic write (tmp + flush + rename), debounced save, corrupt-file
quarantine, in-memory fake. Done when: tests for round-trip, a truncated file → quarantine +
defaults, and a crash-between-write-and-rename simulation leaving the old file intact.

**M2.3 Migrations.** `schemaVersion`, `migrations.dart`, fixture `test/fixtures/settings_v1.json`.
Done when: loading the fixture yields the expected object; unknown keys are ignored; missing keys
get defaults.

**M2.4 `SettingsController`.** `Notifier<AppSettings>`; one named method per mutation; input
validation (ranges from the specs) returning typed failures. Done when: unit tests per method;
invalid input leaves state unchanged.

**M2.5 Backup / restore / reset.** Export to a chosen path, import with validation and migration,
reset. Done when: export → reset → import restores an identical object.

---

## M3 — Time and locations  [H for M3.1–M3.2, M for the rest]

**M3.1 Clock and zones.** `clockProvider` (`package:clock`); tz database initialised at bootstrap;
`ZoneOffsetResolver.offsetFor(LocationOffset, CivilDate)` implementing T-3 and T-7. Done when:
`iran_has_no_dst_test.dart` (domain spec §1.2) passes; `Europe/London` gives 0 on 2026-01-15 and
60 on 2026-07-15; fixed mode returns the typed value for every date.

**M3.2 The T-5 guard.** A test that builds the full provider graph with fakes, sets
`offset = fixed(210)`, then simulates: app restart, date rollover, location reload, method change,
30 days of engine ticks — and asserts the stored `offset` is still `fixed(210)` and the settings
JSON is unchanged except where the test itself changed it. This test is the direct regression test
for legacy bug B-01 and must never be deleted or weakened.

**M3.3 Location data.** A build script `tools/build_assets.py` that copies
`seed/locations/{cities_iran,provinces,countries}.json` to `app/assets/data/`, keeping only
`verified: true` cities and dropping fields the app does not need. `City`, `Province`, `Country`
models; `LocationRepository` (asset-backed, loaded once) with `provinces()`, `citiesOf(province)`,
`byId`, `search(query)`. Done when: 566 cities and 31 provinces load; every city has a province
or is listed under "سایر"; the province centre exists for all 31.

**M3.4 Search.** `TextNormalizer`: lower-case, ي→ی, ك→ک, remove ZWNJ/spaces/diacritics, آ→ا,
Persian/Arabic digits → Latin. Ranking: exact > prefix > contains; province centres first within
a rank. Done when: tests — "تهران", "tehran", "Tehr", "اصفهان"/"اصفهان " /"اصفهان‌", "قم",
"بندرعباس" finds "بندر عباس"; an empty query returns province centres.

**M3.5 Saved locations.** `SavedLocation` (builtin / custom), `LocationsController` (add, edit,
remove, set active; cannot remove the last one), custom-location validation (lat ±89.9, lon ±180,
DMS ↔ decimal helpers with tests). Done when: unit tests; default first-run location = Tehran.

**M3.6 Network time (F-15).** `NetworkTimeSource` + `ClockCorrectionController` (query at start
and every 6 h when enabled; store result in `state.json`; expose `skew`, `lastChecked`, `error`).
`SystemZone` + the D-1 / D-2 diagnostics as a provider returning a sealed `ClockWarning?`.
Done when: tests with a fake source — skew ≥ 30 s → D-1; OS offset ≠ tz offset for the same zone →
D-2; correction applied only when the user enabled it; a network error leaves correction at zero.

---

## M4 — Schedule engine and audio  [H]

**M4.1 Derived prayer providers.** `todayTimesProvider`, `timesForDateProvider(date)`,
`monthTimesProvider(month)`, `nextEventProvider` (ticks each second from the injected clock, emits
only when the displayed value changes). Done when: tests with a fake clock across a midnight and
after the last event of the day ("tomorrow" case).

**M4.2 `ScheduleEngine`.** Domain spec §5.2: single timer to the next event, rebuild triggers,
watchdog, `HandledEventsStore` (persisted, pruned), dispatch to `EventDispatcher`. Started in
bootstrap, independent of any widget. Done when: `fake_async` simulation tests —
(a) 30 days → exactly one `azan` dispatch per enabled prayer per day, none duplicated;
(b) sleep 6 h across Dhuhr → one "missed" notice, no late azan;
(c) sleep 90 s across an azan → it plays late;
(d) clock set back 1 h after an azan → not replayed;
(e) clock set forward 1 h → events in the skipped window follow the catch-up table;
(f) restart 1 minute after an azan → not replayed;
(g) settings change mid-day → future events change, handled ones stay handled.

**M4.3 Power events.** `PowerEvents` Windows implementation: handle `WM_POWERBROADCAST`
(`PBT_APMSUSPEND`, `PBT_APMRESUMEAUTOMATIC`, `PBT_APMRESUMESUSPEND`) and `WM_TIMECHANGE` in the
runner's `MessageHandler`, forward over a `MethodChannel`. Done when: manual test — sleep and
resume logs both events; changing the Windows clock logs `timeChanged`; the engine rebuilds.

**M4.4 Audio.** `AudioOutput` on `audioplayers`; `SoundRef` (`asset:<id>` | `file:<path>`);
`AzanPlayer` (volume = master × per-prayer, optional fade-in, stop, completion event, fallback to
the default asset when a file is missing or fails, never throws to the engine); `MuteController`
(until instant / until next prayer / indefinitely; auto-expires). Bundled sounds per Q-2.
Done when: unit tests with a fake output for volume maths, fallback and mute expiry; manual test
plays and stops real audio.

**M4.5 Notifications and reminders.** `Notifier` on `flutter_local_notifications` (immediate toasts
only, action button "stop"); `EventDispatcher` maps `azan` → play + toast, `reminder` → toast (+
chime), missed → toast. Text from `05-UI-UX-SPEC.md` §5. Done when: dispatcher unit tests with
fakes for every `CatchUpPolicy` result; manual test of each toast and of the Stop action.

Milestone gate (**review recommended with a stronger model**): all M4.2 simulations green; a
1-hour manual run on a real PC with an azan forced 2 minutes ahead (via a custom fixed offset)
plays exactly once at second :00.

---

## M5 — Home, tray, window  [M]

**M5.1 Formatting helpers.** `formatTime`, `formatCountdown`, `formatDurationWords`,
`formatNumber` (Persian / Latin digits, 12/24 h), bidi isolation. Tests in both locales.
**M5.2 Tri-calendar.** `TriDate` (Gregorian, Jalali, Hijri + adjustment), weekday names, the tests
listed in domain spec §6.
**M5.3 Home screen.** Header, hero card with sky gradient and timeline, today list with bell
toggles, status card, banners, now-playing bar, another-day navigation — `05-UI-UX-SPEC.md` §4.1.
Done when: widget tests in fa/en × light/dark × two sizes × text scale 1.0/2.0 with no overflow;
countdown text changes with a fake clock; the next row is marked.
**M5.4 Window behaviour.** `WindowHost`: remember bounds (`state.json`), min size, close-to-tray,
`--minimized`, single instance (second launch focuses the first and forwards args).
**M5.5 Tray.** `TrayHost` + `TrayController`: tooltip (updated each minute), menu per §5, actions
(stop, mute options, switch location, open, settings, quit). Rebuilt when times, playing state,
mute or locations change. Done when: controller unit tests assert the menu model for: idle,
playing, muted, two locations; manual test on Windows.
**M5.6 Autostart.** `AutostartService` + setting. Manual test: enable → reboot → app is in the
tray, window hidden.
**M5.7 Onboarding.** `05-UI-UX-SPEC.md` §4.7; shown when no settings file existed at start.

---

## M6 — Remaining screens  [M]  *(tasks are parallel-safe)*

**M6.1 Settings UI** — all eight sections (§4.6), every control wired to `SettingsController`,
including the time-zone row of F-05 with the live "offset in effect" line and **no DST control**.
**M6.2 Timetable** — F-12 / §4.2 (compute the month off the UI thread if a frame is dropped).
**M6.3 Calendar and converter** — F-11 / §4.3.
**M6.4 Qibla** — F-13 / §4.4 (`CustomPainter` compass; sun marker updates each minute).
**M6.5 Diagnostics and About** — F-18: next 10 events (UTC + local), clock status, audio test,
copy-diagnostics, licences page (`showLicensePage` plus font and sound licences).

Each is done when its widget tests pass in both locales and themes and the matching rows of the
legacy parity checklist (`02-LEGACY-ANALYSIS.md` §3) can be demonstrated.

---

## M7 — Wake-up alarms  [H, needs a real PC that can sleep]

**M7.1 Spike (time-boxed, throwaway branch).** Prove on real hardware, as a standard (non-admin)
user: (1) `schtasks /Create … /XML` with `WakeToRun` succeeds and the task wakes the PC from sleep
and from hibernate; (2) `SetWaitableTimer(fResume=TRUE)` via FFI wakes the PC while the app runs;
(3) `SetThreadExecutionState` keeps it awake during a 3-minute sound; (4) `SetSuspendState` sleeps
and hibernates (enable `SeShutdownPrivilege` first if required); (5) reading the `RTCWAKE` power
setting. Write the findings to `docs/adr/0005-wake-timers.md` (ADRs 0001-0003 are taken; 0004 is reserved). **Fallbacks**: if (1) needs
elevation → use only the in-process timer and say so in the UI ("works while the app is running");
if (4) fails → `rundll32 powrprof.dll,SetSuspendState` for sleep and `shutdown /h` for hibernate;
on Modern Standby devices where wake is unreliable → the capability panel says so.

**M7.2 `WakeTimerService`, `PowerControl`** per the ADR, with fakes. `probe()` result model.
**M7.3 `WakeAlarmController`**: CRUD, next-occurrence computation (fixed and relative-to-prayer,
once / daily / weekdays), re-arming after each fire and on every engine rebuild, `once` alarms
self-disable. Unit tests incl. "40 minutes before Fajr" following Fajr across 30 days.
**M7.4 Engine integration**: `wakeAlarm` events → sound → cancellable 30 s countdown → sleep /
hibernate; `--wake <id>` argument handling.
**M7.5 UI** — §4.5 incl. capability panel, "test in 2 minutes", sleep-now / hibernate-now.

Done when: the manual checklist passes on a real PC: alarm wakes from sleep, plays, returns to
sleep; cancelling the countdown keeps the PC awake; disabling the alarm removes the task
(`schtasks /Query /TN "Owghat\…"` shows nothing); uninstalling removes all tasks.

---

## M8 — Polish, accessibility, performance  [M]

- Keyboard map and focus order (§7); semantics labels; live-region countdown; contrast check.
- Empty / error / polar states; all banners; settings-reset notice.
- Reduce-motion; text scale 200 %; window at minimum size.
- Performance: no per-second rebuild above the countdown text (use `select` / small `Consumer`s);
  idle CPU about 0 % with the window hidden (stop the 1-second ticker when the window is hidden;
  the tray tooltip uses a 1-minute ticker); startup under 2 s.
- Log rotation; copy-diagnostics content reviewed for privacy.
- Full pass of the legacy parity checklist and the product spec P0 table; record gaps as issues.

---

## M9 — Packaging and release  [M]

**M9.1** App metadata: name, version, icon (`.ico` with 16–256 px), `Runner.rc` strings.
**M9.2** Inno Setup script `app/windows/installer/owghat.iss`: per-user install
(`PrivilegesRequired=lowest`), Start-menu shortcut, optional "start with Windows", uninstall that
removes the autostart entry and scheduled tasks and asks whether to keep settings.
**M9.3** `docs/manual-test-checklist.md`: fresh install, upgrade install, uninstall, autostart,
tray, each toast, azan on time, sleep/resume, wake alarm, clock-change, RTL/LTR, light/dark.
**M9.4** Release build, run the checklist on Windows 10 and Windows 11, tag `v1.0.0`.
**M9.5** `README.md` for users (Persian + English) and `CONTRIBUTING.md`.

---

## After 1.0 (P1 backlog, one milestone each)

F-19 mini widget · F-20 audio ducking (Windows Core Audio session API via FFI) · F-21 occasions ·
F-22 Ramadan mode · F-23 PDF/CSV export · F-24 world cities (GeoNames → SQLite with `drift`,
`LocationRepository` swap) · F-25 hotkeys · F-26 dua after azan · F-27 mosque display · F-28
update check · F-29 location detection.

## Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Wake from sleep unreliable on some hardware (Modern Standby, disabled wake timers) | High | Medium | M7.1 spike first; capability probe; honest UI; feature degrades, nothing else depends on it. |
| Port of the calculator subtly wrong | Medium | High | 300 golden vectors, ±1 s; port, do not redesign. |
| Azan missed after sleep or clock change | Medium | High | Engine simulations (M4.2 a–g); watchdog; power events. |
| A future change reintroduces a DST switch or overwrites the offset | Low | High | Tests M3.1 and M3.2 are named regression guards; rule T-4/T-5 in `CLAUDE.md`. |
| Plugin API differs from what a model remembers | High | Low | Read the package's README/source in the pub cache before using it; never guess an API. |
| Toast actions / cancel limited on unpackaged apps | Medium | Low | Only immediate toasts; Stop also in tray and in-app. |
| No licensed azan audio | Medium | Medium | Q-2; custom-file picker works from day one. |
