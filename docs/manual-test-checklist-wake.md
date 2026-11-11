# Manual test checklist: wake-up alarms (M7 gate)

Everything here needs a real Windows PC that can sleep. Nothing in the wake feature has been run on
hardware yet (see `docs/adr/0005-wake-timers.md`). Run it on Windows 10 and Windows 11, on a **standard
(non-admin) account**, once on mains power and once on battery if the PC has one. Do not change the
Windows clock. Do not run any `powercfg` command that sets a value; only read.

Record at the bottom: date, Windows build, laptop or desktop, `powercfg /a` first line of the
"available" list (Standby (S3) or Standby (S0 Low Power Idle)), app version.

## 0. Preparation

1. Install the app per user. Open Control Panel > Power Options > Change plan settings > Change advanced
   power settings > Sleep > Allow wake timers and write down AC and battery (Disable / Enable /
   Important Wake Timers Only). Do not change it yet.
2. In a normal console run `schtasks /Query /FO CSV /NH` and confirm no `\Owghat\...` task exists.

## 1. Capability panel (self-test)

| # | Step | Expected |
|---|---|---|
| 1.1 | Open Wake-up, press the self-test button | Task creation: OK (no admin prompt). In-process timer: OK. AC/battery values match step 0.1. Modern Standby matches `powercfg /a`. |
| 1.2 | `schtasks /Query /FO CSV /NH` right after | No `\Owghat\Probe` task is left. |
| 1.3 | With "Allow wake timers" set to Disable in Windows (changed by you, by hand), self-test again | The panel explains that wake timers are off and offers to open Power Options. The app did not change the setting. Restore it afterwards. |

## 2. Wake from sleep

| # | Step | Expected |
|---|---|---|
| 2.1 | Press "Test in 2 minutes", then press "Sleep now" and let the 5-second countdown finish | The PC goes to sleep. `schtasks /Query /TN "Owghat\Wake-wake-test-..." ` shows a task (check after waking if you cannot before). |
| 2.2 | Wait | The PC wakes by itself about 2 minutes after step 2.1, the screen turns on, the alarm sound plays. |
| 2.3 | Do nothing for 3 minutes after the sound ends | The PC does not go back to sleep for at least 10 minutes (the app holds it awake). |
| 2.4 | Repeat 2.1 with the app window closed to the tray | Same result. |
| 2.5 | Repeat 2.1 after quitting the app from the tray menu | The PC wakes (the scheduled task). The app starts by itself with `--wake`, the alarm plays within about 1 minute of the due time, and keeps running after the task finishes (check Task Manager 5 minutes later). |
| 2.6 | Repeat 2.1 with Hibernate now | The PC hibernates and wakes (or: record that it does not). |

## 3. Alarms and the countdown

Create alarms in the Wake-up screen. Use a time 3 to 5 minutes ahead.

| # | Step | Expected |
|---|---|---|
| 3.1 | Fixed-time alarm, daily, sound on, after sound: sleep | At the time the sound plays and a 30-second countdown with a Cancel button appears after it. After 30 s the PC sleeps. The next day's wake is armed (the task exists with tomorrow's time). |
| 3.2 | Same, but press Cancel during the countdown | The PC does not sleep and stays awake for at least 10 minutes. |
| 3.3 | Same with after sound: hibernate | After the countdown the PC hibernates. |
| 3.4 | Same with sound off | The countdown starts immediately. |
| 3.5 | Alarm "40 minutes before Fajr" | Next occurrence shown equals today's (or tomorrow's) Fajr minus 40 minutes; the day after, it moves with Fajr by about a minute. |
| 3.6 | A once alarm | After it fires, it shows as switched off and its task is gone (`schtasks /Query`). |
| 3.7 | Weekdays alarm with only tomorrow unchecked | It skips tomorrow. |
| 3.8 | Disable an alarm, then delete another | `schtasks /Query /FO CSV /NH` shows no `\Owghat\Wake-<that id>` task. |
| 3.9 | Press "Sleep now" and then Cancel within 5 seconds | Nothing happens; the PC stays awake. |
| 3.10 | Sound file missing (point the alarm at a deleted file) | The default sound plays and a non-modal notice says so; no dialog opens. |
| 3.11 | Put the PC to sleep over an alarm time and wake it by pressing a key 5 minutes later | The alarm still runs (late by 5 minutes). Wake it 15 minutes later: it does not run. |

## 4. Rules

| # | Step | Expected |
|---|---|---|
| 4.1 | During all of the above | No UAC prompt. The Windows power plan and clock are unchanged. |
| 4.2 | Uninstall the app | Every `\Owghat\Wake-*` task is removed (`schtasks /Query /FO CSV /NH`). |

## Results

| Date | Windows build | PC (S3 / Modern Standby) | App version | Failed steps | Notes |
|---|---|---|---|---|---|
| | | | | | |
