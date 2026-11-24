#!/usr/bin/env bash
# Runs the Maestro suite against the device that is already booted with the
# app installed. Usage: run_maestro.sh <android|ios>
# Writes: reports/maestro-<platform>.xml (JUnit) and maestro-debug/<platform>/
# (per-flow logs and screenshots) for the workflow to upload.
set -uo pipefail

platform="$1"
out="maestro-debug/$platform"
mkdir -p reports "$out"

# Screenshot + UI tree of whatever is on screen right now.
snapshot() {
  if [ "$platform" = android ]; then
    adb exec-out screencap -p > "$out/$1.png"
  else
    xcrun simctl io booted screenshot "$out/$1.png" > /dev/null
  fi
  maestro hierarchy > "$out/$1-hierarchy.json" 2> /dev/null || true
}

# The first Maestro command after install may fail while its on-device driver
# starts, so warm it up before the real run.
maestro hierarchy > /dev/null 2>&1 || sleep 10
snapshot before-tests

maestro test .maestro \
  --format junit \
  --output "reports/maestro-$platform.xml" \
  --test-output-dir "$out/run"
status=$?

if [ $status -ne 0 ]; then
  snapshot after-failure
  [ "$platform" = android ] && adb logcat -d > "$out/logcat.txt" 2> /dev/null
fi
cp -r "$HOME/.maestro/tests/." "$out/maestro-tests/" 2> /dev/null || true
exit $status
