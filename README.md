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
resulting native binary from `build/skir-ae`.

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

## Status

The native CLI surface exists and no TypeScript implementation remains in this
repo. Full target-language binding generation now belongs behind the external
generator command contract described above.
