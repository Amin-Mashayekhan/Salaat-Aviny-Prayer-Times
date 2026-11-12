# Product

**Salaat | Aviny Prayer Times** is a calm, ad-free prayer-times and azan app for Windows. It knows the
prayer times of your city without the internet, plays the azan on time from the system tray, reminds you
beforehand and can wake the PC for an alarm. It is a rewrite, in Flutter, of the old *Aviny Prayer Times*
(اوقات شرعی آوینی) desktop program, without its daylight-saving bug.

Who it is for: primarily Persian-speaking Shia users in Iran on a desktop or laptop that is on most of the
day (Persian, right-to-left, Shamsi calendar, Tehran method by default); secondarily anyone who wants a
clean desktop azan app, in any of eight languages and with other calculation methods.

Platform: Windows 10 and 11, 64-bit. The code keeps all operating-system behaviour behind interfaces
(see [architecture.md](architecture.md)), but only the Windows runner exists today.

## Principles

1. **On time, every time.** A missed or wrong-hour azan is the worst failure. Correct time handling
   outranks every other concern: there is no daylight-saving logic of our own, and the schedule engine
   delivers each event exactly once ([prayer-times.md](prayer-times.md)).
2. **Offline first.** All calculation and all essential data are local. Without internet the whole app
   works, including the compass and the Iranian city list.
3. **Nothing to sell.** No account, no ads, no tracking, no telemetry. The device position is read only
   when you ask and is never stored.
4. **Explicit consent before any network use.** The network is used for four things only, each started by
   the user and announced in plain words first: the optional clock check (off by default), the qibla map
   pictures (the map is off until you switch it on), a place search (only when you press Search), and
   opening a web or mail link. See [adr/0006-place-search-and-offline-use.md](adr/0006-place-search-and-offline-use.md).
5. **Your choice sticks.** The app never changes a setting you did not change. It never sets the Windows
   clock, changes power settings or needs administrator rights.
6. **Quiet by default.** Notifications do not take keyboard focus; the azan can be stopped with one click
   from the window, the tray, the notification, or Esc.
7. **Focused.** Prayer times, azan, calendar, qibla, wake-up. Nothing else.

## What it does

### Prayer times and Home

- Nine events: Imsak, Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha and Islamic midnight. Fajr,
  Sunrise, Dhuhr, Maghrib and Midnight are always shown; Imsak (hidden by default), Asr, Sunset and Isha
  can be switched off in Settings.
- Home answers "what is next and how long is left?" in the largest type: a hero card with the countdown, the
  event and a day timeline; the list of today's times (tomorrow's after the last event) with a bell
  toggle per prayer; a status card (azan state and mute menu, reminders, qibla, next wake-up alarm); the
  three dates; previous/next-day arrows and a "today" button to look at another day.
- Banners above the hero, one at a time, dismissible: azan muted, PC clock off, Windows applies other
  time-zone rules than the bundled database, settings file was reset.
- Locations: a saved list with one active location, switched from Home or the tray; a built-in list of 566
  verified Iranian cities, custom locations (name, coordinates, height, time zone) and places found by
  online search. Time zone per location: automatic (bundled database, recommended) or a fixed offset in
  hours and minutes. The screen shows the offset in effect.

### Calculation methods

Tehran (Institute of Geophysics, the default), Jafari (Leva, Qom), Muslim World League, ISNA, Egypt,
Makkah, Karachi, or custom angles. Asr rule (standard or Hanafi), high-latitude rule (none, middle of the
night, one-seventh, angle-based), Imsak minutes before Fajr, Isha by angle or by minutes, Maghrib by angle
or at sunset, midnight rule, per-prayer offsets of up to 60 minutes either way, and a button that restores
the defaults of the chosen method. A live preview shows the effect.

### Azan and reminders

- Per prayer (Fajr, Dhuhr, Asr, Maghrib, Isha): on or off (Fajr, Dhuhr and Maghrib are on by default),
  sound (the bundled default or any audio file you choose) and volume; a master switch and volume, an
  optional fade-in, preview and stop.
- Reminders 0 to 60 minutes before the azan (10 by default for the prayers with an azan), as a
  notification that does not take focus, with an optional soft chime. Reminders and the azan are
  independent.
- Mute: until the next azan, for one hour, for 24 hours or until you turn it back on, from Home or the tray.
- The engine survives sleep, resume and clock changes; an azan that is due while the PC slept is played
  late only within a short window, otherwise a "was not played" notice appears.
- If the sound file is missing the default sound plays and a notice says so.

### Calendars and converter

Shamsi (Jalali), Hijri (adjustable by up to two days either way) and Gregorian dates shown together. A
month grid with a side panel for the chosen day, a date converter with three linked fields, and a monthly
timetable that can be shown by Shamsi, Hijri or Gregorian month; a row opens that day on Home.

### Qibla

- Compass tab (works offline): the bearing and distance to the Kaaba, a compass drawing with the qibla line
  and the sun's current direction, and the times when the sun stands in the qibla direction, with a short
  explanation of how to use them.
- Map tab (opt-in): street map (OpenStreetMap) or satellite imagery (Esri), the great-circle line and an
  arrow to the Kaaba. Measure from the prayer-times city, the device position (a "find my position" button)
  or any point (tap the map, type coordinates or search a place by name). Camera shortcuts show the whole
  route, the area around you, or the Kaaba. When the device position fails the page says why and shows
  step-by-step help with a button that opens the Windows location settings. Without internet the line and
  numbers still work and a banner says the map pictures could not be loaded.

### Wake-up alarms

Alarms that wake the PC from sleep, at a fixed time or a number of minutes before a prayer, once, daily or
on chosen weekdays, with a sound and volume and an optional return to sleep or hibernate afterwards behind a
cancellable 30-second countdown. "Sleep now" and "Hibernate now" buttons (5-second countdown), a self-test
that reports whether this PC allows wake timers and why not, and a "test in two minutes" alarm. The app only
reads power settings and opens the Windows Power Options page. See [adr/0005-wake-timers.md](adr/0005-wake-timers.md).

### Tray, notifications, start-up

Tray icon with a tooltip (next prayer, time, time left) and a menu (next prayer, today's times, stop azan
while playing, mute, location, show window, settings, quit). Closing the window hides it to the tray (a
setting, explained once). Start with Windows (hidden in the tray, optional), single instance (a second
launch brings the first window forward), keyboard shortcuts (Ctrl+1 to Ctrl+6, Ctrl+comma, Esc).

### First run

Three skippable steps: language; city (the offline Iranian list with province chips and search, or an
online search of any city in the world); azan preview and the start-with-Windows choice. Every setting has
a sensible default.

### Settings

Sections: Location, Calculation, Azan, Reminders, Time (optional network clock check: warns when the PC
clock is off by 30 seconds or more, can correct inside the app, never changes the Windows clock),
Display (theme light/dark/system, language, digit style, 12 or 24-hour clock, Hijri adjustment), App
(start with Windows, start minimised, close to tray, backup, restore, reset) and About. Changes apply at
once; a small tick confirms.

### About and diagnostics

Version, licence notes for the font and the bundled sounds, the developer's name and contact links, ways to
support the project (an Iranian bank card for Iran, USDT on BEP20 for everywhere, with the country each
works in), and how to contribute. Diagnostics: the next scheduled events with their UTC and local
instants, clock status, an audio test, the wake-up check, the log folder, and a "copy diagnostics" button
whose report contains no names and no coordinates.

### Eight languages

Persian (default), English, Arabic, Turkish, Urdu, Azerbaijani, Indonesian and French, switchable without
a restart. Persian, Arabic and Urdu are right-to-left. Digits: Persian, Latin or Arabic-Indic, chosen
independently of the language. City names exist in Persian and English only. See
[ui-guidelines.md](ui-guidelines.md).

## Non-goals

Ads. Accounts or cloud sync. Telemetry. A Quran reader or audio library. Social features. Payments or
locked features. Editing the built-in city database inside the app. Silent changes to power settings or the
Windows clock. Web and mobile builds are possible future work, not current goals ([../PROGRESS.md](../PROGRESS.md)).
