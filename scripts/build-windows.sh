#!/usr/bin/env bash
# Build P for Windows x64 from macOS or Linux using clang-cl + lld + xwin
# (Microsoft CRT / Windows SDK headers and libraries).
#
# Requirements:
#   - LLVM (clang-cl, lld-link): brew install llvm lld
#   - xwin:                    brew install xwin
#   - xwin SDK splat once:     xwin --accept-license splat --output /tmp/winsdk
#   - Geode SDK with bin/6.0.0/Geode.lib (from geode-v6.0.0-win.zip)
#
# On Windows, use scripts/build-windows.ps1 with Visual Studio instead.
set -euo pipefail

cd "$(dirname "$0")/.."

LLVM_PREFIX="${LLVM_PREFIX:-/opt/homebrew/opt/llvm}"
CLANG_CL="$LLVM_PREFIX/bin/clang-cl"
LLD_LINK="${LLD_LINK:-/opt/homebrew/bin/lld-link}"
XWIN_SDK="${XWIN_SDK:-/tmp/winsdk}"

for tool in "$CLANG_CL" "$LLD_LINK"; do
    if [ ! -x "$tool" ]; then
        echo "error: $tool not found. Install LLVM/lld (brew install llvm lld)." >&2
        exit 1
    fi
done

if [ ! -d "$XWIN_SDK" ]; then
    echo "error: Windows SDK/CRT not found at $XWIN_SDK." >&2
    echo "Run: xwin --accept-license splat --output $XWIN_SDK" >&2
    exit 1
fi

if [ -z "${GEODE_SDK:-}" ]; then
    if command -v geode >/dev/null 2>&1; then
        GEODE_SDK="$(geode config get sdk-path 2>/dev/null | sed 's/.*= *//')"
    fi
fi

if [ -z "${GEODE_SDK:-}" ] || [ ! -d "$GEODE_SDK" ]; then
    echo "error: Geode SDK not found. Install it with 'geode sdk install' or set GEODE_SDK." >&2
    exit 1
fi

if [ ! -f "$GEODE_SDK/bin/6.0.0/Geode.lib" ]; then
    echo "error: $GEODE_SDK/bin/6.0.0/Geode.lib missing." >&2
    echo "Download geode-v6.0.0-win.zip from the Geode v6.0.0 release and place Geode.lib there." >&2
    exit 1
fi

# clang-cl consumes INCLUDE/LIB like cl.exe. Assemble the xwin layout.
INCLUDE_DIRS=(
    "$XWIN_SDK/crt/include"
    "$XWIN_SDK/sdk/include/ucrt"
    "$XWIN_SDK/sdk/include/um"
    "$XWIN_SDK/sdk/include/shared"
    "$XWIN_SDK/sdk/include/winrt"
)
LIB_DIRS=(
    "$XWIN_SDK/crt/lib/x86_64"
    "$XWIN_SDK/sdk/lib/ucrt/x86_64"
    "$XWIN_SDK/sdk/lib/um/x86_64"
)

export INCLUDE
INCLUDE="$(IFS=';'; echo "${INCLUDE_DIRS[*]}")"
export LIB
LIB="$(IFS=';'; echo "${LIB_DIRS[*]}")"

export CC="$CLANG_CL"
export CXX="$CLANG_CL"
EXTRA_CMAKE_ARGS=""
if [ -n "${GEODE_DONT_INSTALL_MODS:-}" ]; then
    EXTRA_CMAKE_ARGS="-DGEODE_DONT_INSTALL_MODS=ON"
fi

cmake -B build-win -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_SYSTEM_PROCESSOR=AMD64 \
    -DCMAKE_C_COMPILER="$CLANG_CL" \
    -DCMAKE_CXX_COMPILER="$CLANG_CL" \
    -DCMAKE_C_FLAGS="--target=x86_64-pc-windows-msvc" \
    -DCMAKE_CXX_FLAGS="--target=x86_64-pc-windows-msvc -fuse-ld=lld-link /EHsc" \
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL \
    -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld-link" \
    -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld-link" \
    -DGEODE_TARGET_PLATFORM=Win64 \
    -DGEODE_SDK="$GEODE_SDK" \
    $EXTRA_CMAKE_ARGS

cmake --build build-win -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu)"

echo "Built: build-win/livebyunix.p.geode"
