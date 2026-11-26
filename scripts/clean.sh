#!/usr/bin/env bash
# Remove local build output. Keeps source, docs and scripts.
set -euo pipefail

cd "$(dirname "$0")/.."

rm -rf build build-* out dist
rm -f livebyunix.p.geode

echo "Cleaned build artifacts."
