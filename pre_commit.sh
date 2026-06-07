#!/bin/bash

set -e

ae check aether/skir.ae
AETHER_HOME= ae build aether/examples/schema_dsl.ae -o /tmp/skir_schema_dsl_demo
AETHER_HOME= ae build tests/skir_aeocha.ae -o /tmp/skir_aeocha_tests
/tmp/skir_aeocha_tests
bin/skir version
