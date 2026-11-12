# ADR 0001 — Split the Flutter app into a testable library and a thin runner

Status: accepted (2026-11-11). Still in force; the layout is described in
[../architecture.md](../architecture.md).

## Context

`window_manager` and `tray_manager` (0.6 and 0.8) depend on `nativeapi` / `cnativeapi`, which have a Dart
build hook that compiles C++ with MSVC. `flutter test` runs build hooks for every package in the
dependency graph, so any package that depends on them cannot be tested on a machine without Visual Studio
"Desktop development with C++". Most of the code (calculation, scheduling, settings, screens) needs no
native toolchain to be tested, and contributors who only touch it should not have to install one.

## Decision

- `packages/owghat_lib` (Flutter package): everything except plugin glue — theme, localisation, shell,
  features, state, the schedule engine, and the platform *interfaces* with in-memory fakes. It depends on
  no plugin that has a native build hook (pure Dart and Flutter-only packages such as `flutter_map` are
  fine), so `flutter test` works anywhere Flutter runs.
- `app/` (package `owghat`): the Windows runner. `main.dart`, the Windows implementations of the platform
  interfaces in `lib/src/platform/` (`window_manager`, `tray_manager`, `audioplayers`,
  `flutter_local_notifications`, `windows_single_instance`, `file_selector`, `geolocator`,
  `path_provider`, `reg.exe` for autostart, the shell for links, `dart:ffi` for the wake-up calls), the
  bundled fonts and audio, and the native Windows project. It has almost no logic, so it has no unit
  tests; it is verified by `flutter analyze` and the manual checklists.
- `packages/prayer_core` stays a separate pure Dart package (calculator, qibla, schedule builder).

## Consequences

- The rule "no plugin type outside the platform implementations" is enforced by the package boundary:
  `owghat_lib` cannot import a plugin.
- Fonts are declared in `app/pubspec.yaml`; widget tests in the library render with the test font.
- Bundled city data lives in `owghat_lib/assets/data` and is loaded through an injectable loader.
- `launch_at_startup` was not used: it needs `win32` ^5 while the project uses `win32` 6.x. Autostart
  writes the `HKCU\...\Run` value through `reg.exe` instead.
- A new operating-system capability is added as an interface and a fake in the library and an
  implementation in `app/` (see [0003](0003-platform-services-bundle-and-window-close-contract.md)).
