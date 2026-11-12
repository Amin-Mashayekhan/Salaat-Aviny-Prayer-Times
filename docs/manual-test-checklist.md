# Manual test checklist

Everything here needs a real Windows PC, real audio and a real tray, so it cannot be covered by the
automated tests. Run it on **Windows 10 and Windows 11** before tagging a release, on a clean user
account (no settings from earlier runs). Record date, Windows build, app version and result at the
bottom. A failed item blocks the release unless it is written up as a known issue.

Wake-up alarms have their own checklist: [manual-test-checklist-wake.md](manual-test-checklist-wake.md).

Preparation: build the installer (`flutter build windows --release` in `app/`, then compile
`app/windows/installer/salaat.iss` with Inno Setup 7), and keep a stopwatch or a phone nearby.

## 1. Install, start, uninstall

| # | Step | Expected |
|---|---|---|
| 1.1 | Run `Salaat-Setup-<version>.exe` as a standard user | No admin prompt. Installs to `%LOCALAPPDATA%\Programs\Salaat`. Start-menu shortcut exists. |
| 1.2 | Start the app for the first time | Onboarding appears in Persian, right-to-left. Tehran is preselected. |
| 1.3 | Finish onboarding | Home shows the next prayer and a running countdown. Tray icon appears. |
| 1.4 | Upgrade: install a newer build over the old one | Settings and saved locations are kept. |
| 1.5 | Uninstall | Asks whether to keep settings. The autostart entry and every `Salaat\Wake-*` scheduled task are gone (check Task Scheduler and `HKCU\...\Run`). |

## 2. Tray and window

| # | Step | Expected |
|---|---|---|
| 2.1 | Hover the tray icon | Tooltip: next prayer, its time, remaining time. Updates within a minute. |
| 2.2 | Left-click the icon | The window toggles. |
| 2.3 | Right-click | Menu: next-prayer line, today's times, mute submenu, location submenu, show, settings, quit. «توقف اذان» is absent while nothing plays. |
| 2.4 | Close the window with the X | The window hides, the app keeps running; one toast explains it (only the first time). |
| 2.5 | Start the app a second time | No second tray icon; the running window comes to the front. |
| 2.6 | Quit from the tray menu | The process ends (check Task Manager). |

## 3. Azan and reminders

Use a custom location with a fixed offset (Settings, Location) shifted so that a prayer falls 3 minutes
from now. Do not change the PC clock.

| # | Step | Expected |
|---|---|---|
| 3.1 | Wait for the reminder (default 10 minutes before; set Asr reminder to 1 minute for the test) | A toast without stealing keyboard focus: prayer name and remaining time. Soft chime if enabled. |
| 3.2 | Wait for the azan time | The sound starts within 1 second of the displayed minute, once. The now-playing bar shows with Stop. A toast with Stop appears. |
| 3.3 | Press Stop (bar, toast, tray, and Esc - one per run) | Sound stops immediately. |
| 3.4 | Pick a missing file as the Fajr sound, preview it | The default sound plays instead; a quiet notice mentions it. No dialog. |
| 3.5 | Mute until the next prayer | No azan at the next time; reminder behaviour matches settings; mute clears by itself afterwards (Settings still shows the old choice until changed). |
| 3.6 | Master switch off | Nothing plays. |

## 4. Time handling

| # | Step | Expected |
|---|---|---|
| 4.1 | Set the Windows time zone to (UTC+03:30) Tehran, note today's Dhuhr in the app | Matches a trusted source within a minute. |
| 4.2 | Change the Windows time zone to UTC+4:30 (simulates stale DST rules) | The app shows the banner about Windows rules; the prayer times in the app do **not** move by an hour. |
| 4.3 | Open Settings, Location, time zone: switch to a fixed offset and restart the app | The choice is still there. Nothing changed it. |
| 4.4 | Leave the app running over midnight | The next day's times appear without a restart; exactly one azan per enabled prayer. |
| 4.5 | Change the Windows clock back 1 hour right after an azan | The azan is not played again. |
| 4.6 | Sleep the PC across an azan time and wake it 2 minutes later | The azan plays late if within 3 minutes, otherwise a quiet "missed" toast. |

## 5. Wake-up alarms

The full procedure is in [manual-test-checklist-wake.md](manual-test-checklist-wake.md). As a quick smoke
test:

| # | Step | Expected |
|---|---|---|
| 5.1 | Wake-up screen, capability panel | Green, or amber with a plain reason and a button that opens Windows power options. The app never changes power settings itself. |
| 5.2 | "Test in 2 minutes", then sleep the PC | The PC wakes by itself, plays the sound, and returns to sleep after the cancellable 30-second countdown. |
| 5.3 | Cancel the countdown | The PC stays awake. |
| 5.4 | Disable or delete the alarm | `schtasks /Query /TN "Salaat\Wake-<id>"` finds nothing. |

## 6. Display, language, accessibility

| # | Step | Expected |
|---|---|---|
| 6.1 | Switch through the languages (at least Persian, English, Arabic and Turkish) | Whole UI switches without restart; right-to-left languages mirror the layout; times never render reversed. |
| 6.2 | Light, dark, follow Windows | Contrast is comfortable in all three. |
| 6.3 | Windows text size 200% and the smallest window | No overflow or clipped text. |
| 6.4 | Keyboard only: Tab through Home and Settings, Ctrl+1..6, Esc, Ctrl+, | Visible focus; every control reachable; shortcuts work. |
| 6.5 | Narrator on Home | Prayer names and times are read; the countdown is announced about once a minute, not every second. |

## 7. Qibla map

| # | Step | Expected |
|---|---|---|
| 7.1 | Open Qibla (Map tab) with the map never enabled | A card explains that tiles come from OpenStreetMap; no network request is made. The angle and distance are already shown. |
| 7.2 | Press "Show the map" | Tiles load; a pin at the selected city, a line to the Kaaba, an arrow turned to the bearing. |
| 7.3 | "Around me" | Street level around the pin; the line can be compared with real streets and buildings. "Kaaba" shows the Kaaba; "Whole route" returns. |
| 7.4 | Choose "This device" with Windows location off (or desktop apps not allowed) | A message and a card with four numbered steps appear; the city stays in use. |
| 7.5 | Press "Open Windows location settings" in that card | The Location page of Windows Settings opens (`ms-settings:privacy-location`). Nothing is changed by the app, and the position is not read. |
| 7.6 | Turn on Settings > Privacy > Location (and desktop apps), press "Find my position" | The pin moves to the PC position with its accuracy circle (Wi-Fi estimates can be 100 m or more off). |
| 7.7 | "Any point": tap the map, then type `36.2133, 58.7958` | The pin, bearing and distance follow; bad coordinates show an error and change nothing. |
| 7.8 | Disconnect the network, reopen the tab | A banner says map pictures cannot be loaded; angle, line and numbers still work. |
| 7.9 | Compare with a real compass or the sun-on-qibla time (Compass tab) | The bearing agrees within the compass error. |

## 8. Start with Windows

| # | Step | Expected |
|---|---|---|
| 8.1 | Enable "start with Windows", sign out and in | The app is in the tray, window hidden. |
| 8.2 | Disable it, sign out and in | The app does not start. |

## 9. Backup

| # | Step | Expected |
|---|---|---|
| 9.1 | Export settings, reset to defaults, import the file | Everything is restored exactly. |

## Result log

| Date | Windows build | App version | Tester | Result / issues |
|---|---|---|---|---|
| | | | | |
