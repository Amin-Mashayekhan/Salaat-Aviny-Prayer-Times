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
- [ ] M5.1 Formatting helpers
- [ ] M5.2 Tri-calendar
- [ ] M5.3 Home screen
- [ ] M5.4 Window behaviour
- [ ] M5.5 Tray
- [ ] M5.6 Autostart
- [ ] M5.7 Onboarding

### M6 — Remaining screens
- [ ] M6.1 Settings UI
- [ ] M6.2 Timetable
- [ ] M6.3 Calendar and converter
- [ ] M6.4 Qibla
- [ ] M6.5 Diagnostics and About

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
