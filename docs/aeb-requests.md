# Requests For aeb

## Dart Language Module

Skir now has a native Aether `skir-dart-gen` that emits Dart source from
`skir-ir.json`. To keep the responsibilities clean, Skir should stop at source
generation and aeb should own the Dart build/test/package step.

Request for the aeb maintainers: add `/home/paul/scm/aeb/lib/dart` with a
shape similar to the existing language modules such as `lib/python`,
`lib/go`, `lib/java`, and `lib/kotlin`.

Useful initial surface:

- `dart.pub_get(b)` or equivalent package restore for `pubspec.yaml`.
- `dart.analyze(b)` for `dart analyze`.
- `dart.test(b)` for `dart test`.
- `dart.compile(b)` for `dart compile exe` or another explicit binary target.
- A codegen helper that can declare generator inputs, generated outputs, cwd,
  and arguments, following the explicit-input/output style used by
  `python.codegen`.

Skir use case:

1. `skir gen` writes `bindings/dart/*.dart`.
2. An aeb Dart target runs `pub get`, `dart analyze`, and optionally
   `dart test` or `dart compile`.
3. The Dart module tracks generated files as outputs so stale or partial
   generation fails deterministically.

This keeps the Dart generator as a pure source emitter and lets aeb provide the
per-language build technology.
