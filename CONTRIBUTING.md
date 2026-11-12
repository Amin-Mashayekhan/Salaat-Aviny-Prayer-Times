# Contributing

Thank you for helping. Bug reports, ideas, code, translations, testing on different machines and fixes to
the city data are all welcome.

## Reporting a problem or an idea

Open an issue on GitHub. For a bug, say what you did, what you expected and what happened, and attach the
version and the report from **Settings > About > Copy diagnostics**. The report contains no names and no
coordinates.

## Setup

1. Install Flutter stable 3.47.x (Dart 3.13.x) with Windows desktop support. To build the Windows app you
   also need Visual Studio with the "Desktop development with C++" workload. The library tests do not
   need it.
2. Run `flutter pub get` at the repository root (it is a pub workspace).
3. Checks, from the repository root unless noted:

   ```
   dart format --output=none --set-exit-if-changed .
   flutter analyze                               # no issues
   dart test                  (in packages/prayer_core)
   flutter test               (in packages/owghat_lib)
   ```

   `app/` has no automated tests; check it with `flutter analyze` inside `app/` and with the manual
   checklists in `docs/`.

## Layout

- `packages/prayer_core` is pure Dart: calculator, qibla, schedule builder. No Flutter, no I/O, no clock.
- `packages/owghat_lib` is everything else that can be tested: UI, state, scheduling, translations and the
  platform *interfaces* with fakes. It must not depend on a plugin that has a native build hook.
- `app/` is the thin Windows runner and the plugin-based implementations of those interfaces.
- `seed/` and `tools/` hold source data, generators and the Python reference implementation.

[docs/architecture.md](docs/architecture.md) explains how the parts fit together and
[docs/prayer-times.md](docs/prayer-times.md) how the times are computed.

## Rules that keep the app correct

1. No daylight-saving logic of our own, anywhere. UTC offsets come from `ZoneOffsetResolver`.
2. Only `SettingsController` methods, called from a user action, write settings. Opening a screen or a
   timer firing must never change what the user chose.
3. Do not edit `seed/golden/prayer_times_golden.json` to make a test pass, and do not weaken the
   no-daylight-saving test or the settings-never-rewritten test.
4. No `DateTime.now()`. Use the injected clock (CI enforces this).
5. Every UI string lives in the ARB files, in all languages together (see below).

## Translations

The texts are in `packages/owghat_lib/lib/l10n`: `app_fa.arb` is the template, then `app_en.arb`,
`app_ar.arb`, `app_tr.arb`, `app_ur.arb`, `app_az.arb`, `app_id.arb` and `app_fr.arb`.

- To fix a translation, edit the message in its file and run `flutter gen-l10n` inside
  `packages/owghat_lib`. Keep the `{placeholders}` and the option names inside `{x, select, ...}`
  messages exactly as they are; `flutter test test/l10n` checks this.
- To add a language: copy `app_en.arb`, set `@@locale`, translate every message (drop the `@key`
  metadata entries), add the language to the `AppLanguage` enum in
  `lib/src/features/settings/domain/app_settings.dart` (its own name, direction and default digits), run
  `flutter gen-l10n` and `flutter test`. A native speaker's review is the most valuable help.
- A new text goes into `app_fa.arb` (with its `@key` metadata when it has placeholders) and into every
  other file in the same change.

## Licence of contributions

By sending a change you agree that it is released under the [MIT licence](LICENSE) of the project.

## Pull requests

- Work on a branch, keep one change per pull request and add or update tests in the same commit.
- Commit messages follow Conventional Commits (`feat(scheduler): ...`, `fix(qibla): ...`).
- Run the checks above before you push. The CI workflow runs them too and builds the Windows app.
