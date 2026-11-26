#!/usr/bin/env bash
# Build P for iOS (arm64) and package the .geode mod.
# Requires macOS with Xcode (iPhoneOS SDK) and the Geode SDK.
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

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "error: iOS builds require macOS with Xcode." >&2
    exit 1
fi

BUILD_DIR="${BUILD_DIR:-build-ios}"

EXTRA_CMAKE_ARGS=""
if [ -n "${GEODE_DONT_INSTALL_MODS:-}" ]; then
    EXTRA_CMAKE_ARGS="-DGEODE_DONT_INSTALL_MODS=ON"
fi

cmake -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DGEODE_TARGET_PLATFORM=iOS \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT=iphoneos \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DGEODE_SDK="$GEODE_SDK" \
    $EXTRA_CMAKE_ARGS

cmake --build "$BUILD_DIR" -j"$(sysctl -n hw.ncpu)"

echo "Built: $BUILD_DIR/livebyunix.p.geode"
