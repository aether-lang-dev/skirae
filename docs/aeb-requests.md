# Requests For aeb

## Dart Language Module

Resolved in aeb: `/home/paul/scm/aeb/lib/dart` now exists and Skir uses it via
`bindings/dart/.build.ae`.

Skir's current binding leaves also use aeb's `build.prereq(...)` declarations
so `aeb --prereqs bindings/<language>/.build.ae` reports the toolchain token
needed for local preflight or remote-toolchain routing. The richer
`prerequisite(...) { hint(...) }` style we discussed is not present in aeb yet;
for now Skir uses the available token declaration surface.
