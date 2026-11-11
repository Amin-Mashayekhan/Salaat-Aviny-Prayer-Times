# 07 — Research Notes (2026-11-11)

Background for the decisions in the other documents. Web research; review samples were small
(20–30 reviews per app), so the complaint list is indicative, not statistical.

## 1. What comparable apps offer

Apps looked at — Iranian / Shia: Bade Saba, Namaz Shia, Shia Companion, Nasim Noor. Global mobile:
Muslim Pro, Athan (IslamicFinder), Athan Pro, Mawaqit, Pillars. Desktop: Awqat Salaat (Windows
taskbar widget), Sajda (tray app), AdhanBox, Miqaat, Al Munadi, Muezzin, Minbar, Noor.

| Feature | Seen in | Our plan |
|---|---|---|
| Offline local calculation | AdhanBox, Miqaat, Noor | P0 (principle 2) |
| Tray icon with next-prayer countdown, autostart minimised | Sajda, Al Munadi, Awqat Salaat, AdhanBox | P0 F-09, F-10 |
| Per-prayer azan sound, volume, minute offset, custom MP3 | AdhanBox, Sajda | P0 F-04, F-06 |
| Reminder before azan | AdhanBox, Miqaat (0/5/10/15/30), Awqat Salaat | P0 F-07 |
| One-click stop and "mute for 1 h / 24 h" | Sajda, AdhanBox | P0 F-06 |
| Tehran and Jafari methods, high-latitude rules | PrayTimes, AdhanBox | P0 F-04 |
| Manual coordinates that persist | (old IslamicFinder Athan reviews complain they reset) | P0 F-03, F-17 |
| Shamsi + Hijri + Gregorian, conversion, occasions | Bade Saba | P0 F-11; occasions P1 F-21 |
| No ads, no account, no tracking | Mawaqit, Al Munadi, AdhanBox, Pillars | Principle 3 |
| Persian / Arabic RTL UI | AdhanBox, Miqaat | P0 F-16 |
| Always-on-top compact widget | Miqaat, Awqat Salaat | P1 F-19 |
| Full-screen mosque display, iqama countdown | Mawaqit TV | P1 F-27 |
| Dua after azan | Miqaat | P1 F-26 |
| Imsak and midnight rows, monthly PDF export | Namaz Shia | P0 rows; P1 F-23 |
| Ramadan mode | Athan Pro, Sajda | P1 F-22 |
| Multiple saved locations | Miqaat, Al Munadi | P0 F-03 |
| Notifications that do not steal focus | Sajda | P0 F-07 |
| Auto-update | Sajda, Miqaat | P1 F-28 (notify only) |
| Prayer / qaza tracker, dhikr counter | Pillars, Namaz Shia, Bade Saba | P2 |

Not found in any app reviewed, so these set this app apart: lowering other audio during the azan
(F-20), waking the PC from sleep and returning it to sleep (F-14), network clock check (F-15),
settings backup and restore (F-17).

## 2. What users complain about

- Ads, including ads that interrupt the azan (Muslim Pro, Athan Pro).
- Paid features lost after updates; purchases turned into subscriptions.
- Privacy: Muslim Pro sent location data to a broker that sold to military contractors (2020 reporting).
- Azan not firing, firing two or three times, or cut off part-way.
- Times wrong by 1–30 minutes, especially Maghrib and Fajr; method settings resetting.
- Widgets showing stale times after the day or month rolls over.
- Bloat: Bade Saba now includes bill payment, gold trading and films; reviewers of Pillars ask for focus.

These map directly to the product principles and to the schedule-engine tests (exactly-once,
rollover, catch-up).

## 3. UX patterns that reviewers praise

- Next prayer and countdown as the largest element on the main screen.
- A horizontal day timeline or sun arc with the next prayer highlighted.
- The current period highlighted; after Isha the list switches to tomorrow.
- Tray text changing colour shortly before prayer.
- Clean, minimal, ad-free design is the most repeated praise.
- A guided first run.

## 4. Iran and Shia specifics

- Parameters (PrayTimes documentation and source): Tehran — Fajr 17.7°, Maghrib 4.5°, Isha 14°,
  Jafari midnight. Jafari (Leva, Qom) — Fajr 16°, Maghrib 4°, Isha 14°, Jafari midnight. PrayTimes
  notes that Tehran's Isha angle is not explicitly specified by the institute; 14° is the default.
- Maghrib is not sunset; it is a twilight angle. Show sunset and Maghrib as separate rows.
- Midnight is the midpoint of sunset to Fajr, not sunset to sunrise.
- Imsak has no single convention (commonly 10–15 minutes before Fajr as a precaution). It is a
  configurable offset, default 10.
- **Daylight saving time**: abolished by a 2022 law. The last DST period ended on 21 September
  2022; there has been no clock change from 1 Farvardin 1402 (21 March 2023). IANA tzdata 2022b
  and later encode this; `package:timezone` 0.11.2 bundles tzdb 2026e. Microsoft shipped the
  Windows update for this only in April 2023, so an unpatched Windows can still apply DST — which
  is why the app takes offsets from its own bundled database, not from Windows.
- A Wikipedia line about DST being "partially restored in Tehran in May 2025" refers to a change in
  government office hours, not a clock change; tzdb shows none.
- Iran's official Hijri calendar is sighting-based and can differ from Umm al-Qura by a day; hence
  the visible ±2-day adjustment.

## 5. Technical findings that shaped the architecture

- Flutter stable is 3.47.x (Dart 3.13.x); Impeller is the default renderer on Windows; first-party
  multi-window is still experimental → one window plus tray.
- `adhan_dart` 2.0.1 has Tehran and Jafari presets, but its "middle of the night" is Maghrib → Fajr
  and it applies the Maghrib angle only conditionally → in-house calculator with golden vectors.
- PrayTimes v2 is LGPL; PrayTime v3 is MIT. Our calculator is written from the published formulas
  and tested against our own reference, so neither licence applies.
- `flutter_local_notifications` supports Windows toasts, but on an unpackaged app `cancel` does not
  work and OS-side scheduling is undocumented → the app does its own timing and shows toasts
  immediately.
- `audioplayers` has a first-party Windows backend; `just_audio` does not.
- `win32` 6.4.0 lacks `SetWaitableTimer`, `CreateWaitableTimer` and `SetSuspendState` → hand-written
  FFI bindings.
- Wake from sleep: `SetWaitableTimer(fResume = TRUE)` works only while the process lives; a Task
  Scheduler task with `WakeToRun` survives app exit; both depend on the "Allow wake timers" power
  setting; after an automatic wake Windows re-sleeps in about two minutes unless the app calls
  `SetThreadExecutionState`. Whether a per-user task can be created without admin rights, and how
  Modern Standby devices behave, were **not verified** → M7.1 spike.
- Stale or abandoned packages to avoid: `system_tray`, `local_notifier`, `flutter_acrylic`, `isar`,
  `adhan`, `ntp` (2021), `golden_toolkit`, `sqlite3_flutter_libs`.

## 6. Sources

- PrayTimes: https://praytimes.org/docs/methods · https://praytimes.org/docs/calculation · https://github.com/zarrabi/praytime
- Time zones: https://github.com/eggert/tz/blob/main/asia · https://www.iana.org/time-zones · https://pub.dev/packages/timezone/changelog
- Windows Iran DST update: https://techcommunity.microsoft.com/blog/dstblog/iran-2023-time-zone-update-now-available/3805707
- DST in Iran: https://en.wikipedia.org/wiki/Daylight_saving_time_in_Iran
- Flutter: https://docs.flutter.dev/deployment/windows · https://flutter.dev/blog/whats-new-in-flutter-3-47
- Packages: https://pub.dev/packages/flutter_riverpod · /freezed · /window_manager · /tray_manager · /launch_at_startup · /windows_single_instance · /flutter_local_notifications · /audioplayers · /timezone · /shamsi_date · /hijri · /ntp_dart · /win32 · /very_good_analysis
- Windows power: https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-setwaitabletimer · https://learn.microsoft.com/en-us/windows/win32/taskschd/tasksettings-waketorun · https://learn.microsoft.com/en-us/windows/win32/api/powrprof/nf-powrprof-setsuspendstate · https://learn.microsoft.com/en-us/windows/win32/power/system-wake-up-events
- Comparable apps: https://github.com/Khiro95/Awqat-Salaat · https://github.com/apitlekays/Sajda · https://github.com/bdevgroup/miqaat · https://sourceforge.net/projects/adhanbox-windows/ · https://www.mawaqit.net/ · https://cafebazaar.ir/app/com.mobiliha.badesaba/
- Font: https://github.com/rastikerdar/vazirmatn (OFL-1.1)
