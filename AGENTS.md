# Orientation for an agent working on skirae

Skir is a compact schema language for generating strongly typed bindings,
begun by Tyler Fibonacci in TypeScript. **This repo is a speculative
native-Aether rewrite** meant to showcase the Aether stack: the CLI and schema
DSL are Aether, builds and tests run on aeb, and each target language's
generator is a separate native binary. It keeps the original ISC license and
credit, and it is **not** a contribution back to upstream Skir.

Read `README.md` for the pitch and `docs/aether-port.md` for the port's state.
When this file, the README and the code disagree, the code wins; several
README details are stale (see "Known drift" below).

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
| `.tests.ae` | Test target: `aether.program_test` over `tests/skir_aeocha.ae`. |
| `.pre-commit.ae` | Pre-commit target: `aether.program_test` over `tests/pre_commit.ae`. `pre_commit_setup.sh` installs the git hook. |
| `aeocha.ae` | A **local copy of the retired aeocha** test framework, kept only for `tests/pre_commit.ae` (see "Tests"). |
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

- The README and `pre_commit_setup.sh` call aeb by the absolute path
  `/home/paul/scm/aeb/aeb`. That's the maintainer's machine; use whatever `aeb`
  you have.
- aeb writes to `target/`; `bin/skir` writes to `build/`. Both are gitignored.
- Build files use aeb's `bldr` module and the `aeb(cap) { bldr.build() { … } }`
  entry point (the last migration, `a681452`, moved them off aeb's retired
  `build` module). Follow that shape for new leaves.
- A binding leaf needs its language's toolchain (Node, Python, a JDK, Cargo, …).
  `tests/skir_aeocha.ae` runs the binding smoke leaves only for toolchains
  present locally, so a missing toolchain skips rather than fails.
- skirae was last committed on 2026-10-06. Aether has moved on since (it is in
  the 0.86x releases). If something fails to build, check the Aether
  `CHANGELOG.md` for a renamed or reshaped API before assuming skirae is wrong.

## Tests

- **`tests/skir_aeocha.ae` uses `std.spec`**, Aether's built-in successor to
  aeocha (`spec.describe` / `spec.it`), despite the file's name. It covers the
  schema DSL, the CLI smoke path, generator handoff for every language, and the
  binding smoke leaves. Write new tests here, with `std.spec`.
- **`tests/pre_commit.ae` still imports the local `aeocha.ae` copy.** It runs
  `ae check` on the CLI and builds the DSL example. It clears `AETHER_HOME`
  first, so the installed Aether's standard library is used, not a source
  tree's.
- **Pending migration:** move `tests/pre_commit.ae` to `std.spec`, then delete
  `aeocha.ae`. That also removes skirae's only use of `std.ipc`: the copied
  aeocha writes a test report to `ipc.parent_channel()` when aeb spawns it, and
  aeb no longer reads that report (it reads `std.spec`'s file report,
  `AE_SPEC_REPORT`). Renaming `tests/skir_aeocha.ae` to something like
  `tests/skir_spec.ae` (and updating `.tests.ae`) belongs in the same change.

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

- The README says tests use "Aeocha"; the main suite uses `std.spec` (above).
- The README's layout and "Config" sections mention `skir.json` and `skir-src/`.
  Neither exists in the repo: they are what `skir init` creates in a user's
  project, not files of this one.
- The README's absolute aeb path (above).

## Before committing

1. `aeb .pre-commit.ae` (or install the hook with `pre_commit_setup.sh`).
2. `aeb .tests.ae`.
3. If you touched a generator or a binding leaf, build that language's leaf.
4. Stage explicit paths. Never commit `target/`, `build/`, `genrs/`, `geners/`
   or generated bindings outside a leaf's own output.
5. Ask the maintainer before pushing.
