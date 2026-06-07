#!/bin/bash

set -e

ae check aether/skir.ae
npm run build
npm test
