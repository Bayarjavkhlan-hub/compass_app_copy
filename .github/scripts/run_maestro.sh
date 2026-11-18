#!/usr/bin/env bash
# Runs the Maestro suite against the device that is already booted with the
# app installed. Usage: run_maestro.sh <android|ios>
# Writes: reports/maestro-<platform>.xml (JUnit) and maestro-debug/<platform>/
# (screenshots, hierarchy dumps, logs) for the workflow to upload.
set -uo pipefail

platform="$1"
mkdir -p reports "maestro-debug/$platform"

# The first Maestro command after install may fail while its on-device driver
# starts, so warm it up before the real run.
maestro hierarchy > /dev/null 2>&1 || sleep 10

maestro test .maestro \
  --format junit \
  --output "reports/maestro-$platform.xml" \
  --debug-output "maestro-debug/$platform"
status=$?

# Also keep Maestro's own per-run folder (screenshots of failed steps).
cp -r "$HOME/.maestro/tests/." "maestro-debug/$platform/" 2>/dev/null || true
exit $status
