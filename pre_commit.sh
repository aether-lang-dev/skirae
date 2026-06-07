#!/bin/bash

set -e

ae check aether/skir.ae
AETHER_HOME= ae build aether/examples/schema_dsl.ae --lib aether -o /tmp/skir_schema_dsl_demo
bin/skir version
