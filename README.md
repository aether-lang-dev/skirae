# Skir

Skir is a schema-language experiment for generating language bindings from
`.skir` files.

This branch is a speculative native port: the core CLI is implemented in
Aether, not TypeScript, and the old npm-module generator import path has been
removed.

## Commands

```sh
bin/skir init
bin/skir gen
bin/skir format --ci
bin/skir snapshot
bin/skir version
```

`bin/skir` builds `aether/skir.ae` with `ae build` on demand and runs the
resulting native binary from `build/skir-ae`. The main repo build target is
`.build.ae`, for aeb.

## Project Layout

```text
skir.json
skir-src/
  example.skir
```

`skir gen` scans `skir-src/**/*.skir`, validates tokenization and delimiter
balance, and writes a generator-neutral IR file:

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
separate executable.

## Schema DSL

The `skir_schema` Aether module can generate `.skir` documents directly:

```aether
import skir_schema as skir

main() {
    skir.document("robot.skir") {
        structure("Point") {
            field("x", "float32")
            field("y", "float32")
        }

        enumeration("RobotAction") {
            variant("wave")
            field("say", "string")
            field("move", "Point")
        }
    }
}
```

This is an Aether builder-DSL grammar for Skir schemas. It is close to the
target shape: declarative enough to read as schema, but still native Aether code
with conditionals, loops, and helper functions available when schema generation
needs them.

## Status

The native CLI surface exists and no TypeScript implementation or root npm
package remains in this repo. Full target-language binding generation now
belongs behind the external generator command contract described above; a
language binding generator may create `package.json`, `pyproject.toml`, or other
target-specific package metadata inside its own output.
