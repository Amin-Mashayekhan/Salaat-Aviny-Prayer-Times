# Progress

Update this file at the end of every work session. One line per task; add notes the next session needs.

## Status

- Current milestone: **M0** (not started)
- Next task: **M0.1**

## Blocked

_(nothing)_

## Open questions for the owner

See the table at the top of `docs/06-IMPLEMENTATION-PLAN.md` (Q-1 … Q-5). Record answers here.

## Tasks

### M0 — Repository and toolchain
- [ ] M0.1 Install and pin the toolchain
- [ ] M0.2 Create the workspace
- [ ] M0.3 CI
- [ ] M0.4 App skeleton

### M1 — prayer_core
- [ ] M1.1 Math helpers
- [ ] M1.2 Types
- [ ] M1.3 PrayerCalculator.compute (300 golden vectors)
- [ ] M1.4 Adjustments and rounding
- [ ] M1.5 Qibla and sun
- [ ] M1.6 Schedule builder and catch-up policy

### M2 — Settings and storage
- [ ] M2.1 Models
- [ ] M2.2 JsonStore
- [ ] M2.3 Migrations
- [ ] M2.4 SettingsController
- [ ] M2.5 Backup / restore / reset

### M3 — Time and locations
- [ ] M3.1 Clock and zones (Iran no-DST test)
- [ ] M3.2 T-5 guard test
- [ ] M3.3 Location data
- [ ] M3.4 Search
- [ ] M3.5 Saved locations
- [ ] M3.6 Network time and clock diagnostics

### M4 — Schedule engine and audio
- [ ] M4.1 Derived prayer providers
- [ ] M4.2 ScheduleEngine (simulations a–g)
- [ ] M4.3 Power events
- [ ] M4.4 Audio
- [ ] M4.5 Notifications and reminders
- [ ] Gate: review + 1-hour manual run

### M5 — Home, tray, window
- [x] M5.1 Formatting helpers
- [x] M5.2 Tri-calendar
- [x] M5.3 Home screen
- [ ] M5.4 Window behaviour
- [ ] M5.5 Tray
- [ ] M5.6 Autostart
- [x] M5.7 Onboarding

### M6 — Remaining screens
- [x] M6.1 Settings UI
- [x] M6.2 Timetable
- [x] M6.3 Calendar and converter
- [x] M6.4 Qibla
- [x] M6.5 Diagnostics and About (widget done and tested; reachable once Settings overrides `aboutSectionBuilderProvider`)

### M7 — Wake-up alarms
- [ ] M7.1 Spike + ADR 0001
- [ ] M7.2 WakeTimerService, PowerControl
- [ ] M7.3 WakeAlarmController
- [ ] M7.4 Engine integration
- [ ] M7.5 UI

### M8 — Polish, accessibility, performance
- [ ] Keyboard, semantics, contrast
- [ ] States and banners
- [ ] Performance targets
- [ ] Parity checklist pass

### M9 — Packaging and release
- [ ] M9.1 Metadata and icon
- [ ] M9.2 Installer
- [ ] M9.3 Manual test checklist
- [ ] M9.4 Release build and tag
- [ ] M9.5 User README, CONTRIBUTING

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
