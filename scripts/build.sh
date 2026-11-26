#!/usr/bin/env bash
# Build P on macOS or Linux hosts.
# Note: Geometry Dash does not run natively on Linux, so Linux builds are only
# useful for cross-compiling Windows binaries and are not officially supported.
set -euo pipefail

cd "$(dirname "$0")/.."

BUILD_TYPE="${1:-Release}"
BUILD_DIR="build"

if [ -z "${GEODE_SDK:-}" ]; then
    if command -v geode >/dev/null 2>&1; then
        GEODE_SDK="$(geode config get sdk-path 2>/dev/null | sed 's/.*= *//')"
    fi
fi

if [ -z "${GEODE_SDK:-}" ] || [ ! -d "$GEODE_SDK" ]; then
    echo "error: Geode SDK not found. Install it with 'geode sdk install' or set GEODE_SDK." >&2
    exit 1
fi

EXTRA_CMAKE_ARGS=()
if [ -n "${GEODE_DONT_INSTALL_MODS:-}" ]; then
    EXTRA_CMAKE_ARGS+=("-DGEODE_DONT_INSTALL_MODS=ON")
fi

cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DGEODE_SDK="$GEODE_SDK" "${EXTRA_CMAKE_ARGS[@]}"
cmake --build "$BUILD_DIR" --config "$BUILD_TYPE" -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu)"

echo "Built: $BUILD_DIR/livebyunix.p.geode"
