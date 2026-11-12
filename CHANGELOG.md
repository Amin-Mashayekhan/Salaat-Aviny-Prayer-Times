# Changelog

All notable changes to this project are written here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-11-12

First public release (Windows 10 and 11, 64-bit).

### Prayer times and azan
- Imsak, Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha and Islamic midnight with the Tehran
  (Institute of Geophysics) and Jafari (Leva, Qom) methods and five international methods.
- Azan sound and volume per prayer, reminders before the azan, quick mute, one-click stop, tray icon
  and notifications.
- No daylight-saving logic of its own: UTC offsets come from a bundled time-zone database or from a
  fixed offset chosen by the user, and the app never changes that choice.
- Wake-up alarms that can wake the PC from sleep.

### Dates
- Shamsi, Hijri (with manual adjustment) and Gregorian calendars, a date converter and a monthly
  timetable.

### Qibla
- Compass and the times the sun stands in the qibla direction.
- Map with a street style and a satellite style, the shortest path to the Kaaba, and three places to
  measure from: the chosen city, the device position (asked only on request) or any point, found by
  tapping the map, typing coordinates or searching a place by name.

### Choosing a place
- Offline list of Iranian cities, or search any city in the world online once; the app then keeps
  what it needs and works offline. The search box says what is sent where: the typed text to
  OpenStreetMap's search, and the coordinates of the chosen place to Open-Meteo for its time zone.
  Map pictures are never downloaded in bulk (16 MB cache at most).

### Command line
- `--minimized`, `--wake <id>` and `--page <home|timetable|calendar|qibla|wakeup|settings>` (open on a
  screen, for shortcuts).

### Languages
- Persian, English, Arabic, Turkish, Urdu, Azerbaijani, Indonesian and French, with right-to-left
  layout and matching digit styles. City names are shown in Arabic script for Persian, Arabic and
  Urdu. Translations other than Persian and English await a native speaker's review.

### About
- Developer information (name, GitHub, Telegram, e-mail, mobile with a note that calls and texts work only from Iran), the MIT licence, ways to support the project and how to contribute, with the countries each
  way of giving works from.
