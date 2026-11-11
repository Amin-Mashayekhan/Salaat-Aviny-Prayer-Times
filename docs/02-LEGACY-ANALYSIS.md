# 02 — Legacy Analysis: "Aviny Prayer Times" v1.0.8.6 (2013)

This is what the old Windows app does, how it does it, and what is wrong with it. It was produced by
static analysis (IL disassembly of `Prayer_Win.exe`, decoding of its data files). Nothing here was
guessed from screenshots; where something could not be confirmed it says so.

The new app must cover every feature in section 3 (the parity checklist) and must not reproduce any
bug in section 5.

## 1. What was analysed

| File | What it is |
|---|---|
| `PrayerTimes.exe` | Installer (Tarma InstallMate 7). Not relevant to the rewrite. |
| `Prayer_Win.exe` | The app. .NET Framework 2.0, WinForms, x86, not obfuscated. 36 types. |
| `Microsoft.Win32.TaskScheduler.dll` | Open-source Task Scheduler wrapper, used for the wake-up task. |
| `Countries_Enc.xml`, `Provinces_Enc.xml`, `Cities_Enc.xml` | Location DB. Encoding: Base64 of UTF-8 of the XML with every character XOR 129. |
| `Azan_Voice/*.mp3` | Two azan recordings. `Kazemzade.mp3` is the default for every prayer. |
| `Prayer_Win.exe.config` | Default values of the 23 user settings. |

Legacy code layout: one 21,000-line `Form1` holds almost all logic (UI, scheduling, settings, Task
Scheduler, registry). Helper classes: `PT_Compute` (prayer math, static mutable state), `City`,
`Qibla`, `SunCalc`, `GSDate` (Jalali conversion), `NTPClient`, `MP3Player` (MCI via `winmm.dll`),
`Announcing` (reminder popup), `WakeUp`, `Cryptography` (the XOR codec).

## 2. Legacy data

Decoded and cleaned copies are in `seed/locations/` (script: `tools/legacy/decode_legacy_locations.py`).

| Table | Rows | Notes |
|---|---|---|
| Country | 321 | Persian + English name, one fixed UTC offset per country, `Daylight` Y/N, `Daylight_Begin`, `Daylight_End`. |
| Province | 31 | Iran only. English names existed for 2 of 31; two Persian names were misspelled. Fixed in the seed. |
| City | 972 | 767 Iranian, 205 foreign (mostly capitals). Coordinates in degrees + minutes (about 1.8 km resolution). `Type` capital / province centre / normal. `Approved` Y/N. |

Data problems found and how the seed handles them:

- 25 Iranian cities appear twice (province centre plus a plain row a few km away). Seed keeps one.
- 175 Iranian rows are unapproved and most have a Latin string in the Persian-name column. Seed keeps them with `verified: false`. **The app ships only `verified: true` rows (567 cities).**
- 1 Iranian row has no province (`Emamzadeh 'Abdollah`); it stays `province_id: null`.
- 1 foreign row has coordinates 0,0. Dropped.
- Iran's country row says `Daylight = Y`, `1390/01/01` to `1390/06/30`. This is the data half of bug B-01. **The seed drops the three daylight columns entirely.**

## 3. Feature inventory (parity checklist)

Every item needs an equivalent in the new app. The right column names the new feature ID from
`01-PRODUCT-SPEC.md`.

| ID | Legacy feature | New |
|---|---|---|
| L-01 | Pick location by country → province → city, with a city-name search box. Last selection saved by name. | F-03 |
| L-02 | "Custom" mode: type latitude/longitude in degrees-minutes-seconds with hemisphere, pick UTC offset from a fixed list, pick DST yes/no. Converters between DMS and decimal. | F-03, F-05 |
| L-03 | Shows six times for the day: اذان صبح, طلوع آفتاب, اذان ظهر, غروب آفتاب, اذان مغرب, نیمه شب شرعی. No Asr, no Isha. | F-02 |
| L-04 | Highlights the next event in green and shows a live `HH:MM:SS` countdown "زمان باقی مانده تا …". | F-02 |
| L-05 | Shows the date in Shamsi, Gregorian and Hijri; each can be edited to view another day. "خودکار" checkbox snaps back to today. Hijri adjustment in days (default −1). | F-11 |
| L-06 | Monthly table for the current Shamsi month: weekday, date, the six times, Gregorian date, sun-on-qibla time. | F-12 |
| L-07 | Qibla panel: bearing, compass text (شمال …), drawing with the sun's current direction, and "زمان مقارنه/مقابله خورشید و قبله" (the time today when the sun stands exactly in, or exactly opposite, the qibla direction). | F-13 |
| L-08 | Azan playback at Fajr, Dhuhr and Maghrib. Master switch, per-prayer switch, per-prayer audio file, play/stop preview, volume slider. | F-06 |
| L-09 | Reminder popup N **seconds** before the azan (default 120), topmost, with countdown and a stop button. | F-07 |
| L-10 | Calculation method: Tehran (default), Jafari/Leva-Qom, MWL, ISNA, Egypt, Makkah, Karachi; Fajr and Maghrib angles are editable. | F-04 |
| L-11 | "Get time from time servers" (NTP, `0.pool.ntp.org`), off by default. | F-15 |
| L-12 | Tray icon. Minimise hides to tray; closing the window minimises instead of exiting; tray menu lists today's six times and Exit; balloon tip on minimise. | F-09 |
| L-13 | "Run at Windows startup" via `HKCU\…\Run`, value `"<exe>" /startminimized`. | F-10 |
| L-14 | Wake-up: a Task Scheduler task `AvinyPrayerTimesWakeUp` with "wake the computer", once or daily at HH:MM. Options: play a sound on wake, then put the PC back to sleep or hibernate when the sound ends. Buttons "sleep now", "hibernate now", and "40 minutes before Fajr" (fills the wake time). | F-14 |
| L-15 | Editing screens for countries, provinces and cities (add / change / delete rows of the DB). | F-03 (custom locations only) |
| L-16 | About box, link to aviny.com, "this program is free" notice. | F-18 |

Legacy settings and defaults (`user.config`): Country, Province, City (names) · TimeServer
`0.pool.ntp.org` · LoadFromNTP `false` · BeforeAzanAnnouncing `120` (seconds) · PlayAzan `true` ·
PlayImsaak / PlayNoon / PlayMaghreb `true` · Volume `500` (scale 0–1000) · Adjust_Hijri `-1` ·
PlayImsaakFile / PlayNoonFile / PlayMaghrebFile / PlayWakUpFile (empty → `Azan_Voice\Kazemzade.mp3`) ·
WakeUpHour `0`, WakeUpMinute `0`, WakeUpEnabled `false`, PlayOnWakeUp `true`, WakeUpInterval `Once`,
WakeUpSleepAgain `true`, WakeUpSleepAgainMode `Hibernate` · CalculatingMethod `Tehran`.

There is **no** setting key for the DST choice, the UTC offset, or custom coordinates.

## 4. Legacy algorithm

`PT_Compute.Compute` is a low-precision almanac method evaluated once at local noon:

- `T` = Julian centuries; mean anomaly `M = 357.528 + 35999.05·T`; centre `C = 1.915·sin M + 0.020·sin 2M`;
  longitude `L = 280.46 + 36000.77·T + C`; `α = L − 2.466·sin 2L + 0.053·sin 4L`;
  obliquity `ε = 23.4393 − 0.013·T`; declination `δ = atan(tan ε · sin α)`; equation of time `(L − C − α)·4` minutes.
- Noon = `720 − 4·(longitude − 15·utcOffset) − EoT` minutes, **plus 60 if `Daylight == "Y"`**.
- Sunrise/sunset at altitude −0.8333°. Fajr at `−ImsaakDegree` (17.7 for Tehran). Maghrib at `−MaghrebDegree` (4.5).
- Midnight = midpoint of sunset and (the same day's) Fajr + 24 h.
- Methods table (Fajr / Maghrib degrees): Tehran 17.7 / 4.5 · Jafari 16 / 4 · MWL 18 / 0.833 · ISNA 15 / 0.833 · Egypt 19.5 / 0.833 · Makkah 18.5 / 0.833 · Karachi 18 / 0.833.

Measured: the new reference algorithm (`tools/reference/prayer_times_reference.py`) differs from
this legacy formula by at most 49 seconds over a full year for four Iranian cities, so users will
see the same minute or the adjacent one. The legacy field named "Imsaak" is actually Fajr.

## 5. Bugs in the legacy app (the new app must not have these)

### B-01 — Times jump by one hour for half the year, and the DST switch re-enables itself (the user's main complaint)

Root cause, confirmed in the IL of `Form1.BindData` and `Form1.timer1_Tick`:

1. The country row for Iran carries `Daylight = Y`, begin `1390/01/01`, end `1390/06/30`.
2. Both `BindData` (runs on start and on every city change) and `timer1_Tick` (runs every second)
   contain: *if the country has `Daylight = Y` and today's day-of-year is between begin and end,
   set the DST dropdown to "Y", otherwise to "N"*. `PT_Compute` then adds 60 minutes when it is "Y".
3. The tick does this whenever the date changed **or the flag `NeedToUpdatePrayerTime` is set**.
   The DST dropdown's own change handler sets `NeedToUpdatePrayerTime = true`. So when the user
   switches DST to "No", the next tick (≤ 1 second later) recomputes from the country table and
   puts it back to "Yes".
4. The user's choice is not stored anywhere (no setting key), so even without step 3 it would be
   lost on restart.

Iran abolished daylight saving time: the last DST period ended on 21 September 2022 and there has
been no clock change since 1 Farvardin 1402 (21 March 2023). The app therefore shows every time one
hour late from 1 Farvardin to 30 Shahrivar, and the user cannot turn it off.

Required behaviour in the new app: see "Time model" in `04-DOMAIN-SPEC.md`. In short: no DST table
of our own, no DST checkbox, UTC offsets come from the IANA time-zone database or from a fixed
offset the user typed, and a stored user choice is never overwritten by code.

### Other bugs and weaknesses

| ID | Problem | Consequence |
|---|---|---|
| B-02 | The azan is started by the reminder popup's timer, not by the scheduler. If the reminder is set to 0 seconds, or the user closes the popup more than 50 s before the time, no azan plays. | Azan silently skipped. |
| B-03 | Trigger is "remaining time ≤ 2 s" polled by a 1 s UI timer. No handling of sleep/resume, clock changes or a busy UI thread. | Azan missed after sleep; can fire up to 2 s early. |
| B-04 | Which prayer is next is passed around as a Persian display string and matched with `Contains("صبح")`. | Fragile; breaks with any wording or language change. |
| B-05 | One fixed UTC offset per country, from a hard-coded list. | Wrong for countries with several zones or real DST. |
| B-06 | DST window test compares day-of-year of dates in the year 1390 with today's day-of-year. | Off by a day in leap years. |
| B-07 | `PT_Compute` writes results into static fields. | Not safe for concurrent use; the monthly table and the live view share state. |
| B-08 | No Asr or Isha times; no per-prayer minute offsets; no high-latitude handling (`acos` of an out-of-range value gives NaN). | Incomplete, crashes or garbage at high latitudes. |
| B-09 | With "time from NTP" on, the tick handler takes an early branch that skips the countdown / reminder / azan block (it only refreshes the clock and then handles wake-up). The NTP class can also set the Windows clock (`SetLocalTime`). | Could not confirm at runtime; treat NTP mode as unreliable. The new app never changes the system clock. |
| B-10 | Wake-up task is registered as `SYSTEM` with highest privileges and runs `ping` as a dummy action, so it needs admin rights ("برنامه را با دسترسی مدیر اجرا نمایید"). It also silently edits the power plan with `powercfg` to allow wake timers. | Needs elevation; changes system settings without asking. |
| B-11 | Custom coordinates and the UTC-offset choice are not persisted. | Lost on restart. |
| B-12 | Errors are shown with blocking `MessageBox` calls from timers. | A failed audio file can freeze the schedule until the box is dismissed. |
| B-13 | Text bugs: "اذان مفرب" (should be مغرب), "ا نتخاب شده". Volume stored on a 0–1000 scale. | Cosmetic. |
| B-14 | The same azan file is used for all prayers by default, including Fajr. | No separate Fajr azan. |

## 6. Deliberately not carried over

- In-app editing of the country / province / city master tables (L-15). Replaced by user-defined custom locations stored in settings.
- The XOR "encryption" of data files and the Encrypt / Decrypt / Generate-key buttons.
- Setting the Windows clock from NTP.
- Registering tasks as `SYSTEM` and changing the power plan without consent.
- The bundled azan recordings. Their licence is unknown; see open question Q-2 in `06-IMPLEMENTATION-PLAN.md`.
