# Skir Aether Port

Skir's executable core now lives in `aether/skir.ae`. The command wrapper at
`bin/skir` builds it with `ae build` and runs the native binary from
`build/skir-ae`. The repo build target is `.build.ae` for aeb, and tests run
through `.tests.ae` using Aeocha; there is no root npm package.

Current native surface:

- `skir init`
- `skir gen`
- `skir format`
- `skir snapshot`
- `skir version`

`gen` scans `skir-src/**/*.ae`, builds each Aether schema DSL program, and uses
the emitted `skirout/skir-ir.json` as the native generator contract. This path
does not generate or parse `.skir` text as an intermediate; schemas are Aether
programs that use `skir_schema` builder calls to produce IR directly.

A minimal schema source looks like this:

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

Language generators consume the IR rather than importing the old TypeScript
parser. The native generator targets live under `generators/<language>`.

Generator config is JSON:

```json
{
  "generators": [
    { "kind": "ir", "outDir": "./skirout" },
    {
      "kind": "external",
      "outDir": "./bindings/typescript",
      "command": "target/build/generators/typescript/bin/skir-typescript-gen"
    },
    {
      "kind": "external",
      "outDir": "./bindings/python",
      "command": "target/build/generators/python/bin/skir-python-gen"
    }
  ]
}
```

When `command` is present, Skir runs it as:

```text
<command> <outDir>/skir-ir.json <outDir>
```

That is the replacement for the old npm-module generator import path. Per-target
generators can be native Aether binaries and do not need to link to or import
the Skir core. In this repo, `aeb .build.ae` builds those binaries under
`target/build/generators/...` before `skir gen` runs them.

Language-specific package metadata belongs to the binding generator output. The
TypeScript generator emits `package.json`; the Python generator emits
`pyproject.toml`; the remaining language generators emit source modules only in
this first native pass. Skir itself does not use npm as build or runtime
infrastructure. Local `genrs/` clones are reference material for comparing
against the historical Node implementations and are intentionally ignored.

The port intentionally uses `skir.json` for the new config path. Aether does not
currently ship a YAML parser, and reintroducing Node only to parse `skir.yml`
would keep TypeScript in the core path.
