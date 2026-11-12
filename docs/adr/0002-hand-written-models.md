# ADR 0002 — Hand-written immutable models instead of freezed

Status: accepted (2026-11-11). Still in force.

## Context

`freezed` and `build_runner` add a generation step, generated files in review and a dependency whose API
changes between major versions, for models that are a few dozen small classes.

## Decision

The settings tree and the other models are plain immutable classes with `copyWith`, `toJson`, `fromJson`,
`==` and `hashCode` (the settings classes share a small `JsonValue` base and lenient `Json` readers), each
covered by round-trip tests. No code generation is used in the project except `flutter gen-l10n` for the
translations.

## Consequences

- A new field means editing the class, its JSON methods and its test by hand; a round-trip test catches a
  forgotten field.
- Reading is lenient by design: unknown keys are ignored and missing or out-of-range values fall back to
  defaults, so an older or hand-edited settings file never stops the app from starting.
