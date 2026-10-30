# Orientation for an agent working on skirae

Skir is a compact schema language for generating strongly typed bindings,
begun by Tyler Fibonacci in TypeScript. **This repo is a speculative
native-Aether rewrite** meant to showcase the Aether stack: the CLI and schema
DSL are Aether, builds and tests run on aeb, and each target language's
generator is a separate native binary. It keeps the original ISC license and
credit, and it is **not** a contribution back to upstream Skir.

Read `README.md` for the pitch and `docs/aether-port.md` for the port's state.
When this file, the README and the code disagree, the code wins (see "Known
drift" below).

## The shape in one paragraph

A schema is an **Aether program** (`skir_schema` DSL) that emits schema IR as
JSON (`skir-ir.json`). There is no `.skir` text intermediate on the main path.
The native CLI (`aether/skir.ae`) runs schema programs and hands the IR to
external generators. A generator is invoked as
`<command> <outDir>/skir-ir.json <outDir>` and writes one language's binding.
All thirteen generators are **one source file**, `generators/skir_bindgen.ae`,
built once per language under a different output name by
`generators/<language>/.build.ae`.

## Layout

| Path | What it is |
|---|---|
| `aether/skir.ae` | The CLI: `init`, `gen`, `format`, `snapshot`, `version`. `aether/.build.ae` builds it as program `skir`. |
| `aether/examples/schema_dsl.ae` | A runnable schema DSL example. |
| `skir_schema/module.ae` | The schema DSL: `document`, `structure`, `enumeration`, `field`, `variant`, `constant`, `method`, typed names (`record_name`, `field_name`, …) and type constructors (`string_type`, `array_type`, `ref_type`, …). Trailing-block builder shape. |
| `generators/skir_bindgen.ae` | The shared generator source for every target language. |
| `generators/<language>/.build.ae` | Builds `skir-<language>-gen` from `skir_bindgen.ae`. Languages: cpp, csharp, dart, gleam, go, java, kotlin, moonbit, python, rust, swift, typescript, zig. |
| `bindings/<language>/.build.ae` | Smoke leaf: generates a binding from `fixtures/greet/schema.ae`, then builds it with that language's aeb SDK. Declares its toolchain with `prereq(...)` (e.g. `prereq("node:20")`). |
| `binding_build/module.ae` | Helpers the binding leaves share (`prepare_project`, `write_text`). |
| `fixtures/greet/schema.ae` | The fixture schema the binding leaves use. |
| `bin/skir` | Shell wrapper: rebuilds `build/skir-ae` with `ae build` when `aether/skir.ae` is newer, then runs it. |
| `.build.ae` | Root aeb target: depends on `aether/.build.ae`. |
| `.tests.ae` | Test target: `aether.program_test` over `tests/skir_spec.ae`. |
| `.pre-commit.ae` | Pre-commit target: `aether.program_test` over `tests/pre_commit.ae`. `pre_commit_setup.sh` installs the git hook. |
| `docs/aeb-requests.md` | What skirae needed from aeb, and what was resolved. |
| `genrs/`, `geners/` (gitignored) | Optional local clones of the historical TypeScript generators, for reference only. Never commit them. |

## Build and test

```sh
aeb .build.ae                            # the CLI
aeb .tests.ae                            # the main test suite
aeb .pre-commit.ae                       # what the git hook runs
aeb generators/typescript/.build.ae      # one generator
aeb bindings/typescript/.build.ae        # one binding smoke leaf
aeb --prereqs bindings/typescript/.build.ae   # which toolchain it needs
bin/skir version                         # the CLI, rebuilt on demand
```

- aeb writes to `target/`; `bin/skir` writes to `build/`. Both are gitignored.
- Build files use aeb's `bldr` module and the `aeb(cap) { bldr.build() { … } }`
  entry point (the last migration, `a681452`, moved them off aeb's retired
  `build` module). Follow that shape for new leaves.
- A binding leaf needs its language's toolchain (Node, Python, a JDK, Cargo, …).
  `tests/skir_spec.ae` runs six binding leaves unconditionally (C++, Go, Java,
  Python, Rust, TypeScript), so a missing one of those toolchains fails the
  suite. The other seven leaves are not in the suite; build them by hand.
- skirae was last brought up to date with Aether 0.860.0 and aeb v0.339. If
  something fails to build with a newer one, check the Aether
  `CHANGELOG.md` for a renamed or reshaped API before assuming skirae is wrong.

## Tests

- Both test programs use **`std.spec`**, Aether's built-in successor to the
  retired aeocha (`spec.describe` / `spec.it`). aeb reads `std.spec`'s file
  report (`AE_SPEC_REPORT`).
- **`tests/skir_spec.ae`** is the main suite. It covers the schema DSL, the CLI
  smoke path, generator handoff for every language, and six binding smoke
  leaves. Write new tests here.
- **`tests/pre_commit.ae`** runs `ae check` on the CLI, builds the DSL example,
  builds and runs `tests/skir_spec.ae`, and checks `bin/skir version`. It
  clears `AETHER_HOME` first, so the installed Aether's standard library is
  used, not a source tree's.

## Conventions

- **Aether idioms** come from the Aether repo's own `AGENTS.md`
  (aether-lang-dev/aether): `(value, err)` returns with `""` meaning success,
  `match` for string dispatch, trailing-block builder DSLs, `defer` for
  cleanup, `std.os.run_capture` for spawning. Read it before writing much
  Aether here.
- **The schema DSL is the API.** A schema is an Aether program; keep it
  declarative-looking (trailing blocks, typed name constructors) while allowing
  ordinary Aether (helpers, conditionals, loops) where useful. Don't
  reintroduce a `.skir` text format on the main path.
- **Generators stay separate executables** behind the
  `<command> <ir.json> <outDir>` contract, so one language's generator can
  change without touching the core.
- **No npm at the root.** Package metadata (`package.json`, `pyproject.toml`)
  belongs to generated bindings only.
- **Licensing:** keep the ISC license and the credit to Tyler Fibonacci's
  original work.

## Known drift

- The README's size figure for the native binary (about 112 KiB) is old; it
  is larger now.

## Before committing

1. `aeb .pre-commit.ae` (or install the hook with `pre_commit_setup.sh`).
2. `aeb .tests.ae`.
3. If you touched a generator or a binding leaf, build that language's leaf.
4. Stage explicit paths. Never commit `target/`, `build/`, `genrs/`, `geners/`
   or generated bindings outside a leaf's own output.
5. Ask the maintainer before pushing.
