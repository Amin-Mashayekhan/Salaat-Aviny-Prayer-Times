# Contributing

Read `README.md`, then `docs/` in numeric order. The documents are the specification; the code
follows them, not the other way round.

## Setup

1. Install Flutter stable 3.47.x (Dart 3.13.x) with Windows desktop support. To build the Windows
   app you also need Visual Studio "Desktop development with C++". Library tests do not need it.
2. `flutter pub get` at the repository root (it is a pub workspace).
3. Checks, from the repository root unless noted:

   ```
   dart format --output=none --set-exit-if-changed .
   flutter analyze                               # zero issues
   dart test                  (in packages/prayer_core)
   flutter test               (in packages/owghat_lib)
   ```

   `app/` has no tests; check it with `flutter analyze` inside `app/` and the manual checklist
   (`docs/manual-test-checklist.md`).

## Layout

- `packages/prayer_core` - pure Dart: calculator, qibla, schedule builder. No Flutter, no I/O, no clock.
- `packages/owghat_lib` - everything else that can be tested: UI, state, scheduling, platform
  *interfaces* with fakes. It must not depend on a plugin with a native build hook.
- `app/` - the thin Windows runner and the plugin-based implementations (ADR 0001).
- `seed/`, `tools/` - source data, the Python reference algorithm and generators.

## Non-negotiable rules

1. No daylight-saving logic of our own, anywhere. Offsets come from `ZoneOffsetResolver`.
2. Only `SettingsController` methods, called from a user action, write settings.
3. Never edit `seed/golden/prayer_times_golden.json` to make a test pass; never weaken the
   no-DST test or the settings-overwrite guard test.
4. No `DateTime.now()` - use the injected clock.
5. UI strings live in the ARB files, Persian and English together.
6. A decision that changes a document gets an ADR in `docs/adr/` and the document is updated in the
   same commit.

## Commits

Conventional Commits (`feat(scheduler): ...`), one task per commit, tests in the same commit.
