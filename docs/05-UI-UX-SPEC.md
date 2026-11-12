# 05 — UI / UX Spec

The legacy app is a grey WinForms dialog with five tabs of numeric boxes. The new app should feel
calm, clear and native to a modern desktop: one glance tells you what is next and how long is left.

## 1. Design principles

1. **One answer first.** The home screen answers "what is next and when?" in the largest type on
   screen. Everything else is secondary.
2. **Calm.** Few colours, generous spacing, no decoration that carries no information, no
   animation longer than 300 ms, none that loops.
3. **Persian first.** Right-to-left layout, Persian digits, Shamsi date first. English is a full
   mirror, not an afterthought.
4. **Tray-first behaviour.** Most days the user never opens the window. The tray tooltip, the tray
   menu and the notifications must be complete on their own.
5. **Every state designed.** Loading, empty, error, muted, playing, "no times today" (polar),
   "clock is off" each have a defined look. No raw exception text, ever.

## 2. Window

- Default 1040 × 680, minimum 800 × 560, resizable, remembers size and position.
- Standard Windows title bar (no custom chrome in v1).
- Layout: a **navigation rail** on the start side (right in Persian, left in English), 72 px wide,
  icon + label; content area beside it with a max content width of 960 px, centred.
- Below 900 px width the rail shows icons only.

Destinations, in order: **خانه** Home · **جدول ماهانه** Timetable · **تقویم** Calendar ·
**قبله** Qibla · **بیدارباش** Wake-up · **تنظیمات** Settings (pinned to the bottom of the rail).

## 3. Visual system

Material 3 (`useMaterial3: true`) with a seeded colour scheme and the tokens below. Define them
once in `app/theme/` as a `ThemeExtension`; widgets never use literal colours or sizes.

| Token | Light | Dark | Use |
|---|---|---|---|
| seed | `#0F766E` (deep teal) | same seed | `ColorScheme.fromSeed` |
| surface | `#FAFAF7` | `#111614` | window background |
| surfaceCard | `#FFFFFF` | `#1A211F` | cards |
| accentWarm | `#C2410C` | `#FDBA74` | "next prayer" highlight, countdown |
| success / warning / danger | `#15803D` / `#B45309` / `#B91C1C` | `#4ADE80` / `#FBBF24` / `#F87171` | status only |

- **Sky gradient**: the hero card background shifts with the sun: night (deep indigo) → dawn →
  day (soft blue) → dusk (amber) → night. Five fixed gradients chosen by the current period, cross-fading in
  300 ms. Text on it must keep 4.5:1 contrast (use a scrim).
- **Type**: Vazirmatn for both scripts. Scale: display 56/64 (countdown), headline 28/36,
  title 20/28, body 15/24, label 13/18. Countdown and all times use tabular figures
  (`FontFeature.tabularFigures()`) so digits do not jitter.
- **Shape and space**: radius 16 (cards), 12 (controls); spacing on a 4-px grid (8, 12, 16, 24, 32).
- **Icons**: Material Symbols Rounded. Each prayer has a fixed icon (dawn, sunrise, sun, sun-low,
  sunset, moon-rising, moon, midnight star).
- **Motion**: fades and small slides only; respect "reduce motion" (disable all but fades).

## 4. Screens

### 4.1 Home

```
┌───────────────────────────────────────────────────────────────────────────┬──────┐
│  تهران ▾                         چهارشنبه ۲۰ آبان ۱۴۰۵                     │ خانه │
│                                  ۱ جمادی‌الثانی ۱۴۴۸ · 11 November 2026    │ جدول │
│ ┌───────────────────────────────────────────────────────────────────────┐ │ تقویم│
│ │  (sky gradient)                                                       │ │ قبله │
│ │   تا اذان مغرب                                                        │ │ بیدار│
│ │   ۰۱:۲۳:۴۵                                           اذان مغرب ۱۷:۲۰   │ │      │
│ │   ───●────────────○───────────────○──────────○──●──○───────○──        │ │      │
│ │   صبح  طلوع       ظهر             عصر       غروب مغرب عشا   نیمه‌شب    │ │      │
│ └───────────────────────────────────────────────────────────────────────┘ │      │
│  ┌ اوقات امروز ─────────────────────────┐  ┌ وضعیت ─────────────────────┐ │      │
│  │ اذان صبح                    ۰۵:۱۰  🔔 │  │ اذان: روشن   [بی‌صدا ▾]    │ │      │
│  │ طلوع آفتاب                  ۰۶:۳۶    │  │ یادآوری: ۱۰ دقیقه قبل      │ │      │
│  │ اذان ظهر                    ۱۱:۴۸  🔔 │  │ قبله: ۲۱۸° جنوب غربی       │ │      │
│  │ عصر                         ۱۴:۳۹  🔕 │  │ بیدارباش بعدی: —           │ │      │
│  │ غروب آفتاب                  ۱۷:۰۰    │  └────────────────────────────┘ │ تنظیم│
│  │ ▶ اذان مغرب                 ۱۷:۲۰  🔔 │                                 │      │
│  │ عشا                         ۱۸:۰۸  🔕 │                                 │      │
│  │ نیمه‌شب شرعی                 ۲۳:۰۶    │                                 │      │
│  └──────────────────────────────────────┘                                 │      │
└───────────────────────────────────────────────────────────────────────────┴──────┘
```

- **Header**: location name (opens the location switcher), the three dates. Previous-day / next-day
  arrows and a "امروز" chip appear when viewing another day; while viewing another day the hero
  shows that day's times without a countdown and a clear "viewing <date>" label.
- **Hero card**: label "تا <next event>", the countdown `HH:MM:SS`, the event name and clock time,
  and the day timeline: dots at each event positioned proportionally from Fajr to midnight, a
  filled marker for "now", passed part drawn solid.
- **Today list**: one row per shown time: icon, name, time, and a bell toggle for the five prayers
  (on / off, same state as settings). Passed rows are dimmed; the next row is highlighted with
  `accentWarm` and a leading marker. After the last event the card title becomes "اوقات فردا".
- **Status card**: azan state with the mute menu, reminder summary, qibla summary, next wake alarm.
  Each line is a link to its screen.
- **Banners** (above the hero, dismissible, one at a time by priority): azan muted until …;
  clock skew (D-1); stale Windows zone rules (D-2); settings file was reset.
- **Now-playing bar** (bottom, only while audio plays): prayer name, progress, **توقف** button.
  `Esc` also stops.
- **No times** (polar): the list rows show "—" with an info line explaining and linking to the
  high-latitude setting.

### 4.2 Timetable

Month header with previous / next and a calendar-type switch (شمسی / قمری / میلادی). A table: day,
weekday, then one column per shown time. Today's row highlighted; Fridays tinted. Sticky header.
Clicking a row opens that day on Home. (P1 adds Export.)

### 4.3 Calendar

A month grid in the Shamsi calendar with small Hijri and Gregorian day numbers in each cell, a side
panel for the selected day (three dates, weekday, that day's prayer times), and a **date
converter**: three linked date fields; editing one updates the other two. The Hijri adjustment
stepper (−2…+2) lives here and in Settings.

### 4.4 Qibla

Two tabs at the top: **نقشه / Map** (default) and **قطب‌نما و خورشید / Compass and sun**.

**Map tab.** A side panel and a map (side by side from 900 px, stacked below). The panel asks
"قبله را از کجا حساب کنم؟" with three choices: the prayer-times city (default, e.g. نیشابور), this
device (a "find my position" button; GPS, or a Wi-Fi estimate on a PC) and any point (tap the map or
type "36.2133, 58.7958"). Below it: the bearing, the distance, latitude and longitude. The map
shows the position pin, the Kaaba, the great-circle line between them and an arrow turned to the
bearing; chips over the map switch the camera between the whole route, "around me" (street level,
to compare the line with buildings) and the Kaaba. The line ends at the centre of the Kaaba; the
gutter is a few metres away, which does not change the direction (stated on the page).
Privacy: map pictures come from OpenStreetMap, so the map is off until the user presses "show the
map" (setting `qibla.mapEnabled`); the device position is read only when asked, is never stored,
and every failure (service off, permission refused, timeout) shows its reason and keeps the
city. Without internet the line, the bearing and the numbers still work and a banner says the map
pictures could not be loaded.

**Compass tab** (works offline). Left: a compass rose (N/E/S/W in the current language) with a line to the qibla bearing and a sun
marker at the sun's current azimuth (hidden at night). Right: bearing "۲۱۸٫۴° (جنوب غربی)",
distance to the Kaaba, today's sun-on-qibla time with a two-sentence explanation ("در این لحظه
خورشید دقیقاً در جهت قبله است؛ رو به خورشید بایستید." / "… سایه‌ی شاخص جهت قبله را نشان می‌دهد."),
and a note that a PC has no compass so the drawing is relative to true north.

### 4.5 Wake-up

A list of alarm cards (label, next occurrence in words, repeat, enabled switch) and an "افزودن"
button. Editor (dialog): trigger type (fixed time / minutes before a prayer), repeat, sound and
volume with preview, "after the sound: nothing / sleep / hibernate". At the top a **capability
panel** with the result of the wake-timer probe (green "this PC can wake itself" or amber with the
reason and an "open Windows power settings" button) and a "test in 2 minutes" action. Buttons
"خواب" and "خواب زمستانی" for doing it now, each with a 5-second cancellable countdown.

### 4.6 Settings

A two-pane page: section list on the start side, the section's content beside it. Each setting is
a row: title, one-line description, control. Changes apply immediately (no Save button); a small
"ذخیره شد" tick confirms.

1. **مکان** — saved locations, add from database / add custom, set active, edit, delete.
   Per location: time zone (automatic / fixed offset) with the live "offset in effect" line.
2. **محاسبه** — method, angles, Asr rule, high-latitude rule, Imsak minutes, per-prayer offsets,
   which rows to show.
3. **اذان** — master switch and volume, fade-in, per-prayer cards (enabled, sound, volume, preview).
4. **یادآوری** — per-prayer minutes, chime.
5. **زمان** — network time check and correction, server, last result; clock diagnostics.
6. **نمایش** — theme, language, digits, 12/24 hour.
7. **برنامه** — start with Windows, start minimised, close to tray, backup / restore / reset.
8. **درباره و عیب‌یابی** — version, licences, diagnostics page.

### 4.7 Onboarding

A single centred card, three steps with a progress indicator, "بعدی" / "رد کردن": language → city
(search field with live results, province chips) → azan preview + start-with-Windows toggle.
Finishing lands on Home with the countdown already running.

## 5. Tray and notifications

- **Tooltip**: `اذان مغرب ۱۷:۲۰ · ۱ ساعت و ۲۳ دقیقه دیگر`. Updated once a minute.
- **Menu** (top to bottom): next-prayer line (disabled, bold) · today's times (disabled rows) ·
  separator · «توقف اذان» (only while playing) · «بی‌صدا» submenu (تا اذان بعدی / ۱ ساعت /
  ۲۴ ساعت / تا اطلاع ثانوی / لغو بی‌صدا) · «مکان» submenu (saved locations, radio) · separator ·
  «نمایش پنجره» · «تنظیمات» · «خروج».
- **Reminder toast**: title `۱۰ دقیقه تا اذان مغرب`, body `تهران · ساعت ۱۷:۲۰`. No focus steal.
- **Azan toast**: title `اذان مغرب`, body `تهران · ۱۷:۲۰`, action button `توقف`.
- **Missed toast**: title `اذان ظهر پخش نشد`, body `رایانه در ساعت ۱۱:۴۸ در حالت خواب بود.`
- First time the window is closed to the tray: one toast `برنامه در کنار ساعت ویندوز فعال می‌ماند.`

## 6. Text and numbers

- Glossary (use exactly these): امساک · اذان صبح · طلوع آفتاب · اذان ظهر · عصر · غروب آفتاب ·
  اذان مغرب · عشا · نیمه‌شب شرعی. English: Imsak · Fajr · Sunrise · Dhuhr · Asr · Sunset ·
  Maghrib · Isha · Midnight.
- Use the half-space (ZWNJ) correctly: «نیمه‌شب», «بی‌صدا», «می‌شود».
- Persian digits and the Persian decimal separator (٫) when `digits = persian`; a single
  `formatNumber` / `formatTime` / `formatDuration` helper does all conversions.
- Durations in words in sentences ("۱ ساعت و ۲۳ دقیقه دیگر"), `HH:MM:SS` in the hero countdown.
- Times and Latin fragments inside Persian text are wrapped for correct bidi display
  (`Directionality` / Unicode isolates), so "17:20" never renders reversed.
- Tone: short, plain, no exclamation marks, no technical words in user-facing text
  ("منطقه‌ی زمانی", not "IANA zone").

## 7. Accessibility and input

- Full keyboard operation: `Tab` order follows reading order; visible focus ring; `Ctrl+1…6`
  switch destinations; `Esc` stops audio / closes dialogs; `Ctrl+,` opens settings.
- Every interactive widget has a `Semantics` label in the current language; the countdown is a
  live region announced once a minute, not every second.
- Minimum hit target 40 × 40 px; contrast AA in both themes; respects Windows text scaling up to
  200 % without overflow (widget tests at 1.0 and 2.0 text scale).
- Colour is never the only signal (the next row also has a marker and bold weight).
