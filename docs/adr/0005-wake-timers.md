# ADR 0005 - Wake-up alarms: two wake mechanisms, one awake hold, explicit suspend

Status: accepted as a design on 2026-11-11. **Nothing in it has been run on real hardware.** The
development PC cannot sleep under automation and has no Visual Studio, so every operating-system
call below is written from the Microsoft documentation and checked only by `flutter analyze`. The
manual procedure at the end is the acceptance test. Implements `docs/03-ARCHITECTURE.md` section 6
and `docs/04-DOMAIN-SPEC.md` section 7. (The plan asked for ADR 0003; that number went to the platform
agent, and 0004 is reserved.)

## Context

A wake-up alarm must wake a sleeping PC at a chosen instant, make a sound, and optionally put the PC
back to sleep or hibernate. The legacy app did this with a `SYSTEM` / highest-privilege task that ran
`ping` and silently edited the power plan (bug B-10). We must not need elevation and must never change
power settings (`CLAUDE.md` rule 10).

## Decision

### 1. Two wake mechanisms, both armed for every alarm

| Mechanism | Survives the app being closed | Works if the task cannot be created | Where |
|---|---|---|---|
| Per-user Task Scheduler task `Owghat\Wake-<id>`, `WakeToRun=true`, one-time `TimeTrigger`, `InteractiveToken` + `LeastPrivilege`, action `owghat.exe --wake <id>` | yes | no | `SchtasksWakeScheduler` (library, pure + injected command runner) |
| In-process waitable timer, `SetWaitableTimer(fResume = TRUE)` | no | yes | `FfiInProcessWakeTimer` (app, `dart:ffi`) |

`CompositeWakeTimerService` arms both and fails only when both fail. Why two: the task is the only
thing that works with the app closed; the timer is the fallback if the task cannot be created (for
example if per-user creation without elevation turns out not to work, plan fallback 1) and costs
nothing.

- **Task XML** (`buildWakeTaskXml`): UTF-16LE with BOM. `MultipleInstancesPolicy=Parallel` and
  `ExecutionTimeLimit=PT0S` because the process the task starts is the app itself and stays alive; a
  limit would let Task Scheduler kill it, and `IgnoreNew` would swallow the next wake while it runs.
  `StartWhenAvailable=true` runs a missed wake when the PC is next available (the engine drops alarms
  more than 10 minutes late). `StartBoundary` is written as an absolute UTC instant
  (`2026-11-12T00:30:00Z`) so a Windows with stale daylight-saving rules cannot shift the alarm; if
  Task Scheduler rejects that form, the registration is retried with a local time plus explicit
  offset and then with a floating local time (`StartBoundaryStyle`).
- **Waitable timer threading**: waiting blocks its thread, so each timer lives on its own short-lived
  background isolate (create, arm, `WaitForMultipleObjects([timer, cancelEvent])`). Cancelling sets
  the event; killing an isolate blocked in a native call would not work. The UI thread never blocks.
- **OS wake time = alarm instant minus 30 s** (`WakeTimings.wakeLead`), so the PC and the app are up
  when the alarm is due. A wake time closer than 10 s is not requested (the PC is awake).
- **Task removal**: `schtasks /Delete /F`; "already gone" is detected by a follow-up `/Query`, not by
  parsing localised error text. `pendingIds()` lists `\Owghat\Wake-*` (CSV, first column) so a task
  left by an earlier run is cancelled on the first sync. The installer's uninstall step must run the
  same `schtasks /Query` / `/Delete` loop (M9).

### 2. Keeping the PC awake: `SetThreadExecutionState`

`ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED` while the sound plays and during the
countdown, `ES_CONTINUOUS` alone to release (`Win32AwakeHold`). The state is per thread; the main
isolate stays on the Flutter UI thread, so set and clear happen on the same thread. If that is ever
wrong, `PowerCreateRequest` / `PowerSetRequest` are process-wide alternatives. After an alarm that does
not suspend the PC, or after the user cancels the countdown, the hold lasts 10 more minutes and is then
released, so Windows may sleep by itself again.

### 3. Suspending: `SetSuspendState`, always behind a countdown

`WindowsPowerControl`: enable `SeShutdownPrivilege` in the process token (`AdjustTokenPrivileges`, no
elevation needed to enable a privilege the user token already holds), then
`SetSuspendState(hibernate, 0, bWakeupEventsDisabled = FALSE)` on a background isolate (it blocks until
resume). Fallbacks: `rundll32.exe powrprof.dll,SetSuspendState 0,1,0` for sleep, `shutdown /h` for
hibernate. If hibernation is off (`HiberFilePresent` = 0) `hibernate()` returns `unavailable` instead of
letting Windows sleep; the app never turns hibernation on.

The library (`WakeAlarmController`) never calls `PowerControl` except after a visible, cancellable
countdown: 5 s for "Sleep now" / "Hibernate now", 30 s after an alarm. A sound that cannot be played
(even with the default-sound fallback) skips the after-action so the PC does not silently go back to
sleep without having woken the user.

### 4. Capability probe (read-only)

`probe()` creates and immediately deletes one throw-away task (`Owghat\Probe`, far future), creates and
closes one timer handle, runs `powercfg /query SCHEME_CURRENT SUB_SLEEP RTCWAKE` (AC and DC "Allow wake
timers": 0 disabled, 1 enabled, 2 important timers only; parsed from the hexadecimal values only, so
the Windows language does not matter) and `powercfg /a` (Modern Standby detected by `S0` without `S3`
in the "available" block). Result: `WakeCapability`, whose `issues` list is a list of enums the UI maps
to localised sentences, with a button that opens Power Options (`control.exe powercfg.cpl`, which only
shows the window). **The app never runs a `powercfg` command that sets a value**; a test pins the
allowed argument lists.

### 5. Scheduling model (library)

- `nextOccurrence` (pure): fixed local time or "N minutes before prayer", recomputed per day, strictly
  after now, repeat once / daily / weekdays (weekday of the date the alarm *rings*), null for disabled,
  fired `once`, polar days without the prayer (14-day horizon). Offsets come from `ZoneOffsetResolver`
  (rule T-7, one offset per civil date); there is no DST logic of ours.
- `wakeAlarmPlanProvider` produces two things: `engine` occurrences (including one inside the 10-minute
  catch-up window, so a PC that resumes a few seconds late still runs the alarm) and `upcoming`
  (strictly after now) for the OS. An alarm the user has just created or edited is never "late"
  (`editedAt`), otherwise a new alarm for a time that has just passed would ring immediately.
- `once` alarms disable themselves after firing through `SettingsController.upsertWakeAlarm`
  (`enabled: false` only). This is the single background write to settings and is allowed because the
  user chose "once" for that alarm.
- **Riverpod caveat found while testing**: a derived provider read inside a listener callback is still
  stale, and derived providers are refreshed lazily. So the controller reacts to *root* sources
  (settings, bookkeeping, power events, an hourly check) and reads the plan one microtask later; the
  schedule engine's rebuild was deferred by one microtask for the same reason
  (`scheduler_providers.dart`). The engine now also listens to `wakeBookkeepingProvider`.
- A once alarm that was missed by more than the catch-up window (PC off) rolls to the next day instead
  of being reported; there is no stored creation time to tell the two cases apart. Accepted.

## Unverified on real hardware (the first thing to test)

1. **Per-user task creation without elevation on a standard account**:
   `schtasks /Create /XML` with `WakeToRun` and `InteractiveToken` + `LeastPrivilege`. Fallback if it
   fails: in-process timer only; the capability panel says "works while the app is running".
2. **That a per-user task actually wakes the PC** (from sleep and from hibernate), including on battery,
   and that the `Z`-suffixed `StartBoundary` is accepted and honoured as an absolute instant.
3. **Modern Standby (S0) laptops**: wake timers are often unreliable or only run in short maintenance
   windows. The panel reports `modernStandby`; behaviour is unknown.
4. **`SetSuspendState` and the shutdown privilege**: whether enabling `SeShutdownPrivilege` is enough,
   whether `SetSuspendState` hibernates when hibernation is on, and that the rundll32 / `shutdown /h`
   fallbacks work.
5. "Important Wake Timers Only" (RTCWAKE = 2): whether a user task counts as important.
6. That after a timer wake the PC stays awake through the alarm because of `SetThreadExecutionState`
   (Windows would otherwise re-sleep after about two minutes), and that the display turns on.
7. That `SetThreadExecutionState` set and cleared from the main isolate hit the same thread.
8. The background-isolate waitable timer: that the PC really wakes for it and the isolate exits cleanly.
9. A task started by Task Scheduler while the app is not running: the app starts with `--wake <id>`
   (`WakeAlarmController.noteWakeLaunch`) and the engine's catch-up must run the alarm; the process
   must not be killed with the task.

## Manual hardware test

See `docs/manual-test-checklist-wake.md` for the numbered procedure and the result table.
Preparation: a standard (non-admin) Windows account, the app installed per user, a PC that is
plugged in and (separately) the same on battery, "Allow wake timers" visible in
Control Panel > Power Options > Change plan settings > Advanced > Sleep. Record the Windows build,
whether the PC is Modern Standby (`powercfg /a` in a console shows "S0 Low Power Idle"), and the
result of every step. A failed step 4-8 is a finding for this ADR, not a reason to loosen the code.

## Consequences

- Everything with testable logic lives in `owghat_lib` (XML, command arguments, parsers, composite
  service, controller) behind interfaces with fakes: 110 wake tests, no OS needed.
- `app/lib/src/platform/wake/` is thin and unverified: FFI bindings, the timer worker, the awake hold,
  the suspend call. A wrong signature there shows up only on Windows.
- The runner binds three providers (`wakeTimerServiceProvider`, `powerControlProvider`,
  `alarmSoundPlayerProvider`) and the dispatcher's `wakeAlarmHandlerProvider`; see the report in
  `PROGRESS.md`.
