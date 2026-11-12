# UI guidelines

The legacy program was a grey dialog with five tabs of number boxes. This app should feel calm, clear and
native to a modern desktop: one glance tells you what is next and how long is left. These are the rules
every screen follows; read them before you add or change one. What the screens do is in
[product.md](product.md).

## Principles

1. **One answer first.** Home answers "what is next and when?" in the largest type on screen.
2. **Calm.** Few colours, generous spacing, nothing decorative that carries no information. The only
   animations are short fades and the cross-fade of the sky colours (300 ms, off when the system asks to
   reduce motion).
3. **Persian first, every language equal.** Right-to-left layout, Persian digits and the Shamsi date are
   the default; the other seven languages are not afterthoughts.
4. **Tray first.** Most days the window stays closed, so the tray tooltip and menu and the notifications
   must be complete on their own.
5. **Every state is designed.** Loading, empty, error, muted, playing, polar day with no times, wrong PC
   clock, offline: each has a defined look and a plain sentence. Never show a raw exception.
6. **Say what happens before it happens.** Anything that uses the network, the device position or
   changes something on the PC is explained first, in plain words, with the next step on failure.

## Window and shell

- Default size 1040 x 680, minimum 800 x 560 (`WindowController`), resizable; size and position are
  remembered in `state.json`. Standard Windows title bar.
- `AppShell`: a Material `NavigationRail` on the start side (the right in Persian, Arabic and Urdu, the
  left otherwise), at least 72 px wide, a divider, then the page. Page content is at most **960 px** wide
  and centred.
- Destinations, in order: Home, Timetable, Calendar, Qibla, Wake-up, Settings. Ctrl+1 to Ctrl+6 jump to
  them, Ctrl+comma opens Settings, Esc stops a playing azan (or cancels a countdown) from any screen.
- When the window is narrower than 900 px the rail shows icons only.
- The countdown after a wake-up alarm is shown at the bottom of every screen as a banner, not as a dialog.
- While onboarding is not finished the shell shows the first-run page instead of the rail.

## Responsive breakpoints actually used

The widths below are the width of the page area (window width minus the rail, at most 960), except where
stated. Keep new screens on the same scale; do not invent new numbers without a reason.

| Where | Rule |
|---|---|
| Rail labels | Window width under 900: icons only |
| Home | List and status card side by side from 720; header on one line from 640 |
| Calendar | Grid and side panel side by side from 760 |
| Qibla, compass tab | Two columns from 720 |
| Qibla, map tab (`QiblaMapTab.twoColumnWidth`) | Map plus a 360 px side panel from 900; below that the map (at least 320 px tall) sits above the panel and the page scrolls |
| Settings | Section list (208 px) beside the content; under 560 x text scale it becomes a drop-down |
| A settings row | Label and control on one line from 420 x text scale, otherwise stacked |
| Timetable | The table scrolls horizontally when its columns do not fit |

At the minimum window size (800 x 560) every screen must be usable without clipped controls.

## Reading direction, digits, text

- Direction follows the language (`AppLanguage.rtl`): Persian, Arabic and Urdu are right-to-left. Use
  directional values (`EdgeInsetsDirectional`, `AlignmentDirectional`, start/end), never left/right.
- Digits are a separate choice from the language: Persian, Latin or Arabic-Indic. Defaults: Persian digits
  for Persian and Urdu, Arabic-Indic for Arabic, Latin for the rest. All numbers, times and durations go
  through `Formatter`, which applies the digit style and decimal separator, the 12/24-hour clock, and wraps
  times and Latin fragments in a left-to-right isolate so "17:20" never renders reversed in right-to-left
  text.
- Times and countdowns use tabular figures so digits do not jitter.
- Durations in sentences are words ("1 hour and 23 minutes left"); the hero countdown is `HH:MM:SS`.
- Tone: short, plain, no exclamation marks, no technical words ("time zone", not "IANA zone"). Use the
  half-space (ZWNJ) correctly in Persian.
- The glossary of the nine prayer names lives in the ARB files; use those messages, never new wording.
- **Text scaling:** layouts must survive a text scale of 2x without overflow. Use `Wrap`, `Flexible`,
  `FittedBox` for the countdown, and thresholds multiplied by the text scale (see Settings above).
- **Font:** Vazirmatn (Regular, Medium, Bold; SIL Open Font License 1.1), bundled in
  `app/assets/fonts` and declared in `app/pubspec.yaml`. It covers the Arabic script (Persian, Arabic,
  Urdu) and the Latin letters of the other languages: every character used by the eight ARB files is in the
  font except one arrow in the Persian file, which falls back to a system font. Do not add a second
  font family for a language. Widget tests use the test font, so the real look still has to be checked in
  the running app.

## Visual system

- Material 3 with a seeded colour scheme (seed teal `#0F766E`), light and dark, plus the choice "follow
  Windows". Tokens live in `app/theme/app_theme.dart` (spacing 8, 12, 16, 24, 32; radius 16 for cards, 12 for
  controls; type scale display 56/64, headline 28/36, title 20/28, body 15/24, label 13/18) and
  `app_colors.dart` (a `ThemeExtension`: card surface, warm accent for the next prayer and the countdown,
  success, warning, danger, four sky gradients). Widgets use these tokens, not literal colours or sizes.
- The hero card background follows the sun: night, dawn, day, dusk. A 40 % scrim keeps white text at
  least 4.5:1 against the gradient (a test checks it). Status colours are used for status only.
- Both themes must be checked for every new screen.

## Accessibility and input

- Every control is reachable and operable with the keyboard, with a visible focus indicator.
- Interactive widgets have a semantic label in the current language. Things that change every second
  (the countdown) are excluded from the accessibility tree and replaced by a phrase that changes once a
  minute (`liveRegion`). Status messages (banners, search results, errors, the wake-up self-test, the
  wake-up countdown) are live regions.
- Tap targets are at least 44 px tall (the custom tappable rows use a 44 px minimum height; the dense
  timetable rows 40); Material controls keep their default sizes and are not shrunk.
- Colour is never the only carrier of meaning: status has an icon or a word as well.
- No blocking dialog may be opened by a background event; the azan is stoppable with one click or Esc.

## How every flow explains itself

- **Consent before network use.** The place search shows, above the box, a notice that the typed text goes
  to the OpenStreetMap search service, that nothing else is sent and that the app works offline afterwards;
  the qibla map shows a card ("Show the map") explaining that the area you look at is sent to
  OpenStreetMap, or to Esri for satellite, and that nothing is requested until you agree. Anything new that
  touches the network follows the same pattern ([adr/0006-place-search-and-offline-use.md](adr/0006-place-search-and-offline-use.md)).
- **Plain-language errors with a next step.** Place search distinguishes offline ("Connect and press
  Search again. The rest of the app works offline."), timeout, server busy, "found but the time zone could
  not be fetched, choose it again", and "this zone is not in the app database, add it with Custom
  location". The qibla page explains why the device position failed (service off, permission refused,
  timeout, unsupported) and, for Windows, shows a numbered how-to card with a button that opens the
  Windows location settings; if that cannot be opened it says so. A missing sound file plays the default
  and says so; a wake-up self-test names what the PC refuses and offers to open Power Options.
- Changes in Settings apply at once and a small tick confirms; there is no Save button. Text fields apply
  on Enter or when focus leaves, never per keystroke.
- Destructive or irreversible actions (import a backup, reset settings) ask first and say what will happen.

## The screens, briefly

- **Home:** header (location switcher, the three dates, previous/next day and "today"), banners, hero card
  (countdown, event, day timeline), today's list, status card, and a now-playing bar with Stop at the
  bottom while audio plays. A polar day shows dashes and an explanation with a link to the high-latitude
  setting.
- **Timetable:** month navigation and a calendar-type switch, a table of the shown times with today
  highlighted; a row opens that day on Home.
- **Calendar:** month grid with the three calendars, side panel for the chosen day, Hijri adjustment and the
  three-field date converter.
- **Qibla:** a segmented switch between the Map tab (the default) and the Compass tab. Map: the source of
  the position, bearing and distance, the map with camera and style chips, or the consent card while the
  map is off. Compass: the rose with the qibla line and the sun, bearing, distance, sun-on-qibla times and a
  note that a PC has no compass.
- **Wake-up:** a capability panel, the alarm cards with an enable switch, an editor dialog, "sleep now" and
  "hibernate now" and the "test in two minutes" action.
- **Settings:** section list (Location, Calculation, Azan, Reminders, Time, Display, App, About) and the
  section content.
- **Onboarding:** one centred card, three steps with a progress indicator, Next and Skip.
- **About:** version, licence notes, developer card, support card (copyable card and wallet values, with
  the countries each works in), contribute card, and the diagnostics.

## A new or changed screen is done when

1. It follows the rules above in light and dark, at 1200 x 800 and 800 x 560 (and the breakpoints it uses),
   at text scale 1x and 2x, in a right-to-left and a left-to-right language.
2. Its strings are in **all eight** ARB files (`packages/owghat_lib/lib/l10n`), generated with
   `flutter gen-l10n`, and `flutter test test/l10n` passes.
3. It is part of the all-languages layout test
   (`packages/owghat_lib/test/app/all_languages_test.dart`), which pumps every destination and every
   settings section in every language at 1200 x 800 and 800 x 560 and fails on any layout exception. A
   screen that is not reachable through a destination or a settings section needs its own layout test in
   the same style as the feature tests (for example `test/features/places/place_search_test.dart`,
   which also runs at text scale 2).
4. Layout tests with a text scale of 2 exist for the new widgets.
5. Anything it tells the user is plain, short and says what to do next.
