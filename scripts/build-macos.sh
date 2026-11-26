#!/usr/bin/env bash
# Build P for macOS (Apple Silicon + Intel) and package the .geode mod.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -z "${GEODE_SDK:-}" ]; then
    if command -v geode >/dev/null 2>&1; then
        GEODE_SDK="$(geode config get sdk-path 2>/dev/null | sed 's/.*= *//')"
    fi
fi

if [ -z "${GEODE_SDK:-}" ] || [ ! -d "$GEODE_SDK" ]; then
    echo "error: Geode SDK not found. Install it with 'geode sdk install' or set GEODE_SDK." >&2
    exit 1
fi

if ! command -v geode >/dev/null 2>&1; then
    echo "error: 'geode' CLI not found on PATH (needed for packaging)." >&2
    exit 1
fi

echo "Using Geode SDK: $GEODE_SDK"

cmake -B build -DCMAKE_BUILD_TYPE=Release -DGEODE_SDK="$GEODE_SDK"
cmake --build build --config Release -j"$(sysctl -n hw.ncpu)"

echo "Built: build/livebyunix.p.geode"
