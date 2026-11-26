# P

Press **P** while playing a Geometry Dash level to instantly switch the current run into **Practice Mode**.

No restart. No interruption. No menu trip. The level keeps running from exactly where you are.

## Features

- One keybind (default: `P`) toggles the current run into Practice Mode mid-level.
- Uses the game's own native practice-mode transition (`PlayLayer::togglePracticeMode`), the same code path as the pause menu's Practice Mode button — so checkpoints, practice music, and all vanilla behavior apply.
- Fully customizable through Geode's built-in keybind settings.
- No HUD, popups, sounds, or custom UI.

## Requirements

- Geometry Dash **2.2091**
- [Geode](https://geode-sdk.org) **v6.0.0** or newer
- Platforms: Windows, macOS (Apple Silicon & Intel), iOS, Android — wherever Geode and GD 2.2091 run.

## Installation

1. Install [Geode](https://geode-sdk.org/install/) for Geometry Dash 2.2091.
2. Download `livebyunix.p-<platform>.geode` from the [releases page](https://github.com/live-by-unix/p-practice/releases).
3. Drag the `.geode` file into the Geode mods folder (or open it with Geode).

## Usage

1. Start any level in Normal Mode.
2. Press `P`.
3. The run switches to Practice Mode and continues from your current position.

Pressing `P` again while already in Practice Mode does nothing.

### Changing the keybind

Open **Geode → Mods → P → Settings** (or the in-game keybinds list) and rebind **Practice Mode** to any key or key combination.

## How it works

- A Geode keybind setting (`practice-mode`, category *gameplay*) registers the shortcut; Geode handles press/release/repeat and ignores text input fields automatically.
- On key press, the mod reads the live `PlayLayer` via `PlayLayer::get()` and only proceeds when gameplay is genuinely active: a valid `PlayLayer` and player exist, `isGameplayActive()` is true, the game is not paused, and Practice Mode is not already enabled.
- It then calls `PlayLayer::togglePracticeMode(true)` — the exact function `PauseLayer::onPracticeMode` invokes — so the transition is a real one (practice flag, music swap, checkpoint UI and initial checkpoint all handled by the game).
- No PlayLayer pointers are cached; state is re-queried on every press, so exiting a level can never leave a stale pointer behind.

## Building from source

Requirements:

- CMake 3.25+
- A C++23 compiler (MSVC, clang, or gcc)
- [Geode CLI](https://docs.geode-sdk.org/getting-started/geode-cli) (`geode`)
- Geode SDK v6.0.0 (`geode sdk install`, or set `GEODE_SDK`)

```sh
git clone https://github.com/live-by-unix/p-practice
cd p-practice
cmake -B build -DGEODE_SDK=/path/to/Geode/sdk
cmake --build build
```

The build produces `build/livebyunix.p.geode` (and installs it into your Geode mods folder unless `GEODE_DONT_INSTALL_MODS=ON` is set).

Platform notes:

- **macOS**: builds a universal `arm64` + `x86_64` binary via `scripts/build-macos.sh` (requires macOS).
- **Windows**: build on Windows with MSVC via `scripts/build-windows.ps1`, or cross-compile from macOS/Linux with `scripts/build-windows.sh` (requires LLVM + [xwin](https://github.com/Jake-Shadle/xwin) Windows SDK/CRT).
- **iOS**: `scripts/build-ios.sh` (requires macOS with Xcode).
- **Android**: `scripts/build-android.sh` builds both `arm64-v8a` and `armeabi-v7a` (requires the Android NDK).
- **Linux**: not supported — Geometry Dash and Geode do not run natively on Linux.

### Running the tests

```sh
cmake -B build -DGEODE_SDK=/path/to/Geode/sdk
cmake --build build --target p_tests
ctest --test-dir build
```

`p_tests` covers the gameplay-state decision table (normal run, already-practice, menus, pause, dead/inactive gameplay, destroyed PlayLayer, repeated presses). It does not require the game.

## Manual test procedure (in Geometry Dash 2.2091)

Automated tests cover the decision logic only. Verify the following in-game:

| Scenario | Expected |
|---|---|
| Normal Mode + P | Switches to Practice Mode, level continues, no restart |
| Practice Mode + P | Nothing happens |
| Main menu / level select + P | Nothing happens |
| Editor + P | Nothing happens |
| Pause menu + P | Nothing happens (use the pause menu button instead) |
| Hold P (key repeat) | Single transition, no flicker |
| Quit level, start another, press P | Works again |
| Die after switching | Respawns at the practice checkpoint like vanilla practice mode |

## Known limitations

- The shortcut only *enables* Practice Mode; it never switches back to Normal Mode (by design).
- While the pause menu is open the keybind is ignored; use the pause menu's own Practice Mode button there.
- Requires Geode v6.0.0+ / GD 2.2091; older game versions are not supported.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
