#!/usr/bin/env bash
# Build P for Android (arm64-v8a and armeabi-v7a) and package the .geode mods.
# Requires the Android NDK (brew install --cask android-ndk) and the Geode SDK.
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

if [ -z "${ANDROID_NDK_HOME:-}" ]; then
    for candidate in \
        "$HOME/Library/Android/sdk/ndk" \
        /opt/homebrew/share/android-ndk \
        /usr/local/share/android-ndk; do
        if [ -d "$candidate" ]; then
            ANDROID_NDK_HOME="$candidate"
            break
        fi
    done
fi

if [ -z "${ANDROID_NDK_HOME:-}" ] || [ ! -f "$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" ]; then
    echo "error: Android NDK not found. Install it (e.g. 'brew install --cask android-ndk') or set ANDROID_NDK_HOME." >&2
    exit 1
fi

TOOLCHAIN="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake"
JOBS="$(nproc 2>/dev/null || sysctl -n hw.ncpu)"

EXTRA_CMAKE_ARGS=""
if [ -n "${GEODE_DONT_INSTALL_MODS:-}" ]; then
    EXTRA_CMAKE_ARGS="-DGEODE_DONT_INSTALL_MODS=ON"
fi

for ABI in arm64-v8a armeabi-v7a; do
    case "$ABI" in
        arm64-v8a)   SUFFIX=64 ;;
        armeabi-v7a) SUFFIX=32 ;;
    esac
    BUILD_DIR="build-android$SUFFIX"

    echo "=== Building Android $ABI ($BUILD_DIR) ==="
    cmake -B "$BUILD_DIR" -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM=android-26 \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
        -DGEODE_SDK="$GEODE_SDK" \
        $EXTRA_CMAKE_ARGS
    cmake --build "$BUILD_DIR" -j"$JOBS"
    echo "Built: $BUILD_DIR/livebyunix.p.geode"
done
