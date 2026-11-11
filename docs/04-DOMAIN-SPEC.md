# 04 — Domain Spec: time model, prayer-time algorithm, scheduling, calendars, qibla

This is the part of the app that must be exactly right. It is written so that it can be ported
line by line. The executable form of sections 2–4 is `tools/reference/prayer_times_reference.py`;
the expected outputs are in `seed/golden/prayer_times_golden.json` (300 vectors).

If this document and the Python reference ever disagree, the Python reference wins and this
document gets fixed.

## 1. Time model (this is the fix for legacy bug B-01)

### 1.1 Rules

- **T-1. The calculator never knows about DST or time zones.** `PrayerCalculator` takes an explicit
  `utcOffset` as an input, like latitude. It is a pure function.
- **T-2. Every scheduled thing is a UTC instant.** Azan, reminder and wake-up events are stored and
  compared as UTC `DateTime`s. Local times exist only for display.
- **T-3. The UTC offset of a location comes from exactly one of two sources**, chosen per location
  and stored with it:
  - `automatic` — the IANA zone id of the location (for example `Asia/Tehran`) resolved with the
    time-zone database bundled in the app (`package:timezone`). Default.
  - `fixed` — a number of minutes east of UTC typed by the user (range −720…+840, step 15).
    It applies on every day of the year.
- **T-4. There is no DST switch, no DST table and no DST date range anywhere in our code or data.**
  If a zone has DST, the IANA database handles it. If the user distrusts it, they choose `fixed`.
- **T-5. Code never writes a setting the user did not just change.** The offset mode and value are
  only written by the settings screen's explicit action. Recalculation, date rollover, city reload
  and app start read them and never write them.
- **T-6. Display uses the location's zone, not the Windows zone.** A user in Tehran whose Windows
  still applies the abolished DST rule sees correct Tehran times in the app.
- **T-7. The offset for a civil date is the zone's offset at 12:00 local time of that date**, used
  for all times of that day. Resolve it in two steps: `o1` = the zone's offset at
  `DateTime.utc(y, m, d, 12)`; result = the zone's offset at `DateTime.utc(y, m, d, 12) − o1`.

### 1.2 Iran

`Asia/Tehran` is UTC+03:30 on every date from 22 September 2022 onward (tzdata 2022b and later).
Before that date the database still contains the historical DST periods, which is correct for
viewing past dates.

Mandatory regression test `iran_has_no_dst_test.dart`: for every year 2023…2040 and every day from
20 March to 25 September, `offsetFor('Asia/Tehran', date)` equals exactly 210 minutes. This test
must also fail the build if someone bundles a tz database older than 2022b.

### 1.3 Clock sources

All code obtains "now" from an injected `Clock` (never `DateTime.now()` directly), so tests can
control time. `now = systemUtcNow + clockCorrection`.

- `clockCorrection` is zero unless the user enabled **"Correct with network time"** (F-15). When
  enabled, the app queries NTP at start and every 6 hours; the measured offset is stored in memory
  and applied. The app **never sets the Windows clock**.
- Diagnostics (shown as a dismissible banner on the home screen and in Settings → Time):
  - **D-1 clock skew**: an NTP check found `|offset| ≥ 30 s`. Text: the PC clock is off by N; offer to enable correction.
  - **D-2 stale Windows zone rules**: the Windows local UTC offset differs from the bundled
    database's offset for the *same* zone as the selected location. Text explains that Windows is
    using outdated daylight-saving rules, that the app's times are still correct, and that the
    Windows clock is one hour off. (Typical: unpatched Windows still applying Iran DST.)
  - An offset of 3600 ± 120 s in D-1 together with an Iranian location gets the D-2 wording too,
    because it is the same cause seen after the user "fixed" the clock by hand.

## 2. Inputs and outputs of the calculator

```
PrayerTimes compute({
  required CivilDate date,          // year, month, day (proleptic Gregorian)
  required double latitude,         // degrees, north positive, −89.9…+89.9
  required double longitude,        // degrees, east positive, −180…+180
  double elevationMeters = 0,       // ≥ 0
  required Duration utcOffset,      // of that civil date, from T-3
  required CalculationParams params,
});
```

`CalculationParams`:

| Field | Type | Default (Iran) | Notes |
|---|---|---|---|
| `fajrAngle` | degrees | 17.7 | Sun depression at Fajr. |
| `maghribAngle` | degrees or null | 4.5 | null means Maghrib = sunset. |
| `ishaAngle` | degrees or null | 14.0 | null when `ishaMinutes` is used. |
| `ishaMinutes` | minutes or null | null | Isha = Maghrib + minutes (Umm al-Qura: 90). |
| `midnight` | `jafari` / `standard` | `jafari` | `jafari`: sunset → next Fajr. `standard`: sunset → next sunrise. |
| `asr` | `standard` / `hanafi` | `standard` | Shadow factor 1 or 2. |
| `highLatitude` | `none` / `nightMiddle` / `oneSeventh` / `angleBased` | `nightMiddle` | Only matters above about 48° latitude. |
| `imsakMinutes` | minutes | 10 | Imsak = Fajr − minutes. |

Output: nine nullable values, each a `Duration` after local midnight of `date`:
`imsak, fajr, sunrise, dhuhr, asr, sunset, maghrib, isha, midnight`. `midnight` is usually between
22 h and 25 h; it, and at high latitudes also `isha`, may be past 24 h, meaning after 00:00 of the
next civil day (58 of the 300 golden vectors have such a value). Never wrap these to 0–24 h before
converting to an instant; wrap only when formatting a clock time. `null` means the event does not
occur on that date at that place (polar day / night).

### Built-in methods

| id | Persian label (from legacy) | Fajr | Isha | Maghrib | Midnight |
|---|---|---|---|---|---|
| `tehran` | موسسه ژئوفیزیک دانشگاه تهران | 17.7° | 14° | 4.5° | jafari |
| `jafari` | شیعه اثنی‌عشری، موسسه لواء، قم | 16° | 14° | 4° | jafari |
| `mwl` | مجمع جهانی اسلامی | 18° | 17° | sunset | standard |
| `isna` | جامعه اسلامی آمریکای شمالی | 15° | 15° | sunset | standard |
| `egypt` | هیئت عمومی مساحی مصر | 19.5° | 17.5° | sunset | standard |
| `makkah` | دانشگاه ام‌القری، مکه | 18.5° | 90 min after Maghrib | sunset | standard |
| `karachi` | دانشگاه علوم اسلامی کراچی | 18° | 18° | sunset | standard |
| `custom` | سفارشی | user | user | user | user |

Default method: `tehran` when the location's country is Iran, otherwise `mwl`. Choosing a built-in
method copies its numbers into the params; editing any number switches the method id to `custom`.

## 3. Algorithm

All trigonometry is in degrees. `fix(x, m)` reduces `x` into `[0, m)`.

### 3.1 Julian day

For Gregorian `(Y, M, D)`: if `M ≤ 2` then `Y −= 1, M += 12`.
`A = floor(Y/100)`, `B = 2 − A + floor(A/4)`,
`JD = floor(365.25·(Y + 4716)) + floor(30.6001·(M + 1)) + D + B − 1524.5`.

The working day number is `jd = JD − longitude / (15·24)`.

### 3.2 Sun position at `jd + t` (t = fraction of a day)

```
d    = (jd + t) − 2451545.0
g    = fix(357.529 + 0.98560028·d, 360)
q    = fix(280.459 + 0.98564736·d, 360)
L    = fix(q + 1.915·sin g + 0.020·sin 2g, 360)
e    = 23.439 − 0.00000036·d
RA   = fix(atan2(cos e · sin L, cos L) / 15, 24)
decl = asin(sin e · sin L)
EqT  = q/15 − RA                      // hours
```

### 3.3 Building blocks

```
midDay(t)            = fix(12 − EqT(jd + t), 24)
angleTime(a, t, dir) :  x = (−sin a − sin decl · sin lat) / (cos decl · cos lat)     // decl at jd + t
                        if x < −1 or x > 1 → null
                        h = acos(x) / 15
                        return midDay(t) − h   (dir = before noon)   or   midDay(t) + h   (after noon)
asrTime(f, t)        = angleTime(−acot(f + tan|lat − decl|), t, after)                // f = 1 or 2
horizon              = 0.833 + 0.0347·sqrt(elevationMeters)
```

`a` is the depression angle in degrees below the horizon (positive = below).

### 3.4 One day, in the "UT + longitude/15" frame

Start values (fractions of a day): fajr 5/24, sunrise 6/24, dhuhr 12/24, asr 13/24, sunset 18/24,
maghrib 18/24, isha 18/24. Repeat **exactly 3 times**:

```
fajr    = angleTime(fajrAngle,    t.fajr,    before)
sunrise = angleTime(horizon,      t.sunrise, before)
dhuhr   = midDay(t.dhuhr)
asr     = asrTime(factor,         t.asr)
sunset  = angleTime(horizon,      t.sunset,  after)
maghrib = angleTime(maghribAngle, t.maghrib, after)   // only if maghribAngle != null
isha    = angleTime(ishaAngle,    t.isha,    after)   // only if ishaAngle != null
for each non-null result: t.x = result / 24
```

### 3.5 High-latitude adjustment

Skip when `highLatitude == none` or when sunrise or sunset is null. Otherwise:

```
night   = fix(sunrise − sunset, 24)
portion(angle) = night/2 (nightMiddle) | night/7 (oneSeventh) | angle/60 · night (angleBased)
fajr    : if fajr is null or fix(sunrise − fajr, 24) > portion(fajrAngle)   → fajr = sunrise − portion(fajrAngle)
isha    : (angle-based isha only)  if null or fix(isha − sunset, 24) > portion(ishaAngle) → isha = sunset + portion(ishaAngle)
maghrib : (angle-based maghrib only) same rule with maghribAngle, base sunset
```

### 3.6 Finishing

```
if maghribAngle == null : maghrib = sunset
if ishaAngle == null    : isha = maghrib + ishaMinutes/60      (null if maghrib is null)
shift = utcOffsetHours − longitude/15 ;  add shift to every non-null time
imsak = fajr − imsakMinutes/60
midnight : run 3.4–3.5 for date + 1 day, take `end` = its fajr (jafari) or its sunrise (standard),
           midnight = sunset + ((end + shift + 24) − sunset) / 2 ;  null if sunset or end is null
```

### 3.7 User adjustments, rounding, validity

Applied by a thin layer on top of the pure calculator, in this order:

1. **Per-prayer offsets**: a signed number of minutes (−60…+60, default 0) for each of the nine
   times, added to the computed value.
2. **Rounding for display and for scheduling**: to the nearest minute, half up
   (`floor(minutes + 0.5)`). The azan fires at the rounded minute, at second 00, so the clock on
   screen and the sound agree.
3. Times are then converted to UTC instants: `instant = localMidnightUtc(date) + roundedDuration`,
   where `localMidnightUtc(date) = DateTime.utc(y, m, d) − utcOffset`.

Golden test requirements for the Dart port (`packages/prayer_core/test/golden_test.dart`):
every vector's nine unrounded values within ±1 second of `seconds`, and the rounded `HH:mm`
strings exactly equal to `display`.

Independent check already done on the reference: Tehran, method `tehran`, four dates in 2026
compared with a public third-party calculator: every time within 1.1 minutes (differences are
rounding only). Do not "tune" the algorithm to match any other source.

## 4. Qibla and sun

- **Bearing** (degrees clockwise from true north), Kaaba at 21.422487° N, 39.826206° E:
  `fix(atan2(sin(Δλ), cos φ · tan φK − sin φ · cos(Δλ)), 360)` with `Δλ = λK − λ`.
  Reference value: Tehran (35.6892, 51.3890) → 218.4°. More in the golden file under `qibla`.
- **Distance**: great-circle, Earth radius 6371.0088 km (haversine).
- **Sun azimuth and altitude now**: from `decl` and `EqT` above:
  `H = 15·(utcHours + λ/15 + EqT − 12)`; `alt = asin(sin φ sin δ + cos φ cos δ cos H)`;
  `az = fix(atan2(−sin H, tan δ cos φ − sin φ cos H), 360)`.
- **Sun-on-qibla time** (legacy L-07): scan the day from sunrise to sunset in 1-minute steps, find
  where `az` crosses the bearing (`مقارنه`: sun in the qibla direction) or bearing + 180°
  (`مقابله`: shadow points to the qibla), then refine by bisection to 1 second. Report whichever
  occurs while the sun's altitude is above 0°; show "—" if neither does.

## 5. Schedule engine

### 5.1 Events

```
ScheduledEvent { String id; EventKind kind; Prayer? prayer; DateTime instantUtc; }
EventKind = azan | reminder | wakeAlarm | dayRollover
id        = "<kind>:<prayer or alarmId>:<yyyy-MM-dd of the civil date in the location zone>"
```

The engine builds events for today and tomorrow (location zone) from the current settings.
Only enabled items produce events. A reminder is `azanInstant − reminderMinutes`.
`dayRollover` is at local 00:00:05 and triggers a rebuild.

### 5.2 Running

- One `Timer` is armed for the nearest future event. When it fires: handle every event with
  `instantUtc ≤ now`, then re-arm.
- **Rebuild triggers**: app start, settings change, location change, `dayRollover`, system resume
  from sleep, Windows time-change notification, and the watchdog below.
- **Watchdog**: every 15 s compare elapsed wall-clock time with elapsed monotonic time
  (`Stopwatch`). A difference above 5 s means the clock was changed or the PC slept → rebuild.
- **Exactly-once**: the id of every handled event is recorded (in memory and in the persisted
  state file, pruned after 3 days). An id is never handled twice, even across restarts.
- **Catch-up after a gap** (start, resume, clock change). For each unhandled event with
  `instantUtc ≤ now`:
  - `azan`: if late by ≤ `azanGraceMinutes` (default 3) play it; otherwise mark handled and show a
    quiet "missed" notification with the time. Never play two azans back to back: only the most
    recent missed azan is considered for playing.
  - `reminder`: if its azan is still in the future, show it with the true remaining time; else drop.
  - `wakeAlarm`: if late by ≤ 10 minutes run it; else drop.
- Failures (audio file missing, device busy) never block the engine: log, show a non-modal
  notification, fall back to the bundled default sound, continue.

### 5.3 "Next prayer" for the UI

Derived state, recomputed each second from `Clock`: the current period (the latest event already
passed), the next event, and the remaining `Duration`. After the last event of the day the next
event is tomorrow's first one. Prayer identity is always the `Prayer` enum; display strings come
from localisation only (fixes B-04).

Which rows count as "next": imsak (if shown), fajr, sunrise, dhuhr, asr (if shown), sunset,
maghrib, isha (if shown), midnight.

## 6. Calendars

- **Jalali (Shamsi)**: `package:shamsi_date` (arithmetic algorithm, matches Iran's official calendar
  for 1178–1633 AP). Week starts on Saturday. Persian month and weekday names from localisation.
- **Hijri**: `package:hijri` (Umm al-Qura table, valid 1356–1500 AH) plus a user adjustment of
  −2…+2 days (default 0), applied by shifting the Gregorian date before conversion. Iran's official
  lunar calendar follows moon sighting and often differs from Umm al-Qura by a day, so the
  adjustment control sits next to the Hijri date and the date carries a "تقریبی" hint while the
  adjustment is 0. Month names in Persian come from our own localisation (the package has none).
- **Occasions** (P1): a bundled JSON keyed by calendar and month-day; see product spec F-21.
- **Conversion tool**: any of the three calendars → the other two, plus weekday.

Tests: 1 Farvardin 1405 = 21 March 2026 (a Saturday); 1 Farvardin 1404 = 21 March 2025;
30 Esfand 1403 exists (1403 is a leap year); 11 November 2026 = 20 Aban 1405.

## 7. Wake-up alarms (legacy L-14)

```
WakeAlarm { id, enabled, label,
            trigger: fixedTime(hh:mm) | relativeToPrayer(prayer, minutesBefore),
            repeat: once | daily | weekdays(Set<Weekday>),
            playSound: bool, soundRef, volume,
            afterSound: nothing | sleep | hibernate }
```

- The app computes the next occurrence itself and asks the OS to wake at that instant
  (`WakeTimerService`, see architecture doc). For `relativeToPrayer` the instant is recomputed
  every day, so it follows the prayer time through the year.
- On wake: the schedule engine sees the `wakeAlarm` event, plays the sound if enabled, and when
  the sound ends (or immediately if no sound) performs `afterSound`, after a 30-second on-screen
  countdown that the user can cancel. Never suspend without that countdown.
- `once` alarms disable themselves after firing.
