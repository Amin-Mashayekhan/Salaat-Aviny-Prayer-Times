# ADR 0002 — Hand-written immutable models instead of freezed

Status: accepted (2026-11-11). Updates `03-ARCHITECTURE.md` section 1.

`freezed` 4 and `build_runner` add a generation step, generated files in review and a dependency
whose API changed in a major version, for models that number about twenty small classes. The
settings tree is written as plain immutable classes with `copyWith`, `toJson`, `fromJson`,
`==` and `hashCode`, each covered by round-trip tests. No code generation is used in the project
(only `flutter gen-l10n`).
