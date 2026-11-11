# Progress

Legend: `[x]` done and covered by automated tests; `[~]` code written and analysed but NOT yet run on a
real Windows PC (needs the manual checklist in `docs/manual-test-checklist*.md`); `[ ]` not done.

## Status (2026-11-11)

- Library `packages/owghat_lib`: 767 tests, `flutter analyze` clean. `packages/prayer_core`: 374 tests,
  100 % line coverage, `dart analyze` clean. `app/`: `flutter analyze` clean.
- **Nothing in `app/` has ever been compiled or run**: this machine has no Visual Studio (C++ workload),
  so `flutter build windows` / `flutter run -d windows` were never executed. That covers the C++ runner
  code, every plugin class (tray, window, audio, toasts, autostart, single instance, file dialogs) and the
  wake-up FFI/Task Scheduler code. Install Visual Studio Build Tools (Desktop development with C++), run
  `flutter build windows --release` in `app/`, then work through the manual checklists.
- Next steps for the owner: (1) install the C++ toolchain, build, fix compile errors in `app/windows` and
  `app/lib/src/platform`; (2) run `docs/manual-test-checklist.md` and `docs/manual-test-checklist-wake.md`
  on Windows 10 and 11; (3) answer the open questions below; (4) tag `v1.0.0`.

## Blocked

- M9.4 (release build, tag): needs the Visual Studio C++ toolchain.
- Hardware verification of M4.3-M4.5, M5.4-M5.6 and M7: needs a real PC (see manual checklists).

## Open questions for the owner

See the table at the top of `docs/06-IMPLEMENTATION-PLAN.md` (Q-1 ... Q-5). Defaults in force: name
"Owghat", generated placeholder sounds only (no azan recording shipped), 566 verified cities.

## Tasks

### M0 - Repository and toolchain
- [x] M0.1 Install and pin the toolchain (Flutter 3.47.9 at `E:\Ermile	oolslutter`; VS C++ missing)
- [x] M0.2 Create the workspace
- [x] M0.3 CI (`.github/workflows/ci.yml`, not yet run on GitHub)
- [x] M0.4 App skeleton

### M1 - prayer_core
- [x] M1.1 - M1.6 (calculator with 300 golden vectors, adjustments, qibla and sun, schedule builder, catch-up policy)

### M2 - Settings and storage
- [x] M2.1 - M2.5 (models, atomic JSON store, migrations, controller, backup/restore/reset)

### M3 - Time and locations
- [x] M3.1 Clock and zones (Iran no-DST test)
- [x] M3.2 T-5 guard test (`t5_guard_test.dart`)
- [x] M3.3 - M3.5 Location data, search, saved locations
- [x] M3.6 Network time and clock diagnostics

### M4 - Schedule engine and audio
- [x] M4.1 Derived prayer providers
- [x] M4.2 ScheduleEngine (simulations a-g)
- [~] M4.3 Power events (C++ uncompiled)
- [~] M4.4 Audio
- [~] M4.5 Notifications and reminders
- [ ] Gate: review + 1-hour manual run

### M5 - Home, tray, window
- [x] M5.1 Formatting helpers
- [x] M5.2 Tri-calendar
- [x] M5.3 Home screen
- [~] M5.4 Window behaviour
- [~] M5.5 Tray
- [~] M5.6 Autostart
- [x] M5.7 Onboarding

### M6 - Remaining screens
- [x] M6.1 Settings UI
- [x] M6.2 Timetable
- [x] M6.3 Calendar and converter
- [x] M6.4 Qibla
- [x] M6.5 Diagnostics and About (wired in `bootstrap`)

### M7 - Wake-up alarms
- [ ] M7.1 Hardware spike (see `docs/adr/0005-wake-timers.md`, `docs/manual-test-checklist-wake.md`)
- [~] M7.2 WakeTimerService, PowerControl
- [x] M7.3 WakeAlarmController
- [x] M7.4 Engine integration
- [x] M7.5 UI

### M8 - Polish, accessibility, performance
- [x] Keyboard: Ctrl+1..6, Ctrl+comma, global Esc (stop azan / cancel countdown)
- [x] Idle ticking: minute ticks while the window is hidden
- [~] Semantics, contrast, text scale 200 % (widget tests pass with the test font; not seen with Vazirmatn)
- [ ] Parity checklist pass on a real run

### M9 - Packaging and release
- [x] M9.1 Metadata and icons (Runner.rc company/product "Owghat", generated icons)
- [~] M9.2 Installer script `app/windows/installer/owghat.iss` (never compiled)
- [x] M9.3 Manual test checklists
- [ ] M9.4 Release build and tag
- [x] M9.5 User README, CONTRIBUTING

## Session log

- 2026-11-11 — Planning package created: legacy app analysed, location data extracted and cleaned,
  reference algorithm and 300 golden vectors generated, specs and plan written. No app code yet.
- 2026-11-11 — Platform layer (parallel session, tasks M4.3-M4.5 and M5.4-M5.6; not ticked above because
  their manual checks need a real PC). Library: platform interfaces + fakes (`core/platform/`),
  `PlatformServices` + `bootstrap(args, services)` / `prepareApp`, audio (`AzanPlaybackController`:
  master x prayer volume, fade-in, fallback to `asset:azan_default`, preview, chime), mute (evaluated, never
  written back), `AppScheduleDispatcher` (override of `eventDispatcherProvider`; wake alarms go to
  `wakeAlarmHandlerProvider`), notification texts, `TrayController`, `WindowController`,
  `AutostartController`, locale/theme follow the settings. Runner: `app/lib/src/platform/` (audioplayers,
  toasts, window_manager, tray_manager, `reg.exe` autostart, single instance, file_selector, path_provider,
  power events channel `owghat/power`) and native code in `app/windows/runner/` (power messages,
  `--minimized`). ADR 0003. Next session must know: the C++ and every `app/` plugin class are UNCOMPILED
  and UNRUN (no Visual Studio here; verified by `flutter analyze` only). First manual run should check:
  tray icon + menu, close-to-tray, `--minimized` start, toast Stop button, sleep/resume and clock change logs,
  autostart value in `HKCU\...\Run`, second launch focusing the first window.
- 2026-11-11 - UI core (parallel session, M5.1, M5.2, M5.3, M5.7, M6.2; ticked because their automated
  "Done when" is met; not seen on a real screen or with the Vazirmatn font, tests run with the Ahem test font).
  `core/format/Formatter` (+ `formatterProvider`, `appLocalizationsProvider`), `features/calendar` (`TriDate`,
  `monthDays`, `CalendarNames`, `dateHeaderProvider`), Home (`prayer_times/presentation`, state in
  `application/home_view.dart`, `home_status.dart`, `home_banners.dart`), `viewedDateProvider` (null = today;
  the Timetable and the future Calendar screen open a day on Home through `.show(date)`), Timetable
  (`timetable_providers.dart`, per-month cache), Onboarding (`features/onboarding`, shown by `AppShell` while
  `onboardingCompleted` is false). Hooks other work must provide: override `settingsWasResetProvider` (true when
  the settings file was reset) and `onboardingPreviewProvider` (plays the azan sample; default no-op). The Home
  "next wake-up" line is a placeholder dash until the wake-up feature publishes the next occurrence. Esc stops
  the audio only while Home is shown. Gregorian dates use the app language month names (Persian names in the
  Persian UI), not the Latin names of the sketch.
- 2026-11-11 - Wake-up alarm logic and platform glue (parallel session, M7.2-M7.4; NOT ticked: the "Done when" is the
  manual wake checklist on a real PC, and M7.5 UI is not built; M7.1 spike is replaced by `docs/adr/0005-wake-timers.md`,
  a design written without hardware). Library `features/wake_alarm/`: pure `nextOccurrence` + `buildWakePlan`
  (fixed time or N min before a prayer, once/daily/weekdays, polar nulls, midnight crossing), `WakeAlarmController`
  (add/update/delete/setEnabled, probe, sleepNow/hibernateNow 5 s countdown, 30 s after-alarm countdown, keep-awake,
  `testInTwoMinutes`, OS wake re-arming), interfaces + fakes (`WakeTimerService`, `PowerControl`, `AlarmSoundPlayer`),
  task XML / schtasks / powercfg pure builders and parsers, `CompositeWakeTimerService`, `AudioOutputAlarmSoundPlayer`.
  Public barrel `package:owghat_lib/wake_alarm.dart`. Scheduler: `alarmOccurrencesProvider` now reads the wake plan, the
  engine rebuild starts one microtask later and also listens to `wakeBookkeepingProvider` (derived providers are stale
  inside listener callbacks). Runner `app/lib/src/platform/wake/`: dart:ffi waitable timer on a worker isolate,
  `SetThreadExecutionState`, `SetSuspendState` + fallbacks, `WindowsWakeServices.create`. Bootstrap must (not done, belongs
  to the platform session): pass `extraOverrides` with `wakeTimerServiceProvider`, `powerControlProvider`,
  `alarmSoundPlayerProvider` (`AudioOutputAlarmSoundPlayer(ref.read(audioOutputProvider))`) and
  `wakeAlarmHandlerProvider.overrideWith((ref) => ref.watch(wakeAlarmEventHandlerProvider))`, read
  `wakeAlarmControllerProvider` once after the engine starts, and call `noteWakeLaunch(id)` for `LaunchArgs.wakeAlarmId`.
  Home can show `nextWakeOccurrenceProvider`. The app/ code is UNRUN; see the ADR's list of unverified questions and
  `docs/manual-test-checklist-wake.md`.
- 2026-11-11 - Settings UI (parallel session, M6.1; ticked because its automated "Done when" is met: widget tests in fa/en,
  light/dark, 1200x800 and 800x560, text scale 1.0 and 2.0 show every section without overflow; not seen on a real screen
  or with Vazirmatn). `features/settings/presentation/` (`SettingsPage`, one file per section, `setting_widgets.dart`),
  state in `features/settings/application/` (`settings_ui.dart`: `selectedSettingsSectionProvider` for deep links such as
  the home "Calculation settings" link, `settingsSavedCountProvider`, `calculationBaseMethodProvider`,
  `aboutSectionBuilderProvider`; `settings_actions.dart`: sound pick, preview, backup export/import/reset;
  `zone_info.dart`: offset in effect; `location_draft.dart`, `number_input.dart`), `data/backup_files.dart`
  (`backupFilesProvider`). Registered as `Destination.settings` in `destination_pages.dart`. Additive change in core:
  `ZoneOffsetResolver.nextOffsetChange`. SLOT for M6.5: override `aboutSectionBuilderProvider` with a builder that returns
  `AboutDiagnosticsSection` (placeholder text until then). Decisions: text fields (angles, server, steppers) apply on
  Enter or when focus leaves, not per keystroke, so the schedule is not recalculated with half-typed numbers; "Custom"
  method is shown but not selectable (typing any angle makes it custom) and "restore defaults for this method" returns to
  the last built-in method used on this screen (Tehran after a restart); adding a city does not activate it; backup import
  keeps `onboardingCompleted` true and is refused when a custom location names an unknown zone; start-with-Windows only
  calls `setLaunchAtStartup`, the `AutostartController` listener started by `bootstrap` does the registry write.
- 2026-11-11 - Calendar, Qibla, Wake-up page, About and diagnostics (parallel session, M6.3, M6.4, M6.5 ticked because
  their automated "Done when" is met: widget tests in fa/en, light/dark, 1200x800 and 800x560, text scale 1.0 and 2.0,
  no overflow; M7.5 UI is built and tested with the fake wake services but NOT ticked, the M7 "Done when" is the manual
  checklist on a real PC; nothing seen on a real screen or with Vazirmatn). Calendar `features/calendar/presentation/`
  (month grid in the Shamsi calendar, side panel, lunar adjustment stepper through `setHijriAdjustment`, date converter
  with three linked fields; state `application/calendar_view.dart`, validation `domain/date_converter.dart`
  `convertDate`). Qibla `features/qibla/` (`qiblaInfoProvider`, `sunNowProvider` updated each minute from
  `nowMinuteProvider`, `sunOnQiblaTodayProvider`, `CustomPainter` `QiblaCompassPainter`). Wake-up page
  `features/wake_alarm/presentation/` (`WakeUpPage`, `WakeCapabilityPanel`, `AlarmCard`, `showAlarmEditor`,
  `WakeCountdownOverlay`; texts in `application/wake_labels.dart`). The Home status card now shows
  `nextWakeOccurrenceProvider`. About `features/diagnostics/` (`AboutDiagnosticsSection`, `appVersionProvider`,
  `diagnosticEventsProvider`, `diagnosticsReportProvider`, privacy rules in `buildDiagnosticsReport`). Registered
  `Destination.calendar`, `.qibla`, `.wakeUp` in `destination_pages.dart` (the placeholder is gone; the switch is
  exhaustive). Orchestrator must still: (1) override `aboutSectionBuilderProvider` with a builder returning
  `const AboutDiagnosticsSection()`, (2) override `appVersionProvider` with the packaged version, (3) mount
  `WakeCountdownOverlay` in `AppShell` so the 30 s countdown after an alarm is visible and cancellable on every screen
  (today it exists only on the Wake-up page; it is deliberately not a modal dialog, rule 8), (4) the About page has no
  project link yet (no URL is known). Known limits: the diagnostics list shows the events the engine holds (today and
  tomorrow), so late in the day fewer than 10 exist; the report is English only on purpose.
