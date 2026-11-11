# Instructions for the implementing agent

You are building a Flutter (Windows-first) prayer-times and azan app that replaces a 2013 WinForms
app. Everything you need is specified in `docs/`. Your job is to implement it faithfully, one task
at a time.

## Read first

1. `PROGRESS.md` — where the work stands and which task is next.
2. `docs/06-IMPLEMENTATION-PLAN.md` — the task you are about to do (Do / Files / Done when).
3. The spec sections that task points to:
   `01-PRODUCT-SPEC.md` (what) · `02-LEGACY-ANALYSIS.md` (the old app and its bugs) ·
   `03-ARCHITECTURE.md` (structure, packages, rules) · `04-DOMAIN-SPEC.md` (time model, algorithm,
   schedule engine) · `05-UI-UX-SPEC.md` (screens, text) · `07-RESEARCH-NOTES.md` (why).

## How to work

- Do exactly one task from the plan per session, in order. Do not start the next one unasked.
- Before finishing, run from the repo root and fix everything they report:
  `dart format .` → `flutter analyze` (zero issues) → `dart test` in `packages/prayer_core` →
  `flutter test` in `app`.
- Then update `PROGRESS.md` (tick the task, add a dated line of anything the next session must
  know) and commit with a Conventional Commit message. Tests go in the same commit as the code.
- If the "Done when" of a task cannot be met, stop and write what blocked you in `PROGRESS.md`
  under "Blocked". Do not mark it done, do not loosen the test.
- If a spec is ambiguous or wrong, do not improvise silently: choose the most conservative reading,
  record it as an ADR in `docs/adr/NNNN-title.md`, and update the spec in the same commit.
- Before using any package API, open its README or source in the pub cache (or `dart doc`) and
  confirm the API exists in the installed version. Never write a call from memory.
- Add packages with `flutter pub add <name>`; never hand-write a version number.

## Rules that must never be broken

1. **No DST logic of our own.** No daylight-saving switch, table, date range or "+1 hour" anywhere
   in code, data or UI. UTC offsets come only from `ZoneOffsetResolver` (IANA database or the
   user's fixed offset). See `04-DOMAIN-SPEC.md` §1. This is the bug the whole rewrite exists to fix.
2. **Code never changes a setting the user did not just change.** Only `SettingsController`
   methods called from a user action write settings.
3. **Never edit `seed/golden/prayer_times_golden.json`, and never weaken** the golden test, the
   Iran no-DST test (M3.1) or the T-5 guard test (M3.2). If one fails, the code is wrong.
4. **No `DateTime.now()`.** Use the injected `Clock`. No `Timer` outside `core/time` and `scheduler`.
5. **`packages/prayer_core` stays pure**: no Flutter, no plugins, no I/O, no clock, no globals,
   no mutable static state.
6. **Layering** as in `03-ARCHITECTURE.md` §3: widgets hold no business logic; plugin types never
   leave `core/platform/**/impl` or a feature's `data/`.
7. **Prayer identity is the `Prayer` enum.** Never compare or branch on a display string.
8. **Background events never open a modal dialog** and never throw into the schedule engine.
9. **No user-visible string outside the ARB files**; Persian and English are added together.
10. **Never** set the Windows clock, change power settings, or register anything that needs admin
    rights. Never add network calls beyond the optional NTP check.
11. Do not copy code from the legacy app or from LGPL sources. Port only from
    `tools/reference/prayer_times_reference.py`.
12. Do not ship the legacy azan MP3 files (licence unknown; see Q-2 in the plan).

## Useful commands

```
python -I tools/reference/prayer_times_reference.py show 2026-11-11 35.6892 51.3890 210 tehran
python -I tools/reference/prayer_times_reference.py generate seed/golden/prayer_times_golden.json
python -I tools/legacy/decode_legacy_locations.py "<legacy install dir>" seed/locations
```

The second and third regenerate inputs; run them only if the owner asks.
