#!/usr/bin/env bash
# Build (if needed) and collect the packaged .geode mod into dist/.
set -euo pipefail

cd "$(dirname "$0")/.."

BUILD_TYPE="${1:-Release}"

if [ ! -f build/livebyunix.p.geode ]; then
    ./scripts/build.sh "$BUILD_TYPE"
fi

mkdir -p dist
cp build/livebyunix.p.geode "dist/livebyunix.p-${BUILD_TYPE}.geode"
# Also keep an unversioned copy for convenience.
cp build/livebyunix.p.geode dist/livebyunix.p.geode

echo "Packaged:"
ls -l dist/
