# Build P for Windows (x64) and package the .geode mod.
# Requires: Visual Studio 2022 (MSVC) or Build Tools, CMake, and the Geode SDK.
$ErrorActionPreference = "Stop"

Set-Location (Join-Path $PSScriptRoot "..")

if (-not $env:GEODE_SDK) {
    $geode = Get-Command geode -ErrorAction SilentlyContinue
    if ($geode) {
        $sdkPath = (& geode config get sdk-path) -replace '.*=\s*', ''
        if ($sdkPath) { $env:GEODE_SDK = $sdkPath.Trim() }
    }
}

if (-not $env:GEODE_SDK -or -not (Test-Path $env:GEODE_SDK)) {
    Write-Error "Geode SDK not found. Install it with 'geode sdk install' or set GEODE_SDK."
    exit 1
}

if (-not (Get-Command geode -ErrorAction SilentlyContinue)) {
    Write-Error "'geode' CLI not found on PATH (needed for packaging)."
    exit 1
}

Write-Host "Using Geode SDK: $env:GEODE_SDK"

cmake -B build -G "Visual Studio 17 2022" -A x64 -DGEODE_SDK="$env:GEODE_SDK"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
cmake --build build --config Release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Built: build/livebyunix.p.geode"
