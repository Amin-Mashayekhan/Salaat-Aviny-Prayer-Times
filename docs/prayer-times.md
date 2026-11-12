# Prayer times: time handling, calculation, scheduling, calendars, qibla

This is the part of the app that has to be exactly right. It describes the code as it is in
`packages/prayer_core` and `packages/owghat_lib`. The executable reference of the calculation is
`tools/reference/prayer_times_reference.py`; its output is stored in `seed/golden/prayer_times_golden.json`
(300 vectors) and `packages/prayer_core/test/golden_test.dart` checks the Dart code against it. If the Dart
code and the reference ever disagree, work out which one is wrong before changing either, and never edit the
golden file to make a test pass.

## 1. Time handling

The legacy problem this design exists to prevent: a program that applies its own daylight-saving rules on
top of the operating system's, and then overwrites the user's setting, shows prayer times that are an hour
off. The rules are:

1. **The calculator knows nothing about zones or daylight saving.** `PrayerCalculator.compute` takes the UTC
   offset of the civil date as an explicit input, like the latitude. It is a pure function.
2. **Everything scheduled is a UTC instant.** Azan, reminder, wake-up and rollover events are stored,
   compared and persisted as UTC `DateTime`s. Local times exist only for display.
3. **The UTC offset of a location comes from exactly one of two sources**, chosen per location and stored
   with it (`LocationOffset`):
   - `automatic`: the IANA zone id of the location (`Asia/Tehran` for every built-in city, a user-chosen id
     for a custom location), resolved with the time-zone database bundled by `package:timezone`. This is
     the default.
   - `fixed`: a number of minutes east of UTC typed by the user, from -720 to +840, valid on every day of
     the year.
4. **There is no daylight-saving switch, table or date range anywhere in our code or data.** A zone that
   has DST gets it from the IANA database. A user who distrusts the database chooses `fixed`.
5. **Code never writes a setting the user did not just change.** The offset rule is written only by
   `SettingsController.setLocationOffset`, called from the settings screen. Recalculation, date rollover,
   location loading and app start only read it. (See the settings guard test mentioned in
   [architecture.md](architecture.md).)
6. **Display uses the location's zone, not the Windows zone.** A user in Tehran whose Windows still applies
   the abolished Iranian DST rule sees correct Tehran times in the app. "Today" is the civil date at the
   location, derived from the current instant and the location's offset.
7. **One offset per civil date.** `ZoneOffsetResolver.offsetFor` returns the zone's offset at 12:00 local
   time of that date and uses it for every time of that day. It resolves this in two steps so that zones
   that change offset near midnight come out right: `o1` is the zone's offset at `DateTime.utc(y, m, d, 12)`;
   the result is the zone's offset at `DateTime.utc(y, m, d, 12) - o1`. For `fixed` it is the typed value.
   `ZoneOffsetResolver` is the only place that decides an offset.

### Iran

`Asia/Tehran` is UTC+03:30 on every date from 22 September 2022 onward (tzdata 2022b and later); earlier
years still contain the historical DST periods, which is correct when looking at past dates.
`owghat_lib/test/core/time/iran_has_no_dst_test.dart` asserts exactly 210 minutes for every day of every year
from 2023 to 2040 and that 2022 summer is still +04:30. It fails the build if a database older than 2022b is
ever bundled or if anyone adds DST logic.

### Clock sources and warnings

All code asks the injected `Clock` for "now" (see [architecture.md](architecture.md)).
`now = system clock + correction`.

- The correction is zero unless the user turned on "Correct with network time". Then the app measures the
  offset against an NTP server (default `pool.ntp.org`, three samples, the one with the lowest round trip
  wins) when the setting is enabled and every 6 hours. The measured offset is applied inside the app only
  when "apply correction" is also on. **The app never sets the Windows clock.**
- `evaluateClockWarning` produces the banner on the home screen (dismissible) and the details in the
  settings:
  - *Clock skew*: a network check found the PC clock off by 30 s or more.
  - *Stale Windows zone rules*: for a location on an automatic offset, the offset Windows applies now
    differs from the bundled database's offset for that location by exactly one hour. The text says the
    app's times are correct and the Windows clock is the one that is off. The same message is shown when
    the location is `Asia/Tehran` and the measured skew is one hour within 2 minutes, which is the same
    cause seen after the user "fixed" the clock by hand.

## 2. Calculator interface

```
PrayerTimes PrayerCalculator().compute({
  required CivilDate date,          // proleptic Gregorian year, month, day
  required double latitude,         // degrees, north positive
  required double longitude,        // degrees, east positive
  required Duration utcOffset,      // of that civil date (section 1, rule 7)
  required CalculationParams params,
  double elevationMeters = 0,
});
```

`CalculationParams`:

| Field | Default | Notes |
|---|---|---|
| `fajrAngle` | required | Sun depression below the horizon at Fajr, degrees. |
| `ishaAngle` / `ishaMinutes` | exactly one set | Isha at a depression angle, or a fixed number of minutes after Maghrib (Umm al-Qura: 90). |
| `maghribAngle` | null | Depression at Maghrib; null means Maghrib is sunset. |
| `midnight` | `standard` | `jafari`: sunset to the next Fajr. `standard`: sunset to the next sunrise. |
| `asr` | `standard` | Shadow factor 1 (`standard`) or 2 (`hanafi`). |
| `highLatitude` | `nightMiddle` | `none`, `nightMiddle`, `oneSeventh`, `angleBased`. Only matters where twilight is missing or very long (roughly above 48 degrees). |
| `imsakMinutes` | 10 | Imsak is Fajr minus this. |

The settings layer clamps what it loads and accepts: Fajr and Isha angle 5 to 30 degrees, Maghrib angle 0 to
10, Isha minutes 0 to 240, Imsak minutes 0 to 60. Custom locations accept latitudes up to 89.9 degrees and
elevations of 0 to 9000 m.

Result: nine times (`imsak, fajr, sunrise, dhuhr, asr, sunset, maghrib, isha, midnight`), each a nullable
`Duration` after local midnight of `date`. `null` means the event does not occur that day at that place
(polar day or night). Midnight is normally between about 22 h and 25 h, and Isha at high latitudes can also
exceed 24 h, which means after 00:00 of the next civil day (58 of the 300 golden vectors have such a value).
Never wrap these to 0-24 h before turning them into instants; wrap only when formatting a clock time
(`minuteOfDay`).

### Built-in methods

| id | Fajr | Isha | Maghrib | Midnight |
|---|---|---|---|---|
| `tehran` (Institute of Geophysics, University of Tehran) | 17.7 | 14 | 4.5 | jafari |
| `jafari` (Shia Ithna-Ashari, Leva Institute, Qom) | 16 | 14 | 4 | jafari |
| `mwl` (Muslim World League) | 18 | 17 | sunset | standard |
| `isna` (Islamic Society of North America) | 15 | 15 | sunset | standard |
| `egypt` (Egyptian General Authority of Survey) | 19.5 | 17.5 | sunset | standard |
| `makkah` (Umm al-Qura University) | 18.5 | 90 min after Maghrib | sunset | standard |
| `karachi` (University of Islamic Sciences, Karachi) | 18 | 18 | sunset | standard |
| `custom` | user | user | user | user |

The factory default is `tehran`. `SettingsController.applyMethod` copies a method's numbers into the
parameters but keeps the user's Asr rule, high-latitude rule and Imsak minutes. The displayed method is
derived: `CalculationMethod.matching(params)` returns the built-in method whose parameters are equal, or
`custom`, so editing any angle turns the method into `custom` without anyone writing that down.

## 3. Algorithm

All trigonometry is in degrees. `fix(x, m)` reduces `x` into `[0, m)`.

### 3.1 Julian day

For Gregorian `(Y, M, D)`: if `M <= 2` then `Y -= 1, M += 12`. `A = floor(Y/100)`,
`B = 2 - A + floor(A/4)`,
`JD = floor(365.25 (Y + 4716)) + floor(30.6001 (M + 1)) + D + B - 1524.5` (this is 00:00 UT).
The working day number is `jd = JD - longitude / (15 * 24)`.

### 3.2 Sun position at `jd + t` (t = fraction of a day)

Low-precision USNO formulas, about one arc-minute between 1950 and 2050:

```
d    = (jd + t) - 2451545.0
g    = fix(357.529 + 0.98560028 d, 360)
q    = fix(280.459 + 0.98564736 d, 360)
L    = fix(q + 1.915 sin g + 0.020 sin 2g, 360)
e    = 23.439 - 0.00000036 d
RA   = fix(atan2(cos e sin L, cos L) / 15, 24)
decl = asin(sin e sin L)
EqT  = q/15 - RA                         // hours
```

### 3.3 Building blocks

```
midDay(t)            = fix(12 - EqT(jd + t), 24)
angleTime(a, t, dir) : x = (-sin a - sin decl sin lat) / (cos decl cos lat)     // decl at jd + t
                       if x < -1 or x > 1 -> null
                       h = acos(x) / 15
                       return midDay(t) - h (before noon) or midDay(t) + h (after noon)
asrTime(f, t)        = angleTime(-acot(f + tan|lat - decl|), t, after noon)      // f = 1 or 2
horizon              = 0.833 + 0.0347 sqrt(elevationMeters)
```

`a` is the depression angle below the horizon (positive means below).

### 3.4 One day, in the "UT + longitude/15" frame

Start values (fractions of a day): fajr 5/24, sunrise 6/24, dhuhr 12/24, asr 13/24, sunset 18/24, maghrib 18/24,
isha 18/24. Repeat **exactly three times** (fixed so the result is deterministic):

```
fajr    = angleTime(fajrAngle,    t.fajr,    before noon)
sunrise = angleTime(horizon,      t.sunrise, before noon)
dhuhr   = midDay(t.dhuhr)
asr     = asrTime(shadowFactor,   t.asr)
sunset  = angleTime(horizon,      t.sunset,  after noon)
maghrib = angleTime(maghribAngle, t.maghrib, after noon)     // only if maghribAngle != null
isha    = angleTime(ishaAngle,    t.isha,    after noon)     // only if ishaAngle != null
for each non-null result: t.x = result / 24
```

### 3.5 High-latitude adjustment

Skipped when `highLatitude == none` or when sunrise or sunset is null. Otherwise:

```
night = fix(sunrise - sunset, 24)
portion(angle) = night/2             (nightMiddle)
               | night/7             (oneSeventh)
               | angle/60 * night    (angleBased)

fajr:    if fajr is null or fix(sunrise - fajr, 24) > portion(fajrAngle)  -> fajr = sunrise - portion(fajrAngle)
isha:    only if ishaAngle != null; if isha is null or fix(isha - sunset, 24) > portion(ishaAngle)
                                                                         -> isha = sunset + portion(ishaAngle)
maghrib: only if maghribAngle != null; same rule with maghribAngle and base sunset
```

The rule applies to every high-latitude choice, not only angle-based; the choice only changes the size of
the portion.

### 3.6 Finishing

```
if maghribAngle == null : maghrib = sunset
if ishaAngle == null    : isha = maghrib + ishaMinutes/60          (null if maghrib is null)
shift = utcOffsetHours - longitude/15;   add shift to every non-null time
imsak = fajr - imsakMinutes/60                                      (null if fajr is null)
midnight (only if sunset is not null):
    run 3.4-3.5 for date + 1 day; end = that day's fajr (jafari) or sunrise (standard); skip if null
    midnight = sunset + ((end + shift + 24) - sunset) / 2
```

(`sunset` in the midnight formula already includes `shift`.)

### 3.7 What the app does on top (`computePrayerDay`)

In this order:

1. **Per-prayer offsets.** A signed whole number of minutes, -60 to +60 (default 0), added to each of the
   nine times.
2. **Rounding.** To the nearest minute, half up (`floor(minutes + 0.5)`), not wrapped to 24 h. The azan
   fires at the rounded minute, at second 00, so the clock on screen and the sound agree.
3. **Instants.** `instant = localMidnightUtc(date) + roundedDuration`, where
   `localMidnightUtc(date) = DateTime.utc(y, m, d) - utcOffset`. Null times produce no instant.

The golden test requires every vector's nine unrounded values to be within 1 second of the reference and the
rounded `HH:mm` to be exactly equal. An independent comparison of Tehran, method `tehran`, with a public
third-party calculator on four dates in 2026 agreed within 1.1 minutes (rounding only). Do not tune the
algorithm to match any other source.

### 3.8 Which rows are shown

`DisplaySettings` decides: Imsak (off by default), Asr, Isha and Sunset (on by default); Fajr, Sunrise,
Dhuhr, Maghrib and Midnight are always shown. "Next prayer" (`computeNextPrayer`) looks at yesterday, today
and tomorrow, keeps only the rows that are shown, and returns the latest instant already passed, the first
one still to come and the time remaining; after the last event of a day the next one is tomorrow's first.
Only the five prayers `fajr, dhuhr, asr, maghrib, isha` (`Prayer.hasAzan`) can have an azan.

## 4. Scheduling engine

Code: `prayer_core/lib/src/schedule` (events, builder, catch-up policy, pure Dart) and
`owghat_lib/lib/src/features/scheduler` (`ScheduleEngine`, plain Dart; the Riverpod wiring is in
`scheduler_providers.dart`; `AppScheduleDispatcher` carries events out).

### 4.1 Events

```
ScheduledEvent { kind, instantUtc, date, prayer?, alarmId?, relatedInstantUtc? }
EventKind = azan | reminder | wakeAlarm | dayRollover
id        = "<kind>:<prayer name | alarm id | day>:<yyyy-MM-dd>"      // date = civil date in the location
```

`buildScheduleEvents` builds events for today and tomorrow from the current settings. Only enabled items
produce events: an azan needs the master switch and the prayer's own switch; a reminder is
`azanInstant - minutes` and exists only when its azan is enabled and the minutes are greater than zero.
Alarms come from the wake-up feature. A `dayRollover` marker is placed at 00:00:05 local time of tomorrow
and of the day after, and rebuilds the schedule. The result is sorted by instant, then kind, then id.

### 4.2 Running

- One timer is armed for the nearest unhandled future event (never longer than one hour, never shorter than
  one millisecond). When it fires, every due event is handled and the timer is armed again.
- **Rebuild triggers:** engine start, any settings change, a change of the clock correction, a change of
  the wake-up occurrences or bookkeeping, a day rollover, any power event other than "suspending" (resume,
  Windows time change), and the watchdog. Rebuilding only reads state and is idempotent, so a coarse
  trigger is fine.
- **Watchdog:** every 15 s the engine compares elapsed wall-clock time with elapsed monotonic time (a
  `Stopwatch`). A difference above 5 s means the clock was changed or the PC slept, and the schedule is
  rebuilt.
- **Exactly once:** the id of every handled event is recorded in memory and in `state.json` (key
  `handledEvents`) and pruned after 3 days. The id is recorded before dispatch, so an event is never
  handled twice, even across restarts, and a failing dispatcher cannot cause a replay.

### 4.3 Catch-up policy

`CatchUpPolicy.decide` for an event whose time has passed, with `lateness = now - instant`. Up to 5 seconds
late counts as on time.

| Kind | Decision |
|---|---|
| `azan` | on time: `fire`; late by at most 3 minutes: `fireLate` (plays); later: `notifyMissed` (a quiet "missed" notification with the time, no sound) |
| `reminder` | if its azan is no longer in the future: `drop`; otherwise `fire` or `fireLate`, and the text shows the true remaining time, not the configured lead |
| `wakeAlarm` | on time: `fire`; late by at most 10 minutes: `fireLate`; later: `drop` |
| `dayRollover` | always `fire` (it triggers a rebuild and is never dispatched) |

`decideAll` adds one rule: of all azans that would play, only the most recent one plays; earlier ones become
`notifyMissed`. Azans are never played back to back.

On the first pass after start-up the engine turns every `notifyMissed` into a silent `drop`: after a cold
start it cannot know whether the PC was on earlier, so it must not announce old azans as missed. After a
resume or a clock change it does announce them.

### 4.4 Dispatching

`ScheduleDispatcher.dispatch` must not throw for ordinary failures. `AppScheduleDispatcher`:

- **Azan:** `notifyMissed` shows the quiet notice. Otherwise, if the master and prayer switches are on and
  the quick mute is not active, it plays the prayer's sound (master volume times prayer volume, optional
  2-second fade-in) and shows a notification with a Stop button. A sound that cannot be played falls back to
  the bundled default azan with a notice; if nothing plays, a failure notice is shown. A muted azan still
  gets its notification, without Stop.
- **Reminder:** a notification with the remaining minutes and, if enabled and not muted, a short chime.
- **Wake alarm:** handed to `WakeAlarmController` (see [architecture.md](architecture.md)); it returns
  immediately so a long alarm never blocks the azan schedule.
- A failing audio device still leaves the notification, and a failing notification never blocks the sound.

### 4.5 Quick mute

`MuteSetting` is a timed or indefinite flag. "Mute until the next azan" sets `until` to the next enabled
azan instant plus 4 minutes (so an azan that fires up to the 3-minute catch-up grace late is still skipped),
or to 24 hours when no azan is enabled. Expiry is evaluated against the clock when the value is read; nothing
is written back when a mute runs out.

## 5. Calendars

- **Gregorian** is the truth; the other two are derived from it (`TriDate`).
- **Jalali (Shamsi):** `package:shamsi_date`. The week starts on Saturday. Supported years 1079 to 1778
  (checked constructors; Gregorian 1700 to 2400).
- **Hijri:** `package:hijri` (Umm al-Qura table), plus a user adjustment of -2 to +2 days (default 0). The
  adjustment shifts the Gregorian date by that many days before conversion, and is removed again when
  converting from a Hijri date. A date outside the package's table has no Hijri value. Iran's official lunar
  calendar follows moon sighting and often differs from Umm al-Qura by a day, which is why the control
  exists. Hijri month lengths come from the table; day 30 of a 29-day month is rejected, not rolled over.
- Weekday and month names come from the ARB files.
- **Converter:** any of the three calendars to the other two plus the weekday. Persian and Arabic-Indic
  digits are accepted; impossible dates (month 13, 31 Esfand in a common year) are errors, never rolled
  into the next month.

Anchors used by the tests: 1 Farvardin 1405 is 21 March 2026 (a Saturday); 1 Farvardin 1404 is 21 March
2025 (a Friday); 30 Esfand 1403 exists (1403 is a leap year; it is 20 March 2025); 11 November 2026 is
20 Aban 1405 and 1 Jumada al-Thani 1448.

## 6. Qibla and the sun

Code: `prayer_core/lib/src/qibla`.

- **Bearing** (degrees clockwise from true north), Kaaba at 21.422487 N, 39.826206 E:
  `fix(atan2(sin(dLon), cos(lat) tan(latK) - sin(lat) cos(dLon)), 360)` with `dLon = lonK - lon`.
  Tehran (35.6892, 51.3890) gives 218.4 degrees; the golden file has more.
- **Distance:** great circle, haversine, Earth radius 6371.0088 km.
- **Sun azimuth and altitude** at a UTC instant, from `decl` and `EqT` of section 3.2:
  `H = 15 (utcHours + lon/15 + EqT - 12)`; `alt = asin(sin lat sin decl + cos lat cos decl cos H)`;
  `az = fix(atan2(-sin H, tan decl cos lat - sin lat cos H), 360)`.
- **Sun on the qibla line:** for the local civil day, scan from local midnight in one-minute steps and look for
  a sign change of the azimuth difference to the target, where both samples are within 90 degrees of it (this
  skips the wrap-around at 180 degrees), refine by bisection to one second, and accept the crossing only if the
  sun's altitude is above 0. The target is the bearing (the sun stands in the qibla direction) or bearing + 180
  (the sun is opposite, so a shadow points to the qibla). Either result can be null.
- **Map line:** `greatCircleToKaaba` returns 65 points along the great circle that leaves the start in the
  qibla direction, with longitudes unwrapped so a path crossing the antimeridian stays one line on a flat map.
  The map is optional and opt-in: no tile is requested until the user presses "Show the map".
- `parseCoordinates` reads a typed "lat, lon" pair (Latin, Persian or Arabic-Indic digits, Arabic decimal
  mark and comma) and returns null for anything invalid.

## 7. Wake-up alarms: times

The type is `WakeAlarm { id, label, enabled, trigger, repeat, sound, volume, afterSound, ... }` with:

- `trigger`: `fixedTime` (hour and minute in the location's zone, using that date's offset) or
  `relativeToPrayer` (a prayer and 0 to 720 minutes before it, recomputed every day from the prayer time);
- `repeat`: `once`, `daily` or `weekdays` (a set of ISO weekdays; the weekday is that of the day the alarm
  rings);
- `afterSound`: `nothing`, `sleep` or `hibernate`.

`nextOccurrence` searches from the previous civil day (Isha or midnight can fall after 24:00 of the day that
computed it) up to 14 days ahead. The OS is asked to wake the PC 30 seconds before the alarm, and no request
is made when that wake time is less than 10 seconds away (the PC is awake anyway). A late alarm is run within 10 minutes of its time and dropped after that (the
catch-up policy above). A `once` alarm switches itself off after it fires. How the PC is actually woken and
put back to sleep is described in [architecture.md](architecture.md).
