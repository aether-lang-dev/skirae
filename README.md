# Skir

Skir began as Tyler Fibonacci's TypeScript implementation of a compact schema
language for generating strongly typed bindings. This repository keeps the
original ISC license and gives credit to that work; the current branch is a
speculative native-Aether rewrite meant to showcase Aether itself.

This is not a donation back to the original Skir project. It is a local
experiment in replacing the Node/TypeScript core with:

- Aether for the CLI and schema authoring DSL.
- aeb for build and test targets.
- Aeocha for BDD-style tests.
- External generator binaries for language-specific bindings.

## Achievements

The port has changed the shape of the project substantially:

- **No root npm package**: `package.json` and `package-lock.json` are gone.
  Package metadata now belongs to generated language bindings, not to Skir's
  own build.
- **No TypeScript core**: the previous `src/*.ts` implementation and tests were
  removed. The old tree had 44 TypeScript files and about 21.5k TypeScript
  source lines.
- **No npm dependency graph**: the pre-port lockfile was about 3,174 lines and
  pulled runtime packages such as `glob`, `yaml`, `zod`, `watcher`,
  `skir-internal`, and the `skir-*-gen` packages, plus TypeScript/Mocha/ESLint
  dev tooling. The native repo has no npm install step.
- **Native CLI**: `bin/skir` builds and runs `aether/skir.ae`. The current
  native binary is about 112 KiB locally.
- **Aether schema DSL**: `skir_schema` builds schema IR directly. `.skir` is no
  longer the intended intermediate for this showcase path.
- **aeb-native build/test targets**: `.build.ae` builds the CLI and `.tests.ae`
  runs Aeocha tests.

Local rough timing, not a benchmark: after the binary already exists,
`bin/skir version` runs in about 5-6 ms on this machine. A first wrapper run that
has to rebuild the binary took about 0.54s.

## Commands

```sh
bin/skir init
bin/skir gen
bin/skir format --ci
bin/skir snapshot
bin/skir version
```

`bin/skir` builds `aether/skir.ae` with `ae build` on demand and runs
`build/skir-ae`.

## Build And Test

```sh
/home/paul/scm/aeb/aeb .build.ae
/home/paul/scm/aeb/aeb .tests.ae
```

The test target compiles and runs `tests/skir_aeocha.ae`, which exercises the
schema DSL and the native CLI smoke path.

## Schema DSL

Schemas are Aether programs. A minimal schema program looks like this:

```aether
import skir_schema (document, structure, field, string_type)

main() {
    document("skirout/skir-ir.json") {
        structure("Greeting") {
            field("message", string_type())
        }
    }
}
```

The DSL emits schema IR JSON directly. That makes Aether the authoring language
for schemas, not a generator of `.skir` text. The benefit is that schemas can
still read declaratively while using normal Aether helpers, conditionals, loops,
and module imports when useful.

## Project Layout

```text
skir.json
skir-src/
  hello_world.ae
```

`skir gen` runs schema programs under `skir-src/**/*.ae` and writes:

```text
<outDir>/skir-ir.json
```

The generated IR is the handoff point for language-specific binding generators.

## Config

```json
{
  "generators": [
    { "kind": "ir", "outDir": "./skirout" },
    {
      "kind": "external",
      "outDir": "./src/skirout",
      "command": "./bin/skir-python-gen"
    }
  ]
}
```

When `command` is present, Skir runs:

```text
<command> <outDir>/skir-ir.json <outDir>
```

That keeps the core native and lets each target-language generator evolve as a
separate executable. A TypeScript generator may emit its own `package.json`
inside its output directory; Skir itself does not need npm.

## Status

This is speculative and intentionally incomplete. The current goal is to show a
coherent Aether-native toolchain shape: Aether CLI, Aether schema DSL, aeb
targets, Aeocha tests, no Node runtime dependency, and no `.skir` text
intermediate on the main path.
