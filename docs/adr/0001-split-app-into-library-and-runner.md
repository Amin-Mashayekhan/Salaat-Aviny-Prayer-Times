# ADR 0001 — Split the Flutter app into a testable library and a thin runner

Status: accepted (2026-11-11). Updates `03-ARCHITECTURE.md` section 2.

## Context

`window_manager` and `tray_manager` (0.6 / 0.8) depend on `nativeapi` / `cnativeapi`, which has a
Dart build hook that compiles C++ with MSVC. `flutter test` runs build hooks for every package in
the dependency graph, so any package that depends on them cannot be tested on a machine without
Visual Studio "Desktop development with C++". The development machine has no Visual Studio and
about 5 GB of free disk on C:.

## Decision

- `packages/owghat_lib` (Flutter package): everything except plugin glue - theme, l10n, shell,
  features, state, schedule engine, platform INTERFACES and fakes. Depends only on pure Dart
  packages plus `flutter`, so `flutter test` works anywhere.
- `app/` (package `owghat`): the Windows runner. `main.dart`, the Windows implementations of the
  platform interfaces (`window_manager`, `tray_manager`, `audioplayers`, notifications,
  `windows_single_instance`, `file_selector`, `path_provider`, FFI wake/sleep calls), the bundled
  fonts and audio, and the native Windows project. It has almost no logic, so it has no unit tests;
  it is verified by the manual checklist.
- Paths in the docs that say `app/lib/src/...` now mean `packages/owghat_lib/lib/src/...`, except
  `core/platform/**/impl` which lives in `app/lib/src/platform/`.

## Consequences

- Layering rule 7 of the architecture ("no plugin type outside core/platform impl") is now enforced
  by the package boundary: `owghat_lib` cannot import a plugin.
- Fonts are declared in `app/pubspec.yaml`; widget tests in the library render with the test font.
- Bundled city data lives in `owghat_lib/assets/data` and is loaded through an injectable loader.
- `launch_at_startup` was dropped (it needs win32 ^5 while `win32` 6.x is used); autostart writes
  the `HKCU\...\Run` value through `reg.exe` instead.
