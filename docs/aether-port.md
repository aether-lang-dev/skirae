# Skir Aether Port

Skir's executable core now lives in `aether/skir.ae`. The command wrapper at
`bin/skir` builds it with `ae build` and runs the native binary from
`build/skir-ae`.

Current native surface:

- `skir init`
- `skir gen`
- `skir format`
- `skir snapshot`
- `skir version`

`gen` scans `skir-src/**/*.skir`, validates tokenization and delimiter balance,
and writes `skirout/skir-ir.json`. That JSON is the native generator contract:
future language generators should consume this IR rather than importing the old
TypeScript parser.

The port intentionally uses `skir.json` for the new config path. Aether does not
currently ship a YAML parser, and reintroducing Node only to parse `skir.yml`
would keep TypeScript in the core path.
