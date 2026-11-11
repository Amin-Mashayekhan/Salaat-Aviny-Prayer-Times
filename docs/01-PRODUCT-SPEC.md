# 01 — Product Spec

Working name: **Owghat** (اوقات) — a prayer-times and azan app. The name is a placeholder; see
open question Q-1 in `06-IMPLEMENTATION-PLAN.md`.

## 1. What we are building

A modern replacement for the 2013 Windows app "Aviny Prayer Times" (`02-LEGACY-ANALYSIS.md`):
the same job, every legacy feature kept, the legacy bugs gone, a far better interface, and the
most useful features of today's comparable apps added.

It sits in the Windows tray, knows the prayer times of the user's city without the internet, plays
the azan on time, reminds beforehand, and can wake the PC for it.

## 2. Product principles

1. **On time, every time.** A missed or wrong-hour azan is the worst possible failure. Correctness
   of time handling outranks every other concern.
2. **Works offline.** All calculation and all data are local. The network is used only for
   optional features the user turned on (network time check, update check).
3. **Nothing to sell.** No ads, no account, no telemetry, no tracking, no location sent anywhere.
4. **Focused.** Prayer times, azan, calendar, qibla, wake-up. No Quran reader, no social feed, no
   shop. Reviews of competing apps complain most about ads, bloat and unreliable azan.
5. **The user's choice sticks.** No setting is ever changed by the app on its own.
6. **Quiet by default.** Notifications never steal keyboard focus; the azan can be stopped with one
   click from anywhere.

## 3. Platforms

- **v1: Windows 10 (1809+) and Windows 11, x64.** Single window plus tray icon.
- The code is structured so Android, Linux and macOS can be added later: all OS-specific behaviour
  is behind interfaces (`03-ARCHITECTURE.md`). No v1 task targets those platforms.

## 4. Users

- **Primary**: Persian-speaking Shia users in Iran with a desktop or laptop that is on most of the
  day (home, office, mosque office). Persian, right-to-left, Shamsi calendar, Tehran method.
- **Secondary**: users elsewhere who want a clean, ad-free desktop azan app (English UI, other
  methods). Supported, not the design centre.

## 5. Features

Priority: **P0** = required for 1.0 (legacy parity plus fixes plus the essentials every comparable
app has). **P1** = 1.1. **P2** = later. Legacy IDs refer to `02-LEGACY-ANALYSIS.md`.

### P0 — version 1.0

| ID | Feature | Details | Legacy |
|---|---|---|---|
| F-01 | First-run setup | 3 steps: language (Persian default) → city (search box, Tehran preselected) → azan sound preview and "start with Windows" toggle. Skippable; everything has a default. | — |
| F-02 | Home | The next prayer and a live countdown are the largest things on screen. Below: today's times as a list with the current period highlighted; the three dates; a day timeline (sun arc from Fajr to midnight with a "now" marker). After the last event of the day the list shows tomorrow. Rows for Imsak, Asr, Isha and Sunset can be hidden in settings; Fajr, Sunrise, Dhuhr, Maghrib and Midnight are always shown. | L-03, L-04 |
| F-03 | Locations | Offline database of 567 verified Iranian cities, browsable by province and searchable in Persian or English (search ignores ی/ي, ک/ك, آ/ا, spaces and half-spaces). Custom locations: name, latitude and longitude as decimal degrees or degrees-minutes-seconds, elevation, time zone. Several saved locations, one active, quick switch from home and tray. | L-01, L-02, L-15 |
| F-04 | Calculation settings | Method (7 built-in plus custom angles), Asr rule, high-latitude rule, Imsak minutes before Fajr, per-prayer minute offsets (−60…+60). A "restore defaults for this method" button. | L-10 |
| F-05 | Time zone handling | Per location: "Automatic (recommended)" using the built-in time-zone database, or "Fixed offset" in hours and minutes. **No daylight-saving switch.** The screen shows the offset currently in effect and the next change, if the zone has one. | fixes B-01 |
| F-06 | Azan | Per prayer (Fajr, Dhuhr, Asr, Maghrib, Isha): on/off, sound (bundled list or any MP3/WAV/OGG/M4A file), volume. Defaults: on for Fajr, Dhuhr, Maghrib (as legacy); off for Asr and Isha. Global master switch and master volume. Optional 2-second fade-in. Preview and stop buttons. While playing: a small non-modal "now playing" bar in the app and a Stop action in the tray menu and on the notification. Quick mute: "until next prayer", "for 1 hour", "for 24 hours", "until I turn it back on". | L-08, fixes B-02, B-14 |
| F-07 | Reminder before azan | Per prayer: minutes before (0 = off, 1…60). Default 10 for the three prayers with azan on. Delivered as a Windows toast that does not take focus, with the prayer name and remaining time; optional soft chime. Independent of the azan: turning reminders off never affects the azan. | L-09, fixes B-02 |
| F-08 | Reliable schedule | Exactly-once delivery, survives sleep/resume and clock changes, catch-up rules, missed-azan notice. Fully specified in `04-DOMAIN-SPEC.md` §5. | fixes B-03 |
| F-09 | Tray | Icon with tooltip "next prayer · time · remaining". Left click toggles the window. Menu: next prayer line, today's times, Stop azan (only while playing), Mute submenu, location submenu, Open, Settings, Quit. Closing the window hides to tray (setting, default on, explained once by a toast). Single instance: starting the app again brings the running window forward. | L-12 |
| F-10 | Start with Windows | Toggle; starts hidden in the tray. | L-13 |
| F-11 | Dates and calendar | Shamsi, Hijri and Gregorian shown together; Hijri adjustment −2…+2 days; "view another day" date navigation (previous / next / pick a date in any of the three calendars / back to today); date converter. | L-05 |
| F-12 | Monthly timetable | Table of a whole month (Shamsi by default, or Gregorian / Hijri) with all enabled time columns, today highlighted, month navigation. | L-06 |
| F-13 | Qibla | Bearing in degrees and as compass text, distance to the Kaaba, a compass-rose drawing with the qibla line and the sun's current azimuth, and today's sun-on-qibla time (مقارنه / مقابله) with a one-line explanation of how to use it. | L-07 |
| F-14 | Wake-up alarms | One or more alarms that wake the PC from sleep: at a fixed time, or N minutes before a chosen prayer (legacy's "40 minutes before Fajr" becomes a general option). Repeat once / daily / chosen weekdays. Optional sound; optional return to sleep or hibernate afterwards, always with a cancellable 30-second countdown. "Sleep now" and "Hibernate now" buttons. A self-test button that reports whether this PC allows wake timers and, if not, explains the Windows setting and offers to open it. The app never changes power settings silently. | L-14, fixes B-10 |
| F-15 | Network time check | Off by default. When on: checks the PC clock against NTP at start and every 6 hours, warns if it is off by 30 s or more, and can correct inside the app. Never changes the Windows clock. Server name editable (default `pool.ntp.org`). | L-11, fixes B-09 |
| F-16 | Appearance and language | Light / dark / follow Windows. Persian (default) and English, switchable without restart. Right-to-left layout for Persian. Digits: Persian or Latin (setting; Persian default in Persian UI). 24-hour or 12-hour clock. | — |
| F-17 | Backup and restore | Export all settings (including custom locations and alarms) to one JSON file; import it; reset to defaults. | fixes B-11 |
| F-18 | About and diagnostics | Version, licences of bundled packages, fonts and sounds, link to the project page. Diagnostics page: next 10 scheduled events with their UTC and local instants, clock status (D-1, D-2), audio test, wake-timer test, "copy diagnostics" button, log file location. | L-16 |

### P1 — version 1.1

| ID | Feature | Why |
|---|---|---|
| F-19 | Mini widget | Small always-on-top frameless window: next prayer and countdown. Drag anywhere, remembers position. |
| F-20 | Pause or lower other audio during azan | Lower the volume of other apps' audio sessions while the azan plays, restore after. No comparable desktop app was found doing this. |
| F-21 | Occasions | Official Iranian holidays and Shia religious occasions on the date header and in the calendar (bundled, sourced data with attribution). |
| F-22 | Ramadan mode | During Ramadan: Imsak and Iftar become the hero items, with "time to Iftar" countdown and an optional Iftar-time dua line. |
| F-23 | Timetable export | Monthly or yearly timetable to PDF (print-ready A4) and CSV. |
| F-24 | World cities | About 25,000 cities worldwide with IANA zones from GeoNames `cities15000` (CC BY 4.0), with Persian names where available. |
| F-25 | Global hotkeys | Stop azan; show/hide window. Configurable. |
| F-26 | Dua after azan | Optional short audio or text after the azan ends. |
| F-27 | Mosque display mode | Full-screen, large type for a TV or wall screen: clock, all times, countdown, optional iqama countdown per prayer. |
| F-28 | Update check | Checks a release feed, shows "version X is available" with a download link. No silent install. |
| F-29 | Location detection | Opt-in one-shot use of Windows location services to preselect the nearest city. Nothing is sent to any server. |

### P2 — later

Android and iOS (system alarms, home-screen widgets), macOS and Linux builds, prayer / qaza tracker,
dhikr counter, more languages (Arabic, Urdu, Turkish), smart-home hooks.

### Non-goals

Ads. Accounts or cloud sync. Telemetry. Quran text or audio library. Social features. Payments.
Editing the built-in city database inside the app.

## 6. Defaults that differ from the legacy app, and why

| Setting | Legacy | New | Reason |
|---|---|---|---|
| DST | Forced on for Iran half the year | Does not exist | B-01 |
| Reminder lead time | 120 seconds, popup that owns the azan | 10 minutes, toast, independent | A 2-minute warning is too short to prepare; B-02 |
| Hijri adjustment | −1 day | 0 with a visible control | −1 was a guess baked into defaults |
| Times shown | 6 | 9 available, 7 shown by default (adds Asr and Isha rows as optional, Imsak optional) | B-08 |
| Volume | 0–1000 | 0–100 % | B-13 |
| Fajr azan sound | Same file as other prayers | Separate Fajr sound selectable | B-14 |

## 7. Quality bar for 1.0

- All golden vectors pass; the Iran no-DST regression test passes.
- Azan starts within 1 second of the scheduled instant while the app is running, and after resume
  from sleep within the catch-up rules.
- 24-hour soak run with a fake clock stepping through 30 days shows exactly one azan per enabled
  prayer per day.
- Cold start to tray in under 2 seconds on a mid-range PC; idle CPU about 0 %; memory under 150 MB.
- Every screen usable by keyboard alone; every control has a semantic label; contrast meets WCAG AA
  in both themes.
- No blocking modal dialog can ever be opened by a background event.
