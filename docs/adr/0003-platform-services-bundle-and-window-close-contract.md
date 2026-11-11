# ADR 0003 — Platform services bundle, window-close contract and toast/tray details

Status: accepted (2026-11-11). Updates `03-ARCHITECTURE.md` sections 4 and 7.

## Context

ADR 0001 put every platform INTERFACE in `owghat_lib` and every plugin in the `app` runner. The
startup sequence in `03-ARCHITECTURE.md` section 7 therefore needs one hand-over point between
the two, and several behaviours the specs leave open had to be fixed to write the code.

## Decisions

1. **`PlatformServices` bundle.** The runner builds one `PlatformServices` (audio, notifier,
   window, tray, autostart, file dialogs, paths, power events, single instance, asset loader) and
   calls `bootstrap(args, services, {extraOverrides})`. `bootstrap` is `prepareApp` (everything
   except `runApp`, testable with `PlatformServices.fake`) plus the single-instance check, error
   hooks and `runApp`. `extraOverrides` lets the runner add providers of its own (the wake-up
   feature). Every platform provider defaults to an in-memory fake, so widget tests need no setup.
2. **`AppNotifier`, not `Notifier`.** The docs called the toast interface `Notifier`; that is also
   Riverpod's base class, so it is `AppNotifier` with a `NotificationSpec`.
3. **The close button never closes the window by itself.** `WindowManagerHost` cancels every close
   request and reports `closeRequested`; `WindowController` decides: hide to the tray only when
   `settings.window.closeToTray` AND the tray icon really exists, otherwise save and quit through
   `WindowHost.quit()`. This guarantees the state files are flushed before the process ends and
   that the app is never left running with no way to reach it. `setPreventClose` from the first
   draft of the table is gone for the same reason.
4. **`--minimized`.** The native runner does not show the window after the first frame when the
   argument is present (no flash); the Dart side starts hidden only if the argument is present AND
   `settings.window.startMinimized` is on, and shows the window otherwise.
5. **Mute.** "Until the next azan" mutes until the next enabled azan plus 4 minutes (longer than
   the 3-minute catch-up grace, so a late azan is still skipped); with no azan switched on it
   falls back to 24 hours. Expiry is evaluated against the clock and never written back (T-5).
   The reminder chime is also silenced while muted.
6. **Dispatcher yields once.** The engine starts inside the build of its provider and may dispatch
   an overdue event at once; Riverpod forbids changing other providers during a build, so
   `AppScheduleDispatcher.dispatch` first awaits a microtask.
7. **Tray menu.** The "next prayer" caption shows prayer and time only (the remaining time is in
   the tooltip), so the menu changes when the next prayer changes, not every minute. The location
   submenu is always present (a checked row for the active location). A checked row is a check
   mark; the plugin has no bold text.
8. **Runner metadata.** `Runner.rc` company and product are now `Owghat`, so `path_provider`
   resolves `%APPDATA%\Owghat\Owghat`, which is the folder the installer script cleans up.
   `tools/make_app_icons.py` generates the tray and runner icons (stdlib only).

## Consequences

- Native code (`flutter_window.cpp`, `main.cpp`) and every file under `app/lib/src/platform/` is
  verified only by `flutter analyze` and the manual checklist: there is no Visual Studio on the
  development machine and plugins with build hooks cannot be tested here.
- Any future platform service is added to `PlatformServices`, its provider and its fake together.
